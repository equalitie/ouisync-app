//
//  FileProviderExtension+Servicing.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 25/03/2024.
//
// TODO(obsolete): app<->extension XPC backend tunnel no longer used in the new client/service
// architecture; needs an architectural decision (likely removal, coordinated with
// macos/Runner/FileProviderProxy.swift).
//
// In the OLD architecture the extension embedded the Rust core in-process and let the app tunnel
// raw protocol bytes through XPC (`ouisyncSession.connectNewClient()` + `OuisyncClient`). In the
// NEW architecture the app connects to the shared out-of-process service directly, so this bridge
// is obsolete. The XPC listener scaffolding below is kept so the code compiles and the service
// source still vends a (no-op) proxy, but the ouisync-client tunneling has been stubbed out.
import FileProvider
import Foundation
import OuisyncCommon
import OuisyncLib


extension Extension: NSFileProviderServicing {
    public func supportedServiceSources(for itemIdentifier: NSFileProviderItemIdentifier,
                                        completionHandler: @escaping ([NSFileProviderServiceSource]?, Error?) -> Void) -> Foundation.Progress {
        completionHandler([OuisyncServiceSource(self)], nil)
        let progress = Foundation.Progress()
        progress.cancellationHandler = { completionHandler(nil, NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError)) }
        return progress
    }
}

// TODO(obsolete): stub. Previously forwarded raw ouisync protocol bytes between the app and the
// in-process backend via `OuisyncClient`. That tunnel no longer exists in the new architecture.
class AppToBackendProxy: FromAppToFileProviderProtocol {
    let connectionToApp: NSXPCConnection
    let sendToApp: FromFileProviderToAppProtocol

    init(_ connectionToApp: NSXPCConnection, _ sendToApp: FromFileProviderToAppProtocol) {
        self.connectionToApp = connectionToApp
        self.sendToApp = sendToApp
    }

    func fromAppToFileProvider(_ message_data: [UInt8]) {
        // TODO(obsolete): no ouisync backend tunnel in the new client/service architecture; drop it.
        NSLog("⚠️ Ignoring app→fileProvider message; the XPC backend tunnel is obsolete")
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

            // TODO(obsolete): previously created a new ouisync client tunnel here
            // (`ext.ouisyncSession.connectNewClient()`). That path no longer exists in the new
            // architecture; we accept the connection and export a no-op proxy instead.

            // this is a bit awkward because to avoid a reference leak, we have to atomically add
            // our invalidation closure iff the base extension has not been shut down yet, but we
            // also don't want to lift the rest of this function into the synchronized block,
            // thus resulting in two checks against the same value
            let active = synchronized(ext) {
                if ext.active {
                    ext.invalidators.append {
                        connection.invalidate() // this should notify peer; invalidationHandler cleans up proxies
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

            let proxy = AppToBackendProxy(connection, sendToApp)

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
