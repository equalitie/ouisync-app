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

class NotificationStream {
    typealias Id = UInt64
    typealias Rx = AsyncStream<OuisyncNotification>
    typealias RxIter = Rx.AsyncIterator
    typealias Tx = Rx.Continuation

    class State {
        var registrations: [Id: Tx] = [:]
    }

    static var nextId: Id = 0
    let id: Id
    let rx: Rx
    var rx_iter: RxIter
    var state: State

    init(_ state: State) {
        id = NotificationStream.nextId;
        NotificationStream.nextId += 1

        var tx: Tx!
        rx = Rx { tx = $0 }
        self.rx_iter = rx.makeAsyncIterator()

        self.state = state

        state.registrations[id] = tx
    }

    public func next() async -> OuisyncNotification? {
        return await rx_iter.next()
    }

    deinit {
        state.registrations.removeValue(forKey: id)
    }
}

class OuisyncConnection {
    // Used to send and receive messages from the Ouisync library
    let libraryClient: OuisyncFileProviderClientProtocol

    var nextMessageId: MessageId = 0
    var pendingResponses: [MessageId: CheckedContinuation<Response, any Error>] = [:]
    var state: NotificationStream.State = NotificationStream.State()

    init(_ libraryClient: OuisyncFileProviderClientProtocol) {
        self.libraryClient = libraryClient
    }

    public func listRepositories() async throws -> [UInt64] {
        let response = try await sendRequest(MessageRequest.listRepositories(generateMessageId()));
        return response.value.arrayValue!.map({n in n.uint64Value! })
    }

    public func subscribeToRepositoryListChange() async throws -> NotificationStream {
        let messageId = generateMessageId()
        let stream = NotificationStream(state)
        let _ = try await sendRequest(MessageRequest.subscribeToRepositoryListChange(messageId));
        return stream
    }

    func sendRequest(_ request: MessageRequest) async throws -> Response {
        async let onResponse = withCheckedThrowingContinuation { continuation in
            pendingResponses[request.messageId] = continuation
        }

        sendDataToOuisyncLib(request.serialize());

        return try await onResponse
    }

    func generateMessageId() -> MessageId {
        let messageId = nextMessageId
        nextMessageId += 1
        return messageId
    }

    func sendDataToOuisyncLib(_ data: [UInt8]) {
        libraryClient.messageFromServerToClient(data);
    }

    func onReceiveDataFromOuisyncLib(_ data: [UInt8]) {
        let maybe_message = IncomingMessage.deserialize(data)

        guard let message = maybe_message else {
            NSLog(":::: 😡 Failed to parse incoming message from OuisyncLib \(data)")
            return
        }

        NSLog(":::: 🙂 Received message from OuisyncLib \(message)")

        switch message.payload {
        case .response(let response):
            handleResponse(message.messageId, response)
        case .notification(let notification):
            handleNotification(message.messageId, notification)
        case .error(let error):
            handleError(message.messageId, error)
        }
    }

    func handleResponse(_ messageId: MessageId, _ response: Response) {
        guard let pendingResponse = pendingResponses.removeValue(forKey: messageId) else {
            NSLog(":::: 😡 Failed to match response to a request")
            return
        }
        pendingResponse.resume(returning: response)
    }

    func handleNotification(_ messageId: MessageId, _ response: OuisyncNotification) {
        for tx in state.registrations.values {
            tx.yield(response)
        }
    }

    func handleError(_ messageId: MessageId, _ response: ErrorResponse) {
        guard let pendingResponse = pendingResponses.removeValue(forKey: messageId) else {
            NSLog(":::: 😡 Failed to match response to a request")
            return
        }
        pendingResponse.resume(throwing: response)
    }

}

extension FileProviderExtension: NSFileProviderServicing {
    public func supportedServiceSources(for itemIdentifier: NSFileProviderItemIdentifier,
                                        completionHandler: @escaping ([NSFileProviderServiceSource]?, Error?) -> Void) -> Progress {
        completionHandler([OuisyncServiceSource(self)], nil)
        let progress = Progress()
        progress.cancellationHandler = { completionHandler(nil, NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError)) }
        return progress
    }
}

extension FileProviderExtension {
    class OuisyncServiceSource: NSObject, NSFileProviderServiceSource, NSXPCListenerDelegate, OuisyncFileProviderServerProtocol {
        var nextMessageId: MessageId = 0

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
            NSLog(":::: START")

            connection.remoteObjectInterface = NSXPCInterface(with: OuisyncFileProviderClientProtocol.self)
            connection.exportedObject = self
            connection.exportedInterface = NSXPCInterface(with: OuisyncFileProviderServerProtocol.self)

            connection.interruptionHandler = {
                NSLog("😡 Connection to Ouisync XPC service has been interrupted")
            }

            connection.invalidationHandler = {
                NSLog("😡 Connection to Ouisync XPC service has been invalidated")
            }

            let maybe_client = connection.remoteObjectProxy() as? OuisyncFileProviderClientProtocol;

            guard let client = maybe_client else {
                NSLog(":::: 😡 Failed to convert XPC connection to OuisyncConnection")
                return false
            }

            // TODO: This was used in an example, but maybe we dont need to do that?
            synchronized(self) {
                listeners.remove(listener)
            }

            let ouisyncConnection = OuisyncConnection(client)

            if let ext = self.ext {
                ext.ouisyncConnection = ouisyncConnection
            }

            connection.resume()

            Task {
                let repoListChanged = try await ouisyncConnection.subscribeToRepositoryListChange()
                let _ = try await ouisyncConnection.listRepositories()
                while true {
                    if await repoListChanged.next() == nil {
                        break
                    }
                    let _ = try await ouisyncConnection.listRepositories()
                }
            }

            return true
        }

        weak var ext: FileProviderExtension?
        let listeners = NSHashTable<NSXPCListener>()

        init(_ ext: FileProviderExtension) {
            self.ext = ext
        }

        func messageFromClientToServer(_ message_data: [UInt8]) {
            if message_data.isEmpty {
                return
            }

            guard let ext = self.ext else {
                return
            }

            guard let ouisyncConnection = ext.ouisyncConnection else {
                return
            }

            ouisyncConnection.onReceiveDataFromOuisyncLib(message_data)
        }
    }
}

public func synchronized<T>(_ lock: AnyObject, _ closure: () throws -> T) rethrows -> T {
    objc_sync_enter(lock)
    defer { objc_sync_exit(lock) }
    return try closure()
}
