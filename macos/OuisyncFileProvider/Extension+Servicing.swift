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

//class OuisyncLibrarySender: OuisyncLibrarySenderProtocol {
//    let libraryClient: OuisyncFileProviderClientProtocol
//
//    init(_ libraryClient: OuisyncFileProviderClientProtocol) {
//        self.libraryClient = libraryClient
//    }
//
//    func sendDataToOuisyncLib(_ data: [UInt8]) {
//        libraryClient.messageFromServerToClient(data);
//    }
//}

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
    class OuisyncServiceSource: NSObject, NSFileProviderServiceSource, NSXPCListenerDelegate, FromAppToFileProviderProtocol {
        weak var weakExt: Extension?
        let listeners = NSHashTable<NSXPCListener>()


        init(_ ext: Extension) {
            self.weakExt = ext
        }

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

            connection.remoteObjectInterface = NSXPCInterface(with: FromFileProviderToAppProtocol.self)
            connection.exportedObject = self
            connection.exportedInterface = NSXPCInterface(with: FromAppToFileProviderProtocol.self)

            connection.interruptionHandler = {
                NSLog("😡 Connection to Ouisync XPC service has been interrupted")
            }

            connection.invalidationHandler = {
                NSLog("😡 Connection to Ouisync XPC service has been invalidated")
            }

            let client = connection.remoteObjectProxy() as? FromFileProviderToAppProtocol;

            guard let client = client else {
                NSLog("😡 Failed to convert XPC connection to OuisyncConnection")
                return true
            }

            guard let ext = weakExt else {
                NSLog("😡 The File Provider extension has received a connection from the app but the extension was already destroyed")
                return false
            }

            if ext.ouisyncSession != nil {
                // TODO: What shoudld we do if there is another app trying to connect? Right now Ouisync
                // runs inside the app, so that would mean we have two or more Ouisyncs running at the
                // same time. The app is set up in Flutter to only allow one instance, but whether that
                // actually works remains to be tested. If it happens that there are acually more than
                // one Ouisync instance, we might need to move the backend to the extension, but that
                // would require a lot of boilerplate to make it accessible from Dart.
                NSLog("😡 Session already exists")
                return false
            }

            //let ouisyncSession = OuisyncSession(OuisyncLibrarySender(client))
            //ext.assignSession(ouisyncSession)

            startListeningToRepoChanges()

            connection.resume()


            return true
        }

        // Ouisync backend is running inside the app (not in this extension), so when we send a request to it
        // here is where we receive responses and pass it to `ouisyncSession`.
        func fromAppToFileProvider(_ message_data: [UInt8]) {
            NSLog("------------------------- extension received \(message_data)")
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

        // Start watchin to changes in Ouisync: Everytime a repository is added or removed, and
        // everytime a repository changes we ask the file provider to refresh it's content.
        func startListeningToRepoChanges() {
            let weakExt = self.weakExt

            Task {
                let repoListChanged: NotificationStream

                if let session = weakExt?.ouisyncSession {
                    repoListChanged = try await session.subscribeToRepositoryListChange()
                } else {
                    return
                }

                var repoWatchingTasks: [RepositoryHandle: Task<Void, Never>] = [:]

                while true {
                    if let ext = weakExt {
                        let currentRepos: [OuisyncRepository]

                        do {
                            currentRepos = try await ext.ouisyncSession!.listRepositories()
                        } catch let error as OuisyncError {
                            switch error.code {
                            case .ConnectionLost: return
                            default: fatalError("😡 Unexpected Ouisync exception: \(error)")
                            }
                        } catch {
                            fatalError("😡 Unexpected exception: \(error)")
                        }

                        let watchedRepoHandles = Set(repoWatchingTasks.keys)
                        let currentRepoHandles = Set(currentRepos.map({ $0.handle }))

                        let reposToAdd = currentRepoHandles.subtracting(watchedRepoHandles)
                        let reposToRemove = watchedRepoHandles.subtracting(currentRepoHandles)

                        for repo in reposToAdd {
                            guard let ext = weakExt else {
                                return
                            }
                            guard let stream = try? await ext.ouisyncSession!.subscribeToRepositoryChange(repo) else {
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

                    } else {
                        NSLog("❗Stopping the refresh of repo changes because the extension was destroyed")
                        return
                    }

                    if await repoListChanged.next() == nil {
                        break
                    }
                }
            }
        }
    }


    // This signals to the file provider to refresh
    // https://developer.apple.com/documentation/fileprovider/replicated_file_provider_extension/synchronizing_files_using_file_provider_extensions#4099755
    static func refreshFileProvider(_ ext: Extension) async {
        let oldAnchor = ext.currentAnchor
        ext.currentAnchor = NSFileProviderSyncAnchor.random()
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
