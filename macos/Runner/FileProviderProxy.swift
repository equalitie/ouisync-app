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
            let ffi = FFI()

            let (fromRustRx, fromRustTx) = makeStream();

            // Compiler complains that `fromRustTx` is not a "class" when I try to get a raw pointer out of it.
            let wrapFromRustTx = Wrap(fromRustTx)

            let callback: FFICallback = { context, dataPointer, size in
                let fromRustTx: Wrap<Tx> = fromPointer(context!)
                let data = Array(UnsafeBufferPointer(start: dataPointer, count: Int(exactly: size)!))
                fromRustTx.inner.yield(data)
            }

            let session = try await ffi.waitForSession(toPointer(wrapFromRustTx), callback)

            let manager = NSFileProviderManager(for: domain)!
            let service = try await manager.service(named: ouisyncFileProviderServiceName, for: NSFileProviderItemIdentifier.rootContainer)

            guard let service = service else {
                return;
            }

            let connection = try await service.fileProviderConnection()
            connection.remoteObjectInterface = NSXPCInterface(with: OuisyncFileProviderServerProtocol.self)

            connection.interruptionHandler = {
                NSLog("😡 Connection to File Provider XPC service has been interrupted")
                fromRustTx.finish();
            }

            connection.invalidationHandler = {
                NSLog("😡 Connection to File Provider XPC service has been invalidated")
                fromRustTx.finish();
            }

            let server = connection.remoteObjectProxy() as! OuisyncFileProviderServerProtocol;

            @Sendable
            func fromRustToServer() async {
                for await message in fromRustRx {
                    server.messageFromClientToServer(message)
                }
            }

            class FromServerToRust : OuisyncFileProviderClientProtocol {
                let ffi: FFI
                let session: SessionHandle
                init(_ ffi: FFI, _ session: SessionHandle) {
                    self.ffi = ffi
                    self.session = session
                }
                func messageFromServerToClient(_ message: [UInt8]) {
                    ffi.channelSend(session, message)
                }
            }

            connection.exportedObject = FromServerToRust(ffi, session)
            connection.exportedInterface = NSXPCInterface(with: OuisyncFileProviderClientProtocol.self)

            connection.resume();

            // For some reason the communication wont start unless we send this first message
            server.messageFromClientToServer([])

            await fromRustToServer();

            ffi.releaseSession(session)
        }
    }


}

// ---------------------------------------------------------------------------------------

typealias Rx = AsyncStream<[UInt8]>
typealias Tx = AsyncStream<[UInt8]>.Continuation

class Wrap<T> {
    let inner: T
    init(_ inner: T) { self.inner = inner }
}

class Channel {
    let rx: Rx
    let tx: Tx

    init(_ rx: Rx, _ tx: Tx) { self.rx = rx; self.tx = tx }
}

func makeStream() -> (Rx, Tx) {
    var continuation: AsyncStream<[UInt8]>.Continuation!
    let stream = AsyncStream<[UInt8]>() { continuation = $0 }
    return (stream, continuation!)
}

// ---------------------------------------------------------------------------------------
// https://stackoverflow.com/questions/68972755/how-to-cast-back-correctly-a-pointer-swift-native

func toPointer<T : AnyObject>(_ obj : T) -> UnsafeRawPointer {
    return UnsafeRawPointer(Unmanaged.passUnretained(obj).toOpaque())
}

func fromPointer<T : AnyObject>(_ ptr : UnsafeRawPointer) -> T {
    return unsafeBitCast(ptr, to: T.self)
}

// ---------------------------------------------------------------------------------------

typealias FFICallback = @convention(c) (UnsafeRawPointer?, UnsafePointer<UInt8>, CUnsignedLongLong) -> Void;
typealias FFISessionGrab = @convention(c) (UnsafeRawPointer?, FFICallback) -> SessionCreateResult;
typealias FFISessionRelease = @convention(c) (SessionHandle) -> Void;
typealias FFISessionChannelSend = @convention(c) (SessionHandle, UnsafeRawPointer, UInt64) -> Void;

class FFI {
    let handle: UnsafeMutableRawPointer
    let ffiSessionGrab: FFISessionGrab
    let ffiSessionChannelSend: FFISessionChannelSend
    let ffiSessionRelease: FFISessionRelease

    init() {
        handle = dlopen("libouisync_ffi.dylib", RTLD_NOW)!
        ffiSessionGrab = unsafeBitCast(dlsym(handle, "session_grab"), to: FFISessionGrab.self)
        ffiSessionChannelSend = unsafeBitCast(dlsym(handle, "session_channel_send"), to: FFISessionChannelSend.self)
        ffiSessionRelease = unsafeBitCast(dlsym(handle, "session_release"), to: FFISessionRelease.self)
    }

    // Blocks until Dart creates a session, then returns it.
    func waitForSession(_ context: UnsafeRawPointer, _ callback: FFICallback) async throws -> SessionHandle {
        // TODO: Might be worth change the ffi function to call a callback when the session becomes created instead of bussy sleeping.
        var elapsed: UInt64 = 0;
        while true {
            let result = ffiSessionGrab(context, callback)
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

    func channelSend(_ session: SessionHandle, _ data: [UInt8]) {
        let count = data.count;
        data.withUnsafeBufferPointer({ maybePointer in
            if let pointer = maybePointer.baseAddress {
                ffiSessionChannelSend(session, pointer, UInt64(count))
            }
        })
    }

    func releaseSession(_ session: SessionHandle) {
        ffiSessionRelease(session)
    }
}
