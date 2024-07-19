//
//  FileProviderProxy.swift
//  Runner
//
//  Created by Peter Jankuliak on 03/04/2024.
//

import Foundation
import FileProvider
import Common
import FlutterMacOS
import OuisyncLib
import MessagePack

class FileProviderProxy2 {
    let flutterMethodChannel: FlutterMethodChannel

    init(_ flutterBinaryMessenger: FlutterBinaryMessenger) {
        flutterMethodChannel = FlutterMethodChannel(name: "org.equalitie.ouisync/backend", binaryMessenger: flutterBinaryMessenger)
        flutterMethodChannel.setMethodCallHandler(handleMessageFromFlutter)
    }

//    func invalidate() async throws {
//        try await NSFileProviderManager.remove(ouisyncFileProviderDomain)
//    }

    static func log(_ message: String) {
        NSLog(message)
    }

    private func handleMessageFromFlutter(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let flutterData = call.arguments as! FlutterStandardTypedData
        let data = Data(flutterData.data)
        // TODO: Get rid of this conversion
        let bytes = [UInt8](unsafeUninitializedCapacity: data.count) {
            pointer, copied_count in
            let length_written = data.copyBytes(to: pointer)
            copied_count = length_written
            assert(copied_count == data.count)
        }
        NSLog("ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ \(call.method) \(bytes)");
        switch call.method {
        case "initialize":
            let message = OutgoingMessage.deserialize(bytes)!
            Task {
                await initialize(message.messageId)
            }
        default:
            fatalError("Received an unrecognized message from Flutter: \(call.method)(\(call.arguments))")
        }
        result(nil)
    }

    private func initialize(_ requestMessageId: MessageId) async {
        let domain = ouisyncFileProviderDomain

        do {
            while true {
                do {
                    try await NSFileProviderManager.add(domain)
                    Self.log("😀 NSFileProviderManager added domain successfully")
                    break
                } catch {
                    Self.log("😡 Error starting file provider for domain \(domain): \(String(describing: error))")
                    try await Task.sleep(for: .seconds(1))
                }
            }

            let manager = NSFileProviderManager(for: domain)!

            var service: NSFileProviderService? = nil

            while true {
                do {
                    service = try await manager.service(named: ouisyncFileProviderServiceName, for: NSFileProviderItemIdentifier.rootContainer)
                    break
                } catch {
                    Self.log("😡 Failed to acquire service from NSFileProviderManager: \(error)")
                    try await Task.sleep(for: .seconds(1))
                }
            }

            guard let service = service else {
                Self.log("😡 Failed to acquire service from NSFileProviderManager")
                return;
            }

            let connection = try await service.fileProviderConnection()
            connection.remoteObjectInterface = NSXPCInterface(with: FromFlutterToFileProviderProtocol.self)

            connection.interruptionHandler = {
                Self.log("😡 Connection to File Provider XPC service has been interrupted")
            }

            connection.invalidationHandler = {
                Self.log("😡 Connection to File Provider XPC service has been invalidated")
            }

            let fileProviderConnection = connection.remoteObjectProxy() as! FromFlutterToFileProviderProtocol;

            func fromRustToServer(_ server: OuisyncFileProviderServerProtocol, _ fromRustRx: Rx) async {
                for await message in fromRustRx {
                    server.messageFromClientToServer(message)
                }
            }

            class FromFileProviderToFlutter : FromFileProviderToFlutterProtocol {
                let flutterMethodChannel: FlutterMethodChannel
                init(_ flutterMethodChannel: FlutterMethodChannel) {
                    self.flutterMethodChannel = flutterMethodChannel
                }
                func send(_ message: [UInt8]) {
                    flutterMethodChannel.invokeMethod("response", arguments: message)
                }
            }

            connection.exportedObject = FromFileProviderToFlutter(flutterMethodChannel)
            connection.exportedInterface = NSXPCInterface(with: FromFileProviderToFlutterProtocol.self)

            connection.resume();

            // For some reason the communication wont start unless we send this first message
            //server.messageFromClientToServer([])
            NSLog("-------- sending back response")
            flutterMethodChannel.invokeMethod("response", arguments: IncomingMessage(requestMessageId, IncomingPayload.response(Response(MessagePackValue.string("none")))).serialize())

        } catch {
            fatalError("Failed to initialize FileProviderProxy \(error)")
        }
    }
}
// Facilitate communication between the file provider extension and the rust code.
class FileProviderProxy {
    init() {
        let domain = ouisyncFileProviderDomain

        SuccessfulTask(name: "FileProviderProxy.init") {
            while true {
                do {
                    try await NSFileProviderManager.add(domain)
                    Self.log("😀 NSFileProviderManager added domain successfully")
                    break
                } catch {
                    Self.log("😡 Error starting file provider for domain \(domain): \(String(describing: error))")
                    try await Task.sleep(for: .seconds(1))
                }
            }

            let ffi = FFI()

            let (fromRustRx, fromRustTx) = makeStream();

            // Compiler complains that `fromRustTx` is not a "class" when I try to get a raw pointer out of it.
            let wrapFromRustTx = Wrap(fromRustTx)

            let callback: FFICallback = { context, dataPointer, size in
                let fromRustTx: Wrap<Tx> = FFI.fromUnretainedPtr(ptr: context!)
                let data = Array(UnsafeBufferPointer(start: dataPointer, count: Int(exactly: size)!))
                fromRustTx.inner.yield(data)
            }

            let session = try await ffi.waitForSession(FFI.toUnretainedPtr(obj: wrapFromRustTx), callback)

            let manager = NSFileProviderManager(for: domain)!

            var service: NSFileProviderService? = nil

            while true {
                do {
                    service = try await manager.service(named: ouisyncFileProviderServiceName, for: NSFileProviderItemIdentifier.rootContainer)
                    break
                } catch {
                    Self.log("😡 Failed to acquire service from NSFileProviderManager: \(error)")
                    try await Task.sleep(for: .seconds(1))
                }
            }

            guard let service = service else {
                Self.log("😡 Failed to acquire service from NSFileProviderManager")
                return;
            }

            let connection = try await service.fileProviderConnection()
            connection.remoteObjectInterface = NSXPCInterface(with: OuisyncFileProviderServerProtocol.self)

            connection.interruptionHandler = {
                Self.log("😡 Connection to File Provider XPC service has been interrupted")
                fromRustTx.finish();
            }

            connection.invalidationHandler = {
                Self.log("😡 Connection to File Provider XPC service has been invalidated")
                fromRustTx.finish();
            }

            let server = connection.remoteObjectProxy() as! OuisyncFileProviderServerProtocol;

            func fromRustToServer(_ server: OuisyncFileProviderServerProtocol, _ fromRustRx: Rx) async {
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

            await fromRustToServer(server, fromRustRx);

            await ffi.closeSession(session)
        }
    }

    func invalidate() async throws {
        try await NSFileProviderManager.remove(ouisyncFileProviderDomain)
    }

    static func log(_ message: String) {
        NSLog(message)
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
    var continuation: Rx.Continuation!
    let stream = Rx() { continuation = $0 }
    return (stream, continuation!)
}

// ---------------------------------------------------------------------------------------

typealias FFIContext = UnsafeRawPointer
typealias FFICallback = @convention(c) (FFIContext?, UnsafePointer<UInt8>, CUnsignedLongLong) -> Void;
typealias FFISessionGrab = @convention(c) (UnsafeRawPointer?, FFICallback) -> SessionCreateResult;
typealias FFISessionClose = @convention(c) (SessionHandle, FFIContext?, FFICallback) -> Void;
typealias FFISessionChannelSend = @convention(c) (SessionHandle, UnsafeRawPointer, UInt64) -> Void;

class FFI {
    let handle: UnsafeMutableRawPointer
    let ffiSessionGrab: FFISessionGrab
    let ffiSessionChannelSend: FFISessionChannelSend
    let ffiSessionClose: FFISessionClose

    init() {
        handle = dlopen("libouisync_ffi.dylib", RTLD_NOW)!
        ffiSessionGrab = unsafeBitCast(dlsym(handle, "session_grab"), to: FFISessionGrab.self)
        ffiSessionChannelSend = unsafeBitCast(dlsym(handle, "session_channel_send"), to: FFISessionChannelSend.self)
        ffiSessionClose = unsafeBitCast(dlsym(handle, "session_close"), to: FFISessionClose.self)
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

    func closeSession(_ session: SessionHandle) async {
        typealias C = CheckedContinuation<Void, Never>

        class Context {
            let session: SessionHandle
            let continuation: C
            init(_ session: SessionHandle, _ continuation: C) {
                self.session = session
                self.continuation = continuation
            }
        }

        await withCheckedContinuation(function: "FFI.closeSession", { continuation in
            let context = Self.toRetainedPtr(obj: Context(session, continuation))
            let callback: FFICallback = { context, dataPointer, size in
                let context: Context = FFI.fromRetainedPtr(ptr: context!)
                context.continuation.resume()
            }
            ffiSessionClose(session, context, callback)
        })
    }

    // Retained pointers have their reference counter incremented by 1.
    // https://stackoverflow.com/a/33310021/273348
    static func toUnretainedPtr<T : AnyObject>(obj : T) -> UnsafeRawPointer {
        return UnsafeRawPointer(Unmanaged.passUnretained(obj).toOpaque())
    }

    static func fromUnretainedPtr<T : AnyObject>(ptr : UnsafeRawPointer) -> T {
        return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
    }

    static func toRetainedPtr<T : AnyObject>(obj : T) -> UnsafeRawPointer {
        return UnsafeRawPointer(Unmanaged.passRetained(obj).toOpaque())
    }

    static func fromRetainedPtr<T : AnyObject>(ptr : UnsafeRawPointer) -> T {
        return Unmanaged<T>.fromOpaque(ptr).takeRetainedValue()
    }
}
