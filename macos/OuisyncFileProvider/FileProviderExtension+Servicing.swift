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

public let ouisyncServiceName = NSFileProviderServiceName("org.equalitie.Ouisync")

@objc public protocol OuisyncServiceV1 {
    func test()
}

extension FileProviderExtension {
    class OuisyncServiceSource: NSObject, NSFileProviderServiceSource, NSXPCListenerDelegate, OuisyncServiceV1 {
        var serviceName: NSFileProviderServiceName {
            ouisyncServiceName
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
            //newConnection.exportedInterface = ouisyncServiceInterface
            newConnection.exportedObject = self
            newConnection.exportedInterface = NSXPCInterface(with: OuisyncServiceV1.self)

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
        
        func test() {
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
        }
    }
}

//extension DomainService.ConflictVersion {
//    init(_ data: Data) throws {
//        self = try JSONDecoder().decode(DomainService.ConflictVersion.self, from: data)
//    }
//}

public func synchronized<T>(_ lock: AnyObject, _ closure: () throws -> T) rethrows -> T {
  objc_sync_enter(lock)
  defer { objc_sync_exit(lock) }
  return try closure()
}
