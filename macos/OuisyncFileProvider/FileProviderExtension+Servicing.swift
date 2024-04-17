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

extension FileProviderExtension: NSFileProviderServicing {
    public func supportedServiceSources(for itemIdentifier: NSFileProviderItemIdentifier,
                                        completionHandler: @escaping ([NSFileProviderServiceSource]?, Error?) -> Void) -> Progress {
        completionHandler([OuisyncServiceSource(self)], nil)
        let progress = Progress()
        progress.cancellationHandler = { completionHandler(nil, NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError)) }
        return progress
    }
}

extension FileProviderExtension {
    class OuisyncServiceSource: NSObject, NSFileProviderServiceSource, NSXPCListenerDelegate, OuisyncFileProviderServerProtocol {
        var nextMessageId: MessageId = 0

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
            NSLog(":::: START")

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
                NSLog(":::: 😡 Failed to convert XPC connection to OuisyncConnection")
                return false
            }

            // TODO: This was used in an example, but maybe we dont need to do that?
            synchronized(self) {
                listeners.remove(listener)
            }

            let ouisyncSession = OuisyncSession(OuisyncLibrarySender(client))

            if let ext = self.ext {
                ext.ouisyncSession = ouisyncSession
            }

            connection.resume()

            Task {
                let repoListChanged = try await ouisyncSession.subscribeToRepositoryListChange()
                let _ = try await ouisyncSession.listRepositories()
                while true {
                    if await repoListChanged.next() == nil {
                        break
                    }
                    let repos = try await ouisyncSession.listRepositories()

                    for repo in repos {
                        let entries = try await repo.getRootDirectory().listEntries()
                        NSLog(">>>> \(entries)")
                    }
                    await refreshFileProvider()
                }
            }

            return true
        }

        weak var ext: FileProviderExtension?
        let listeners = NSHashTable<NSXPCListener>()

        init(_ ext: FileProviderExtension) {
            self.ext = ext
        }

        func messageFromClientToServer(_ message_data: [UInt8]) {
            if message_data.isEmpty {
                return
            }

            guard let ext = self.ext else {
                return
            }

            guard let ouisyncSession = ext.ouisyncSession else {
                return
            }

            ouisyncSession.onReceiveDataFromOuisyncLib(message_data)
        }
    }

    // This signals to the file provider to refresh
    static func refreshFileProvider() async {
        let managerDomain = getDomain()
        guard let manager = NSFileProviderManager(for: managerDomain) else {
            NSLog("❌ failed to create NSFileProviderManager for \(managerDomain)")
            return
        }
        do {
            try await manager.signalEnumerator(for: .workingSet)
        } catch let error as NSError {
            NSLog("❌ failed to signal working set for \(managerDomain): \(error)")
        }
    }
}

public func synchronized<T>(_ lock: AnyObject, _ closure: () throws -> T) rethrows -> T {
    objc_sync_enter(lock)
    defer { objc_sync_exit(lock) }
    return try closure()
}
