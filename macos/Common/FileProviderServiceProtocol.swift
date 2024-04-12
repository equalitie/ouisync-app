//
//  FileProviderServiceProtocol.swift
//  Common
//
//  Created by Peter Jankuliak on 26/03/2024.
//

import Foundation
import FileProvider

public let ouisyncFileProviderServiceName = NSFileProviderServiceName("org.equalitie.Ouisync")

@objc public protocol OuisyncFileProviderClientProtocol {
    func messageFromServerToClient(_ message: [UInt8])
}

@objc public protocol OuisyncFileProviderServerProtocol {
    func messageFromClientToServer(_ message: [UInt8])
}

public func getDomain() -> NSFileProviderDomain {
    return NSFileProviderDomain(identifier: NSFileProviderDomainIdentifier(rawValue: "mydomain"), displayName: "mydisplayname")
}
