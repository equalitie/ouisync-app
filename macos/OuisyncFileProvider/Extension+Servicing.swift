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

            // TODO: Send notifications to the app/flutter
            guard let client = client else {
                NSLog("😡 Failed to convert XPC connection to OuisyncConnection")
                return true
            }

            guard let ext = weakExt else {
                NSLog("😡 The File Provider extension has received a connection from the app but the extension was already destroyed")
                return false
            }

            connection.resume()

            return true
        }

        // Ouisync backend is running inside the app (not in this extension), so when we send a request to it
        // here is where we receive responses and pass it to `ouisyncSession`.
        func fromAppToFileProvider(_ message_data: [UInt8]) async -> [UInt8] {
            if message_data.isEmpty {
                fatalError("FP Extension received an empty message from the App")
            }

            guard let ext = self.weakExt else {
                fatalError("FP Extension received a message but it has already been destroyed")
            }

            let request = OuisyncRequestMessage.deserialize(message_data)!
            let response = await ext.ouisyncSession.invoke(request)
            return response.serialize()
        }
    }
}

public func synchronized<T>(_ lock: AnyObject, _ closure: () throws -> T) rethrows -> T {
    objc_sync_enter(lock)
    defer { objc_sync_exit(lock) }
    return try closure()
}
