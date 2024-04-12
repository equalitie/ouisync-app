//
//  FileProviderEnumerator.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 15/03/2024.
//

import FileProvider

class FileProviderEnumerator: NSObject, NSFileProviderEnumerator {
    private let connection: OuisyncConnection?
    private let enumeratedItemIdentifier: NSFileProviderItemIdentifier
    private let anchor = NSFileProviderSyncAnchor("an anchor".data(using: .utf8)!)
    private let state: State

    init(enumeratedItemIdentifier: NSFileProviderItemIdentifier, _ connection: OuisyncConnection?, _ state: State) {
        Self.log("init")
        self.enumeratedItemIdentifier = enumeratedItemIdentifier
        self.connection = connection
        self.state = state
        super.init()
    }

    func invalidate() {
        Self.log("invalidate")
        // TODO: perform invalidation of server connection if necessary
    }

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
        Self.log("enumerateItems(\(observer), \(page)")
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
        if let connection = self.connection {
            Task {
                let repos = try await connection.listRepositories();
                self.state.items = Set(repos)
                for repo in repos {
                    observer.didEnumerate([FileProviderItem(Entry(repo))])
                }
                observer.finishEnumerating(upTo: nil)
            }
        } else {
            observer.finishEnumerating(upTo: nil)
        }
    }
    
    func enumerateChanges(for observer: NSFileProviderChangeObserver, from anchor: NSFileProviderSyncAnchor) {
        Self.log("enumerateChanges")
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

        Task {
            let new_repos = Set(try await connection.listRepositories())
            let old_repos = self.state.items
            NSLog("********************** old \(old_repos)")
            let deleted = old_repos.subtracting(new_repos)

            NSLog("********************** new \(new_repos)")
            NSLog("********************** deleted \(deleted)")
            if !deleted.isEmpty {
                observer.didDeleteItems(withIdentifiers: deleted.map({FileProviderItem(Entry($0)).itemIdentifier}))
            }

            //let kept = new_repos.subtracting(deleted)

            observer.didUpdate(new_repos.map {
                FileProviderItem(Entry($0))
            })

            self.state.items = new_repos
            NSLog("********************** new' \(new_repos)")

            observer.finishEnumeratingChanges(upTo: anchor, moreComing: false)
        }
    }

    func currentSyncAnchor(completionHandler: @escaping (NSFileProviderSyncAnchor?) -> Void) {
        Self.log("currentSyncAnchor")
        completionHandler(anchor)
    }

    static func log(_ str: String) {
        NSLog(">>>> FileProviderEnumerator: \(str)")
    }
}
