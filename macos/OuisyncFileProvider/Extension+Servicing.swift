//
//  FileProviderExtension+Servicing.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 25/03/2024.
//

import Common
import Foundation
import FileProvider
import OuisyncLib

class OuisyncLibrarySender: OuisyncLibrarySenderProtocol {
    let libraryClient: OuisyncFileProviderClientProtocol

    init(_ libraryClient: OuisyncFileProviderClientProtocol) {
        self.libraryClient = libraryClient
    }

    func sendDataToOuisyncLib(_ data: [UInt8]) {
        libraryClient.messageFromServerToClient(data);
    }
}

extension Extension: NSFileProviderServicing {
    public func supportedServiceSources(for itemIdentifier: NSFileProviderItemIdentifier,
                                        completionHandler: @escaping ([NSFileProviderServiceSource]?, Error?) -> Void) -> Progress {
        completionHandler([OuisyncServiceSource(self)], nil)
        let progress = Progress()
        progress.cancellationHandler = { completionHandler(nil, NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError)) }
        return progress
    }
}

extension Extension {
    class OuisyncServiceSource: NSObject, NSFileProviderServiceSource, NSXPCListenerDelegate, OuisyncFileProviderServerProtocol {
        var serviceName: NSFileProviderServiceName {
            ouisyncFileProviderServiceName
        }

        func makeListenerEndpoint() throws -> NSXPCListenerEndpoint {
            let listener = NSXPCListener.anonymous()
            listener.delegate = self
            synchronized(self) {
                listeners.add(listener)
            }
            listener.resume()
            return listener.endpoint
        }

        /// https://developer.apple.com/documentation/foundation/nsxpclistenerdelegate/1410381-listener
        func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
            NSLog(":::: Servicing START ::::")

            connection.remoteObjectInterface = NSXPCInterface(with: OuisyncFileProviderClientProtocol.self)
            connection.exportedObject = self
            connection.exportedInterface = NSXPCInterface(with: OuisyncFileProviderServerProtocol.self)

            connection.interruptionHandler = {
                NSLog("😡 Connection to Ouisync XPC service has been interrupted")
            }

            connection.invalidationHandler = {
                NSLog("😡 Connection to Ouisync XPC service has been invalidated")
            }

            let maybe_client = connection.remoteObjectProxy() as? OuisyncFileProviderClientProtocol;

            guard let client = maybe_client else {
                NSLog("😡 Failed to convert XPC connection to OuisyncConnection")
                return false
            }

            // TODO: This was used in an example, but maybe we dont need to do that?
//            synchronized(self) {
//                listeners.remove(listener)
//            }

            let ouisyncSession = OuisyncSession(OuisyncLibrarySender(client))

            let weakExt = self.weakExt

            if let ext = weakExt {
                ext.ouisyncSession = ouisyncSession
            }

            connection.resume()

            Task {
                // Everytime a repository is added or removed, and everytime a repository in the backend
                // changes we ask the file provider to refresh it's content.

                let repoListChanged = try await ouisyncSession.subscribeToRepositoryListChange()

                var repoWatchingTasks: [RepositoryHandle: Task<Void, Never>] = [:]

                while true {
                    if await repoListChanged.next() == nil {
                        break
                    }

                    guard let ext = weakExt else {
                        NSLog("❗Stopping the refresh of repo changes because the extension was destroyed")
                        return
                    }

                    let watchedRepoHandles = Set(repoWatchingTasks.keys)
                    let currentRepoHandles = Set((try? await ouisyncSession.listRepositories())!.map({ $0.handle }))

                    let reposToAdd = currentRepoHandles.subtracting(watchedRepoHandles)
                    let reposToRemove = watchedRepoHandles.subtracting(currentRepoHandles)

                    for repo in reposToAdd {
                        guard let stream = try? await ouisyncSession.subscribeToRepositoryChange(repo) else {
                            continue
                        }
                        repoWatchingTasks[repo] = Task {
                            while true {
                                if await stream.next() == nil {
                                    return
                                }
                                guard let ext = weakExt else {
                                    return
                                }
                                await refreshFileProvider(ext)
                            }
                        }
                    }

                    for repo in reposToRemove {
                        repoWatchingTasks.removeValue(forKey: repo)
                    }

                    await refreshFileProvider(ext)
                }
            }

            return true
        }

        weak var weakExt: Extension?
        let listeners = NSHashTable<NSXPCListener>()

        init(_ ext: Extension) {
            self.weakExt = ext
        }

        func messageFromClientToServer(_ message_data: [UInt8]) {
            if message_data.isEmpty {
                return
            }

            guard let ext = self.weakExt else {
                return
            }

            guard let ouisyncSession = ext.ouisyncSession else {
                return
            }

            ouisyncSession.onReceiveDataFromOuisyncLib(message_data)
        }
    }

    // This signals to the file provider to refresh
    // https://developer.apple.com/documentation/fileprovider/replicated_file_provider_extension/synchronizing_files_using_file_provider_extensions#4099755
    static func refreshFileProvider(_ ext: Extension) async {
        let oldAnchor = ext.currentAnchor
        ext.currentAnchor = UInt64.random(in: UInt64.min ... UInt64.max)
        NSLog("🚀 Refreshing FileProvider and updating anchor \(oldAnchor) -> \(ext.currentAnchor)")

        let domain = ouisyncFileProviderDomain

        guard let manager = NSFileProviderManager(for: domain) else {
            NSLog("❌ failed to create NSFileProviderManager for \(domain)")
            return
        }
        do {
            try await manager.signalEnumerator(for: .workingSet)
        } catch let error as NSError {
            NSLog("❌ failed to signal working set for \(domain): \(error)")
        }
    }
}

public func synchronized<T>(_ lock: AnyObject, _ closure: () throws -> T) rethrows -> T {
    objc_sync_enter(lock)
    defer { objc_sync_exit(lock) }
    return try closure()
}
