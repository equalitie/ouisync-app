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
        var client: OuisyncFileProviderClientProtocol?
        var nextMessageId: MessageId = 0

        var serviceName: NSFileProviderServiceName {
            ouisyncFileProviderServiceName
        }

        func generateMessageId() -> MessageId {
            let messageId = nextMessageId
            nextMessageId += 1
            return messageId
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

            client = connection.remoteObjectProxy() as? OuisyncFileProviderClientProtocol;

            synchronized(self) {
                listeners.remove(listener)
            }

            connection.resume()

            client!.messageFromServerToClient(listRepositories(generateMessageId()));
            client!.messageFromServerToClient(subscribeToRepositoryListChange(generateMessageId()));
            return true
        }

        weak var ext: FileProviderExtension?
        let listeners = NSHashTable<NSXPCListener>()

        init(_ ext: FileProviderExtension) {
            self.ext = ext
        }

        func messageFromClientToServer(_ message: [UInt8]) {
            if message.isEmpty {
                return
            }
            guard let client = self.client else {
                return
            }

            let response = parseResponse(message)

            NSLog(":::: ============ Response from rust")
            NSLog(":::: ======== \(message)")
            NSLog(":::: ======== \(response as Response?)")

            if let payload = response?.payload {
                if case ResponsePayload.notification(_) = payload {
                    client.messageFromServerToClient(listRepositories(generateMessageId()));
                }
            }
        }
    }
}

public func synchronized<T>(_ lock: AnyObject, _ closure: () throws -> T) rethrows -> T {
    objc_sync_enter(lock)
    defer { objc_sync_exit(lock) }
    return try closure()
}
