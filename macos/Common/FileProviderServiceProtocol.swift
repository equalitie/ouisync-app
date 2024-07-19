//
//  FileProviderServiceProtocol.swift
//  Common
//
//  Created by Peter Jankuliak on 26/03/2024.
//

import Foundation
import FileProvider

public let ouisyncFileProviderServiceName = NSFileProviderServiceName("org.equalitie.Ouisync")
// We use only one domain
public let ouisyncFileProviderDomainId = NSFileProviderDomainIdentifier(rawValue: "ouisyncCommonDomain")
public let ouisyncFileProviderDomain = NSFileProviderDomain(identifier: ouisyncFileProviderDomainId, displayName: "Ouisync")

@objc public protocol OuisyncFileProviderClientProtocol {
    func messageFromServerToClient(_ message: [UInt8])
}

@objc public protocol OuisyncFileProviderServerProtocol {
    func messageFromClientToServer(_ message: [UInt8])
}

@objc public protocol FromFlutterToFileProviderProtocol {
    func send(_ message: [UInt8]) -> [UInt8]
}

@objc public protocol FromFileProviderToFlutterProtocol {
    func send(_ message: [UInt8])
}
