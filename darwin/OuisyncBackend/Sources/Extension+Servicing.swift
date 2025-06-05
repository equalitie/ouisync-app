//
//  FileProviderExtension+Servicing.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 25/03/2024.
//
import FileProvider
import Foundation
import OuisyncCommon
import OuisyncLib


extension Extension: NSFileProviderServicing {
    public func supportedServiceSources(for itemIdentifier: NSFileProviderItemIdentifier,
                                        completionHandler: @escaping ([NSFileProviderServiceSource]?, Error?) -> Void) -> Progress {
        completionHandler([OuisyncServiceSource(self)], nil)
        let progress = Progress()
        progress.cancellationHandler = { completionHandler(nil, NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError)) }
        return progress
    }
}

class AppToBackendProxy: FromAppToFileProviderProtocol {
    let connectionToApp: NSXPCConnection
    let sendToApp: FromFileProviderToAppProtocol
    let ouisyncClient: OuisyncClient

    init(_ connectionToApp: NSXPCConnection, _ sendToApp: FromFileProviderToAppProtocol, _ ouisyncClient: OuisyncClient) {
        self.connectionToApp = connectionToApp
        self.sendToApp = sendToApp
        self.ouisyncClient = ouisyncClient
        self.ouisyncClient.onReceiveFromBackend = { [weak self] message_data in
            self?.sendToApp.fromFileProviderToApp(message_data)
        }
    }

    func fromAppToFileProvider(_ message_data: [UInt8]) {
        ouisyncClient.sendToBackend(message_data)
    }
}

extension Extension {
    class OuisyncServiceSource: NSObject, NSFileProviderServiceSource, NSXPCListenerDelegate {
        weak var weakExt: Extension?
        let listeners = NSHashTable<NSXPCListener>()
        var proxies: [UInt64: AppToBackendProxy] = [:]
        var nextProxyId: UInt64 = 0

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

            let proxyId = generateProxyId()

            connection.interruptionHandler = { [weak self] in guard let self else { return }
                NSLog("😡 Connection to Ouisync XPC service has been interrupted")
                synchronized(self) {
                    _ = self.proxies.removeValue(forKey: proxyId)
                }
            }

            connection.invalidationHandler = { [weak self] in guard let self else { return }
                NSLog("😡 Connection to Ouisync XPC service has been invalidated")
                synchronized(self) {
                    _ = self.proxies.removeValue(forKey: proxyId)
                }
            }

            connection.remoteObjectInterface = NSXPCInterface(with: FromFileProviderToAppProtocol.self)
            let sendToApp = connection.remoteObjectProxy() as? FromFileProviderToAppProtocol;

            // TODO: Send notifications to the app/flutter
            guard let sendToApp = sendToApp else {
                NSLog("😡 Failed to convert XPC connection to OuisyncConnection")
                return false
            }

            guard let ext = weakExt else {
                NSLog("😡 The File Provider extension has received a connection from the app but the extension was already destroyed")
                return false
            }

            guard let ouisyncClient = try? ext.ouisyncSession.connectNewClient() else {
                NSLog("😡 Failed to create new ouisync client when accepting new connection from the app")
                return false
            }

            // this is a bit awkward because to avoid a reference leak, we have to atomically add
            // our invalidation closure iff the base extension has not been shut down yet, but we
            // also don't want to lift the rest of this function into the synchronized block,
            // thus resulting in two checks against the same value
            let active = synchronized(ext) {
                if ext.active {
                    ext.invalidators.append {
                        connection.invalidate() // this should notify peer; invalidationHandler cleans up proxies
                        await ouisyncClient.close()
                    }
                }
                return ext.active
            }
            guard active else {
                // presumably the OS is smart enough to not keep using this service provider bound
                // to an instance it has already invalidate()d but stranger things have happened
                NSLog("👋 The File Provider extension has received a connection from the app but is in the process of shutting down")
                return false
            }

            let proxy = AppToBackendProxy(connection, sendToApp, ouisyncClient)

            connection.exportedObject = proxy
            connection.exportedInterface = NSXPCInterface(with: FromAppToFileProviderProtocol.self)

            synchronized(self) {
                proxies[proxyId] = proxy
            }

            connection.resume()

            return true
        }

        func generateProxyId() -> UInt64 {
            synchronized(self) {
                let proxyId = nextProxyId
                nextProxyId += 1
                return proxyId
            }
        }
    }
}

public func synchronized<T>(_ lock: AnyObject, _ closure: () throws -> T) rethrows -> T {
    objc_sync_enter(lock)
    defer { objc_sync_exit(lock) }
    return try closure()
}
