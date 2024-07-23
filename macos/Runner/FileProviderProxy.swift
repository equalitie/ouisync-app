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

class FileProviderProxy {
    var extensionManager: NSFileProviderManager? = nil
    var extensionService: NSFileProviderService? = nil
    var connectionToExtension: NSXPCConnection? = nil
    let flutterMethodChannel: FlutterMethodChannel

    init(_ flutterBinaryMessenger: FlutterBinaryMessenger) {
        flutterMethodChannel = FlutterMethodChannel(name: "org.equalitie.ouisync/backend", binaryMessenger: flutterBinaryMessenger)
        flutterMethodChannel.setMethodCallHandler(handleMessageFromFlutter)
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
        switch call.method {
        case "initialize":
            let message = OutgoingMessage.deserialize(bytes)!
            Task {
                await initialize(message.messageId)
            }
        case "invoke":
            NSLog("Sending to extension")
            Task {
                NSLog("app -> extension \(OutgoingMessage.deserialize(bytes) as Optional)");
                let response = await sendToExtension(bytes)
                NSLog("extension -> app \(IncomingMessage.deserialize(bytes) as Optional)")
                sendToFlutter(response)
            }
        default:
            fatalError("Received an unrecognized message from Flutter: \(call.method)(\(call.arguments as Optional))")
        }
        result(nil)
    }

    private func initialize(_ requestMessageId: MessageId) async {
        let domain = ouisyncFileProviderDomain

        do {
            while true {
                do {
                    try await NSFileProviderManager.add(domain)
                    NSLog("😀 NSFileProviderManager added domain successfully")
                    break
                } catch {
                    NSLog("😡 Error starting file provider for domain \(domain): \(String(describing: error))")
                    try await Task.sleep(for: .seconds(1))
                }
            }

            let manager = NSFileProviderManager(for: domain)!

            while true {
                do {
                    extensionService = try await manager.service(named: ouisyncFileProviderServiceName, for: NSFileProviderItemIdentifier.rootContainer)
                    break
                } catch {
                    NSLog("😡 Failed to acquire service from NSFileProviderManager: \(error)")
                    try await Task.sleep(for: .seconds(1))
                }
            }

            guard let service = extensionService else {
                NSLog("😡 Failed to acquire service from NSFileProviderManager")
                return;
            }

            extensionManager = manager
            extensionService = service

            let connection = try await service.fileProviderConnection()
            connection.remoteObjectInterface = NSXPCInterface(with: FromAppToFileProviderProtocol.self)

            connection.interruptionHandler = { [weak self] in
                if let self = self {
                    NSLog("😡 Connection to File Provider XPC service has been interrupted")
                    self.connectionToExtension = nil
                }
            }

            connection.invalidationHandler = { [weak self] in
                if let self = self {
                    NSLog("😡 Connection to File Provider XPC service has been invalidated")
                    connectionToExtension = nil
                }
            }

            class FromFileProviderToApp : FromFileProviderToAppProtocol {
                weak var proxy: FileProviderProxy?

                init(_ proxy: FileProviderProxy) {
                    self.proxy = proxy
                }

                func fromFileProviderToApp(_ message: [UInt8]) {
                    guard let proxy = proxy else {
                        NSLog("😡 Received a message from Extension but proxy is already gone")
                        return
                    }
                    proxy.sendToFlutter(message)
                }
            }

            connection.exportedObject = FromFileProviderToApp(self)
            connection.exportedInterface = NSXPCInterface(with: FromFileProviderToAppProtocol.self)

            connectionToExtension = connection
            connection.resume();

            sendToFlutter(IncomingMessage(requestMessageId, IncomingPayload.response(Response(MessagePackValue.string("none")))).serialize())

        } catch {
            fatalError("Failed to initialize FileProviderProxy \(error)")
        }
    }

    fileprivate func sendToFlutter(_ message: [UInt8]) {
        let channel = flutterMethodChannel
        DispatchQueue.main.async {
            channel.invokeMethod("response", arguments: message)
        }
    }

    fileprivate func sendToExtension(_ message: [UInt8]) async -> [UInt8] {
        let proto = connectionToExtension!.remoteObjectProxy() as! FromAppToFileProviderProtocol;
        return await proto.fromAppToFileProvider(message)
    }
}
