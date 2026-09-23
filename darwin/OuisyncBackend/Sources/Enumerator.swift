//
//  FileProviderEnumerator.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 15/03/2024.
//
import FileProvider
import OuisyncCommon
import OuisyncLib


class Enumerator: NSObject, NSFileProviderEnumerator {
    // The session is now created asynchronously (the service runs out of process), so instead of
    // holding a session we hold an async provider that resolves it on demand.
    private let getSession: () async throws -> Session
    private let itemId: ItemIdentifier
    private let currentAnchor: NSFileProviderSyncAnchor
    private let log: Log
    private let pastEnumerations: PastEnumerations?

    init(_ itemIdentifier: ItemIdentifier, _ getSession: @escaping () async throws -> Session, _ currentAnchor: NSFileProviderSyncAnchor, _ log: Log, _ pastEnumerations: PastEnumerations?) {
        let log = log.child("Enumerator").trace("init(\(itemIdentifier), currentAnchor(\(currentAnchor)), ...)")
        self.itemId = itemIdentifier
        self.getSession = getSession
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
                let session = try await getSession()
                let items = try await enumerateImpl(session, itemId)
                log.trace("  ↳ \(items.map{ $0.providerItem() })")
                if !items.isEmpty {
                    observer.didEnumerate(items.map{ $0.providerItem() })
                }
                if let pastEnumerations = self.pastEnumerations {
                    pastEnumerations.setFor(itemId, Dictionary(uniqueKeysWithValues: items.map { ($0.id(), $0) }))
                }
                observer.finishEnumerating(upTo: nil)
            } catch {
                fatalError("Unhandled exception \(error)")
            }
        }
    }
    
    func enumerateChanges(for observer: NSFileProviderChangeObserver, from oldAnchor: NSFileProviderSyncAnchor) {
        let log = log.trace("enumerateChanges(oldAnchor: \(oldAnchor)) { item:\(itemId), currentAnchor:\(currentAnchor) }")
        /* TODO:
         - query the server for updates since the passed-in sync anchor
         
         If this is an enumerator for the active set:
         - note the changes in your local database
         
         - inform the observer about item deletions and updates (modifications + insertions)
         - inform the observer when you have finished enumerating up to a subsequent sync anchor
         */
        
        let finishEnumeratingWithError = { (error: NSError, line: Int) in
            if self.pastEnumerations == nil {
                // This is a valid error to tell the system that anchor has expired, the system
                // still prints out an error in the log so no need to clutter the log with our
                // message as well.
                if error.code != ExtError.syncAnchorExpired.code {
                    log.trace("\(error) L\(line)")
                }
            } else {
                log.trace("\(error) L\(line)")
            }
            observer.finishEnumeratingWithError(error)
        }

        if oldAnchor == currentAnchor {
            observer.finishEnumeratingChanges(upTo: currentAnchor, moreComing: false)
        } else {
            guard let pastEnumerations = pastEnumerations?.enumerations else {
                // We don't know what has changed because we don't track the current state and neither does
                // the Ouisync backend. So we return `synchAnchorExpired` error which will force the system
                // to re-enumerate the items (by calling the `enumerateItems` function.
                // https://developer.apple.com/documentation/fileprovider/replicated_file_provider_extension/synchronizing_files_using_file_provider_extensions#40997540
                finishEnumeratingWithError(ExtError.syncAnchorExpired, #line)
                return
            }

            guard let previousItems = pastEnumerations[itemId] else {
                finishEnumeratingWithError(ExtError.syncAnchorExpired, #line)
                return
            }

            Task {
                do {
                    let session = try await getSession()
                    let currentItems = try await enumerateImpl(session, itemId)

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

    private func enumerateImpl(_ session: Session, _ itemId: ItemIdentifier, recursive: Bool = false) async throws -> [EntryItem] {
        var retItems: [EntryItem]

        switch itemId {
        case .workingSet:
            retItems = try await enumerateImpl(session, .rootContainer, recursive: true)
        case .rootContainer:
            retItems = try await enumerateRootImpl(session)
        case .entry(.directory(let identifier)):
            retItems = try await enumerateDirImpl(session, identifier)
        case .trashContainer:
            retItems = []
        default: fatalError("Invalid item in `enumerateItems`: \(itemId)")
        }

        if recursive {
            let copy = retItems
            for item in copy {
                if case let .directory(dirItem) = item {
                    retItems += try await enumerateImpl(session, dirItem.directoryIdentifier().item())
                }
            }
        }

        return retItems
    }

    private func enumerateRootImpl(_ session: Session) async throws -> [EntryItem] {
        do {
            let reposByName = try await listRepositories(session)
            var items: [DirectoryItem] = []
            for (repoName, repo) in reposByName {
                do {
                    let dirItem = try await DirectoryItem.load(repo, repoName)
                    items.append(dirItem)
                } catch let error as OuisyncError where error.code == .permissionDenied {
                    log.error("Failed to load repo \(repoName), might be it has not yet been unlocked")
                    continue
                }
            }
            return items.map { .directory($0) }
        } catch {
            fatalError("Unhandled exception \(error)")
        }
    }

    private func enumerateDirImpl(_ session: Session, _ dirItemId: DirectoryIdentifier) async throws -> [EntryItem] {
        do {
            let repo = try await dirItemId.loadRepo(session)
            let entries = try await repo.readDirectory(dirItemId.path.string)
            var items: [EntryItem] = []
            for entry in entries {
                let childPath = dirItemId.path.appending(entry.name)
                switch entry.entryType {
                case .directory:
                    let dirItem = try await DirectoryItem.load(repo, childPath, dirItemId.repoName)
                    items.append(.directory(dirItem))
                case .file:
                    let identifier = FileIdentifier(childPath, dirItemId.repoName)
                    items.append(.file(try await identifier.loadItem(repo)))
                }
            }
            return items
        } catch let error as OuisyncError where error.code == .permissionDenied {
            log.error("Can't open directory dirItemId: \(error)")
            return [];
        } catch {
            fatalError("Unhandled exception for \(dirItemId): \(error)")
        }
    }

    func reposToIdentifiers(_ repos: Dictionary<RepoName, Repository>) -> Set<DirectoryIdentifier> {
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

    func listRepositories(_ session: Session) async throws -> Dictionary<RepoName, Repository> {
        // The new API already returns repositories keyed by name.
        return try await session.listRepositories()
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
