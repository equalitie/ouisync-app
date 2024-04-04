//
//  FileProviderServiceProtocol.swift
//  Common
//
//  Created by Peter Jankuliak on 26/03/2024.
//

import Foundation

public let ouisyncFileProviderServiceName = NSFileProviderServiceName("org.equalitie.Ouisync")

@objc public protocol OuisyncFileProviderClientProtocol {
    func messageFromServerToClient(_ message: [UInt8])
}

@objc public protocol OuisyncFileProviderServerProtocol {
    func messageFromClientToServer(_ message: [UInt8])
}
