//
//  FileProviderEnumerator.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 15/03/2024.
//

import FileProvider
import OuisyncLib

class Enumerator: NSObject, NSFileProviderEnumerator {
    private let session: OuisyncSession
    private let itemId: ItemIdentifier
    private let currentAnchor: NSFileProviderSyncAnchor
    private let log: Log
    private let pastEnumerations: PastEnumerations?

    init(_ itemIdentifier: ItemIdentifier, _ session: OuisyncSession, _ currentAnchor: NSFileProviderSyncAnchor, _ log: Log, _ pastEnumerations: PastEnumerations?) {
        let log = log.child("Enumerator").trace("init(\(itemIdentifier), currentAnchor(\(currentAnchor)), ...)")
        self.itemId = itemIdentifier
        self.session = session
        self.currentAnchor = currentAnchor
        self.log = log
        self.pastEnumerations = pastEnumerations

        super.init()
    }

    func invalidate() {
        log.trace("invalidate() \(itemId)")
        // TODO: perform invalidation of server connection if necessary
    }

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
        let log = log.child("enumerateItems").trace("invoke(...) \(itemId)")
        /* TODO:
         - inspect the page to determine whether this is an initial or a follow-up request
         
         If this is an enumerator for a directory, the root container or all directories:
         - perform a server request to fetch directory contents
         If this is an enumerator for the active set:
         - perform a server request to update your local database
         - fetch the active set from your local database
         
         - inform the observer about the items returned by the server (possibly multiple times)
         - inform the observer that you are finished with this page
         */
        Task {
            do {
                let items = try await enumerateBackend()
                if !items.isEmpty {
                    observer.didEnumerate(items.map{ $0.providerItem() })
                }
                log.info("\(itemId) -> \(items)")
                if var pastEnumerations = self.pastEnumerations?.enumerations {
                    pastEnumerations[itemId] = Dictionary(uniqueKeysWithValues: items.map { ($0.id(), $0) })
                }
                observer.finishEnumerating(upTo: nil)
            } catch {
                fatalError("Unhandled exception \(error)")
            }
        }
    }
    
    func enumerateChanges(for observer: NSFileProviderChangeObserver, from oldAnchor: NSFileProviderSyncAnchor) {
        log.trace("enumerateChanges(oldAnchor: \(oldAnchor)) { item:\(itemId), currentAnchor:\(currentAnchor) }")
        /* TODO:
         - query the server for updates since the passed-in sync anchor
         
         If this is an enumerator for the active set:
         - note the changes in your local database
         
         - inform the observer about item deletions and updates (modifications + insertions)
         - inform the observer when you have finished enumerating up to a subsequent sync anchor
         */
        
        if oldAnchor == currentAnchor {
            observer.finishEnumeratingChanges(upTo: currentAnchor, moreComing: false)
        } else {
            guard let pastEnumerations = pastEnumerations?.enumerations else {
                observer.finishEnumeratingWithError(ExtError.syncAnchorExpired)
                return
            }

            guard let previousItems = pastEnumerations[itemId] else {
                // We don't know what has changed because we don't track the current state and neither does
                // the Ouisync backend. So we return `synchAnchorExpired` error which will force the system
                // to re-enumerate the items (by calling the `enumerateItems` function.
                // https://developer.apple.com/documentation/fileprovider/replicated_file_provider_extension/synchronizing_files_using_file_provider_extensions#40997540
                observer.finishEnumeratingWithError(ExtError.syncAnchorExpired)
                return
            }

            Task {
                do {
                    let currentItems = try await enumerateBackend()

                    let removedIds = Set(previousItems.keys).subtracting(Set(currentItems.map { $0.id() }))
                    let changed: [EntryItem] = currentItems.makeIterator().filter { (current: EntryItem) in
                        let removed = removedIds.contains(current.id())

                        if removed {
                            return false
                        }

                        if let prev = previousItems[current.id()] {
                            return prev.providerItem().itemVersion != current.providerItem().itemVersion
                        } else {
                            // new file
                            return true
                        }
                    }

                    if !removedIds.isEmpty {
                        observer.didDeleteItems(withIdentifiers: removedIds.map { $0.item().serialize() })
                    }

                    if !changed.isEmpty {
                        observer.didUpdate(changed.map { $0.providerItem() })
                    }

                    log.trace("\(itemId) -> previous:\(previousItems), current:\(currentItems), changed:\(changed), removed:\(removedIds)")

                    observer.finishEnumeratingChanges(upTo: currentAnchor, moreComing: false)
                } catch {
                    fatalError("Unhandled exception \(error)")
                }
            }
        }
    }

    private func enumerateBackend() async throws -> [EntryItem] {
        switch itemId {
        case .rootContainer, .workingSet:
            do {
                let reposByName = try await listRepositories()
                let items = try await reposToItems(reposByName)
                return items.map { .directory($0) }
            } catch {
                fatalError("Unhandled exception \(error)")
            }
        case .entry(.directory(let identifier)):
            do {
                let dir = try await identifier.loadItem(session)
                let entries = try await dir.directory.listEntries()
                var items: [EntryItem] = []
                for entry in entries {
                    switch entry {
                    case .directory(let dirEntry):
                        let dirItem = try await DirectoryItem.load(dirEntry, dir.repoName)
                        items.append(.directory(dirItem))
                    case .file(let fileEntry):
                        let identifier = FileIdentifier(fileEntry.path, dir.repoName)
                        items.append(.file(try await identifier.loadItem(session)))
                    }
                }
                return items
            } catch {
                fatalError("Unhandled exception for \(identifier): \(error)")
            }
        case .trashContainer:
            return []
        default: fatalError("Invalid item in `enumerateItems`: \(itemId)")
        }
    }

    func reposToItems(_ repos: Dictionary<RepoName, OuisyncRepository>) async throws -> [DirectoryItem] {
        var items: [DirectoryItem] = []
        for (repoName, repo) in repos {
            let dirItem = try await DirectoryItem.load(repo, repoName)
            items.append(dirItem)
        }
        return items
    }

    func reposToIdentifiers(_ repos: Dictionary<RepoName, OuisyncRepository>) -> Set<DirectoryIdentifier> {
        var items: Set<DirectoryIdentifier> = Set()
        for (repoName, _) in repos {
            items.insert(DirectoryIdentifier("", repoName))
        }
        return items
    }

    func currentSyncAnchor(completionHandler: @escaping (NSFileProviderSyncAnchor?) -> Void) {
        log.trace("currentSyncAnchor(item:\(itemId)) -> \(currentAnchor)")
        completionHandler(currentAnchor)
    }

    func listRepositories() async throws -> Dictionary<RepoName, OuisyncRepository> {
        var repos: Dictionary<RepoName, OuisyncRepository> = [:]
        for repo in try await session.listRepositories() {
            let name = try await repo.getName()
            repos[name] = repo
        }
        return repos
    }
}

class NoConnectionEnumerator: NSObject, NSFileProviderEnumerator {
    let currentAnchor: NSFileProviderSyncAnchor

    init(_ currentAnchor: NSFileProviderSyncAnchor) {
        self.currentAnchor = currentAnchor
    }

    func invalidate() { }

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
        NSLog("NoConnectionEnumerator.enumerateItems(...)")
        observer.finishEnumerating(upTo: nil)
    }

    func enumerateChanges(for observer: NSFileProviderChangeObserver, from anchor: NSFileProviderSyncAnchor) {
        NSLog("NoConnectionEnumerator.enumerateChanges(...))")
        observer.finishEnumeratingChanges(upTo: anchor, moreComing: false)
    }

    func currentSyncAnchor(completionHandler: @escaping (NSFileProviderSyncAnchor?) -> Void) {
        NSLog("NoConnectionEnumerator.currentSyncAnchor(...) -> Anchor(\(currentAnchor))")
        let anchor = currentAnchor
        completionHandler(anchor)
    }
}
