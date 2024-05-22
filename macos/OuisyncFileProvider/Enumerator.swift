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
    private let item: NSFileProviderItem
    private let anchor = NSFileProviderSyncAnchor("an anchor".data(using: .utf8)!)
    private let state: State

    init(_ itemIdentifier: ItemIdentifier, _ session: OuisyncSession, _ state: State) throws {
        Self.log("init(\(itemIdentifier), ...)")
        self.item = try itemFromIdentifier(itemIdentifier, session, state)
        self.session = session
        self.state = state
        super.init()
    }

    func invalidate() {
        Self.log("invalidate(\(item),...)")
        // TODO: perform invalidation of server connection if necessary
    }

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
        Self.log("enumerateItems(\(item))")
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
        switch item {
        case is RootContainerItem:
            Task {
                let reposByName = try await listRepositories()
                self.state.reposByName = reposByName
                observer.didEnumerate(reposToItems(reposByName))
                observer.finishEnumerating(upTo: nil)
            }
        case let dir as DirectoryItem:
            Task {
                let entries = try await dir.directory.listEntries()
                observer.didEnumerate(entries.map({ e in itemFromEntry(e, dir.repoName) }))
                observer.finishEnumerating(upTo: nil)
            }
        case is TrashContainerItem:
            observer.finishEnumerating(upTo: nil)
        case is WorkingSetItem:
            observer.finishEnumerating(upTo: nil)
        default: fatalError("Invalid item in `enumerateItems`: \(item)")
        }
    }
    
    func enumerateChanges(for observer: NSFileProviderChangeObserver, from anchor: NSFileProviderSyncAnchor) {
        Self.log("enumerateChanges(\(item))")
        /* TODO:
         - query the server for updates since the passed-in sync anchor
         
         If this is an enumerator for the active set:
         - note the changes in your local database
         
         - inform the observer about item deletions and updates (modifications + insertions)
         - inform the observer when you have finished enumerating up to a subsequent sync anchor
         */
        switch item {
        case is RootContainerItem:
            Task {
                let new_repos = try await listRepositories()
                var deleted: [NSFileProviderItemIdentifier] = [];

                for (repoName, repo) in self.state.reposByName {
                    if new_repos[repoName] == nil {
                        deleted.append(itemFromRepo(repo, repoName).itemIdentifier)
                    }
                }

                if !deleted.isEmpty {
                    observer.didDeleteItems(withIdentifiers: deleted)
                }

                observer.didUpdate(reposToItems(new_repos))

                self.state.reposByName = new_repos

                observer.finishEnumeratingChanges(upTo: anchor, moreComing: false)
            }
        case is DirectoryItem:
            Task {
                observer.finishEnumeratingChanges(upTo: anchor, moreComing: false)
            }
        case is TrashContainerItem:
            observer.finishEnumeratingChanges(upTo: anchor, moreComing: false)
        case is WorkingSetItem:
            observer.finishEnumeratingChanges(upTo: anchor, moreComing: false)
        default:
            fatalError("Invalid item in `enumerateChanges`")
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
        Self.log("currentSyncAnchor")
        completionHandler(anchor)
    }

    static func log(_ str: String) {
        NSLog(">>>> FileProviderEnumerator: \(str)")
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
        NSLog("NoConnectionEnumerator.currentSyncAnchor(...)")
        let anchor = NSFileProviderSyncAnchor("an anchor".data(using: .utf8)!)
        completionHandler(anchor)
    }
}
