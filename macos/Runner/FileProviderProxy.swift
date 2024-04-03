//
//  FileProviderProxy.swift
//  Runner
//
//  Created by Peter Jankuliak on 03/04/2024.
//

import Foundation
import FileProvider
import Common

// Facilitate communication between the file provider extension and the rust code.
class FileProviderProxy {
    init() {
        let domain = getDomain()
        
        NSFileProviderManager.add(domain, completionHandler: {error in
            if let error = error {
                NSLog("😡 Error starting file provider for domain \(domain): \(String(describing: error))")
            } else {
                NSLog("😀 NSFileProviderManager added domain successfully");
            }
        })
        
        Task.detached {
            let ffi = FFI();
            
            let callback: FFICallback = { context, data, size in }
            let session = try await ffi.waitForSession(callback)
            
            let manager = NSFileProviderManager(for: domain)!
            let service = try await manager.service(named: ouisyncFileProviderServiceName, for: NSFileProviderItemIdentifier.rootContainer)

            guard let service = service else {
                return;
            }

            let requestHandler = RequestHandler();
            
            let connection = try await service.fileProviderConnection()
            connection.remoteObjectInterface = NSXPCInterface(with: OuisyncFileProviderServerProtocol.self)
            connection.exportedObject = requestHandler
            connection.exportedInterface = NSXPCInterface(with: OuisyncFileProviderClientProtocol.self)

            connection.interruptionHandler = {
                NSLog("😡 Connection to File Provider XPC service has been interrupted")
            }

            connection.invalidationHandler = {
                NSLog("😡 Connection to File Provider XPC service has been invalidated")
            }
            
            connection.resume();
            
            let server = connection.remoteObjectProxy() as! OuisyncFileProviderServerProtocol;
            while true {
                let request : [UInt8] = [1, 2, 3]
                server.requestForServer(request, {response in
                    NSLog("================================ \(response)")
                   })
                try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
            }
        }
    }
    
    func getDomain() -> NSFileProviderDomain {
        return NSFileProviderDomain(identifier: NSFileProviderDomainIdentifier(rawValue: "mydomain"), displayName: "mydisplayname")
    }
}

class RequestHandler : OuisyncFileProviderClientProtocol {
    func requestForClient(_ request: [UInt8], _ respond: ([UInt8]) -> Void) {
        
    }
}

typealias FFICallback = @convention(c) (UnsafeRawPointer?, UnsafePointer<CChar>, CUnsignedLongLong) -> Void;
typealias FFISessionGrabShared = @convention(c) (UnsafeRawPointer?, FFICallback) -> SessionCreateResult;

class FFI {
    let handle: UnsafeMutableRawPointer
    let ffiSessionGrabShared: FFISessionGrabShared
    
    init() {
        handle = dlopen("libouisync_ffi.dylib", RTLD_NOW)!
        ffiSessionGrabShared = unsafeBitCast(dlsym(handle, "session_grab_shared"), to: FFISessionGrabShared.self)
    }
    
    // Blocks until Dart creates a session, then returns it.
    func waitForSession(_ callback: FFICallback) async throws -> SessionHandle {
        // TODO: Might be worth change the ffi function to call a callback when the session becomes created instead of bussy sleeping.
        var elapsed: UInt64 = 0;
        while true {
            let result = ffiSessionGrabShared(nil, callback)
            if result.errorCode == 0 {
                NSLog("😀 Got Ouisync session");
                return result.session
            }
            NSLog("🤨 Ouisync session not yet ready. Code: \(result.errorCode) Message:\(String(cString: result.errorMessage!))");
            
            let millisecond: UInt64 = 1_000_000
            let second: UInt64 = 1000 * millisecond
            
            var timeout = 200 * millisecond
            
            if elapsed > 10 * second {
                timeout = second
            }
            
            try await Task.sleep(nanoseconds: timeout)
            elapsed += timeout;
        }
    }
}
