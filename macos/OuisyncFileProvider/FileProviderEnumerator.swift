//
//  FileProviderEnumerator.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 15/03/2024.
//

import FileProvider
import OuisyncLib

class FileProviderEnumerator: NSObject, NSFileProviderEnumerator {
    private let connection: OuisyncSession?
    private let item: ItemEnum
    private let anchor = NSFileProviderSyncAnchor("an anchor".data(using: .utf8)!)
    private let state: State

    init(enumeratedItemIdentifier: NSFileProviderItemIdentifier, _ connection: OuisyncSession?, _ state: State) {
        self.item = ItemEnum(enumeratedItemIdentifier)
        self.connection = connection
        self.state = state
        Self.log("init \(item)")
        super.init()
    }

    func invalidate() {
        Self.log("invalidate \(item)")
        // TODO: perform invalidation of server connection if necessary
    }

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
        Self.log("enumerateItems(\(item)")
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
        guard let connection = self.connection else {
            observer.finishEnumerating(upTo: nil)
            return
        }

        switch item {
        case .repositoryList:
            Task {
                let repos = Set(try await connection.listRepositories());
                self.state.items = repos
                let items = await reposToItems(repos)
                observer.didEnumerate(Array(items))
                observer.finishEnumerating(upTo: nil)
            }
        case .entry(let entry):
            let repo = OuisyncRepository(entry.repositoryHandle(), connection)
            let dir = OuisyncDirectory(entry.path(), repo)

            Task {
                let entries = try await dir.listEntries()
                for entry in entries {
                    let item = FileProviderItem(entry)
                    NSLog("entry: \(entry) \(item.itemIdentifier.rawValue) \(item.parentItemIdentifier.rawValue)")
                }
                observer.didEnumerate(entries.map(FileProviderItem.init))
                observer.finishEnumerating(upTo: nil)
            }
        case .trash:
            observer.finishEnumerating(upTo: nil)
        case .workingSet:
            observer.finishEnumerating(upTo: nil)
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
        guard let connection = self.connection else {
            let error = NSError(domain: NSFileProviderErrorDomain, code: NSFileProviderError.serverUnreachable.rawValue, userInfo: nil)
            observer.finishEnumeratingWithError(error)
            return
        }

        switch item {
        case .repositoryList:
            Task {
                let new_repos = Set(try await connection.listRepositories())
                let old_repos = self.state.items
                let deleted = old_repos.subtracting(new_repos)

                if !deleted.isEmpty {
                    let deletedIdentifiers = reposToItemIdentifiers(deleted)
                    observer.didDeleteItems(withIdentifiers: Array(deletedIdentifiers))
                }

                observer.didUpdate(Array(await reposToItems(new_repos)))

                self.state.items = new_repos

                observer.finishEnumeratingChanges(upTo: anchor, moreComing: false)
            }
        case .entry(let entry):
            Task {
                observer.finishEnumeratingChanges(upTo: anchor, moreComing: false)
            }
        case .trash:
            observer.finishEnumeratingChanges(upTo: anchor, moreComing: false)
        case .workingSet:
            observer.finishEnumeratingChanges(upTo: anchor, moreComing: false)
        }
    }

    func reposToItems(_ repos: Set<OuisyncRepository>) async -> Set<FileProviderItem> {
        var items = Set<FileProviderItem>()
        for repo in repos {
            let item = (try? await FileProviderItem.fromOuisyncRepository(repo))!
            items.insert(item)
        }
        return items
    }

    func reposToItemIdentifiers(_ repos: Set<OuisyncRepository>) -> Set<NSFileProviderItemIdentifier> {
        var items = Set<NSFileProviderItemIdentifier>()
        for repo in repos {
            items.insert(ItemEnum(Entry(repo)).identifier())
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
}
