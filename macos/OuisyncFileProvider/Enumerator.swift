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
    private let currentAnchor: Anchor
    private let log: Log

    init(_ itemIdentifier: ItemIdentifier, _ session: OuisyncSession, _ currentAnchor: Anchor, _ log: Log) {
        let log = log.child("Enumerator").trace("init(\(itemIdentifier), currentAnchor(\(currentAnchor)), ...)")
        self.itemId = itemIdentifier
        self.session = session
        self.currentAnchor = currentAnchor
        self.log = log

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
        switch itemId {
        case .rootContainer, .workingSet:
            Task {
                do {
                    let reposByName = try await listRepositories()
                    let items = reposToItems(reposByName)
                    log.trace("\(itemId) -> \(items.map({ $0.itemIdentifier }))")
                    observer.didEnumerate(items)
                    observer.finishEnumerating(upTo: nil)
                } catch {
                    fatalError("Unhandled exception \(error)")
                }
            }
        case .entry(.directory(let identifier)):
            Task {
                do {
                    let dir = try await identifier.loadItem(session)
                    let entries = try await dir.directory.listEntries()
                    var items: [NSFileProviderItem] = []
                    for entry in entries {
                        switch entry {
                        case .directory(let dirEntry): items.append(DirectoryItem(dirEntry, dir.repoName))
                        case .file(let fileEntry):
                            let identifier = FileIdentifier(fileEntry.path, dir.repoName)
                            items.append(try await identifier.loadItem(session))
                        }
                    }
                    log.trace("\(itemId) -> \(items.map({ $0.itemIdentifier }))")
                    observer.didEnumerate(items)
                    observer.finishEnumerating(upTo: nil)
                } catch {
                    fatalError("Unhandled exception for \(identifier): \(error)")
                }
            }
        case .trashContainer:
            observer.finishEnumerating(upTo: nil)
        default: fatalError("Invalid item in `enumerateItems`: \(itemId)")
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
        
        if oldAnchor.asInteger() == currentAnchor {
            observer.finishEnumeratingChanges(upTo: NSFileProviderSyncAnchor(currentAnchor), moreComing: false)
        } else {
            // We don't know what has changed because we don't track the current state and neither does
            // the Ouisync backend. So we return `synchAnchorExpired` error which will force the system
            // to re-enumerate the items (by calling the `enumerateItems` function.
            // https://developer.apple.com/documentation/fileprovider/replicated_file_provider_extension/synchronizing_files_using_file_provider_extensions#40997540
            observer.finishEnumeratingWithError(ExtError.syncAnchorExpired)
        }
    }

    func reposToItems(_ repos: Dictionary<RepoName, OuisyncRepository>)  -> [NSFileProviderItem] {
        var items: [NSFileProviderItem] = []
        for (repoName, repo) in repos {
            items.append(itemFromRepo(repo, repoName))
        }
        return items
    }

    func currentSyncAnchor(completionHandler: @escaping (NSFileProviderSyncAnchor?) -> Void) {
        log.trace("currentSyncAnchor(item:\(itemId)) -> Anchor(\(currentAnchor))")
        completionHandler(NSFileProviderSyncAnchor(currentAnchor))
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
    let currentAnchor: Anchor

    init(_ currentAnchor: Anchor) {
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
        let anchor = NSFileProviderSyncAnchor(currentAnchor)
        completionHandler(anchor)
    }
}
