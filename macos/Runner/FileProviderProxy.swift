//
//  FileProviderProxy.swift
//  Runner
//
//  Created by Peter Jankuliak on 03/04/2024.
//
import FileProvider
import Common
import FlutterMacOS
import MessagePack


// TODO: this memory copy is unavoidable unless OuisyncLib is updated to use Data (itself [UInt8]-like)
extension Data {
    var bytes: [UInt8] { [UInt8](self) }
}
extension FlutterError: Error {}

actor FileProviderProxy: FromFileProviderToAppProtocol {
    private var manager: NSFileProviderManager!
    private var service: NSFileProviderService!
    private var connection: NSXPCConnection!
    let channel: FlutterMethodChannel

    init(_ flutterBinaryMessenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "org.equalitie.ouisync/backend",
                                       binaryMessenger: flutterBinaryMessenger)
        channel.setMethodCallHandler {
            [weak self] call, result in guard let self
            else { return result(FlutterError(code: "OS00",
                                              message: "Host shutdown",
                                              details: nil)) }
            Task {
                do {
                    let res = try await self.invoke(call)
                    result(res is Void ? nil : res)
                } catch {
                    result(error as? FlutterError ?? FlutterError(code: "OS01",
                                                                  message: "Unknown error in host",
                                                                  details: String(describing: error)))
                }
            }
        }
    }

    nonisolated func fromFileProviderToApp(_ message: [UInt8]) {
        self.channel.invokeMethod("response", arguments: message)
    }

    private func invoke(_ call: FlutterMethodCall) async throws -> Any? {
        switch call.method {
        case "initialize":
            do {
                return try await initialize()
            } catch {
                throw FlutterError(code: "OS02",
                                   message: "Unable to connect to FileProvider",
                                   details: String(describing: error))
            }
        case "invoke":
            guard let bytes = (call.arguments as? FlutterStandardTypedData)?.data.bytes
            else { throw FlutterError(code: "OS03",
                                      message: "Unable to parse message",
                                      details: nil) }
            guard let connection
            else { throw FlutterError(code: "OS04",
                                      message: "Extension is not connected",
                                      details: nil) }
            guard let proto = connection.remoteObjectProxy() as? FromAppToFileProviderProtocol
            else { throw FlutterError(code: "OS05",
                                      message: "Extension is incompatible with host",
                                      details: nil) }

            proto.fromAppToFileProvider(bytes)
            // WARN: this currently returns immediately because an asynchronous response is
            // expected via fromFileProviderToApp; this is fairly inefficient because it results in
            // an extra await that cannot be optimized away (Dart can't possibly know that we're
            // returning immediately) and, depending on how Dart treats its continuations, could
            // very well leak memory every time the connection is dropped
            return nil
        default: throw FlutterError(code: "OS06",
                                    message: "Method \"\(call.method)\" not exported by host",
                                    details: nil)
        }
    }

    private func reset(_ reason: String) {
        connection = nil
        channel.invokeMethod("reset", arguments: reason)
    }

    private func initialize() async throws {
        try await NSFileProviderManager.add(ouisyncFileProviderDomain)
        manager = NSFileProviderManager(for: ouisyncFileProviderDomain)
        if manager == nil { throw FlutterError(code: "OS07",
                                               message: "Unable to obtain File Provider manager",
                                               details: nil) }
        // the following two concurrency warnings can be ignored because they're just transferring
        // ownership of instances created in a different actor; it's better to see them than
        // declaring unchecked Sendable conformance because they should be isolated otherwise
        service = try await manager.service(named: ouisyncFileProviderServiceName,
                                            for: NSFileProviderItemIdentifier.rootContainer)
        if service == nil { throw FlutterError(code: "OS08",
                                               message: "Unable to obtain File Provider service",
                                               details: nil) }

        connection = try await service.fileProviderConnection()
        connection.remoteObjectInterface = NSXPCInterface(with: FromAppToFileProviderProtocol.self)

        connection.interruptionHandler = { [weak self] in guard let self else { return }
            Task { await self.reset("interrupted") }
        }

        connection.invalidationHandler = { [weak self] in guard let self else { return }
            Task { await self.reset("invalidated") }
        }

        connection.exportedObject = self
        connection.exportedInterface = NSXPCInterface(with: FromFileProviderToAppProtocol.self)
        connection.resume()
    }
}
