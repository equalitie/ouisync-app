//
//  FileProviderExtension+Servicing.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 25/03/2024.
//

import Common
import Foundation
import FileProvider

extension FileProviderExtension: NSFileProviderServicing {
    public func supportedServiceSources(for itemIdentifier: NSFileProviderItemIdentifier,
                                        completionHandler: @escaping ([NSFileProviderServiceSource]?, Error?) -> Void) -> Progress {
        NSLog("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
        completionHandler([OuisyncServiceSource(self)], nil)
        let progress = Progress()
        progress.cancellationHandler = { completionHandler(nil, NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError)) }
        return progress
    }
}

extension FileProviderExtension {
    class OuisyncServiceSource: NSObject, NSFileProviderServiceSource, NSXPCListenerDelegate, OuisyncFileProviderServerProtocol {
        var client: OuisyncFileProviderClientProtocol?

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

        func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
            newConnection.remoteObjectInterface = NSXPCInterface(with: OuisyncFileProviderClientProtocol.self)
            newConnection.exportedObject = self
            newConnection.exportedInterface = NSXPCInterface(with: OuisyncFileProviderServerProtocol.self)

            client = newConnection.remoteObjectProxy() as? OuisyncFileProviderClientProtocol;

            synchronized(self) {
                listeners.remove(listener)
            }

            newConnection.resume()
            return true
        }

        weak var ext: FileProviderExtension?
        let listeners = NSHashTable<NSXPCListener>()

        init(_ ext: FileProviderExtension) {
            self.ext = ext
        }
        
        var i: Int = 1;
        
        func requestForServer(_ request: [UInt8], _ respond: ([UInt8]) -> Void) {
            NSLog("=============================================================================")
            NSLog("=============================================================================")
            NSLog("=============================================================================")
            NSLog("=============================================================================")
            NSLog("=============================================================================")
            NSLog("=============================================================================")
            NSLog("=============================================================================")
            NSLog("=============================================================================")
            NSLog("=========================       IT WORKS!!!      ============================")
            NSLog("=============================================================================")
            NSLog("=============================================================================")
            NSLog("=============================================================================")
            NSLog("=============================================================================")
            NSLog("=============================================================================")
            NSLog("=============================================================================")
            NSLog("=============================================================================")
            NSLog("=============================================================================")
            respond(request)
            i += 1;
        }
    }
}

public func synchronized<T>(_ lock: AnyObject, _ closure: () throws -> T) rethrows -> T {
  objc_sync_enter(lock)
  defer { objc_sync_exit(lock) }
  return try closure()
}
