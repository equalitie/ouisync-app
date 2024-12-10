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

@objc public protocol FromAppToFileProviderProtocol {
    // Used for sending requests from Flutter to the extension's backend.
    func fromAppToFileProvider(_ message: [UInt8])
}

@objc public protocol FromFileProviderToAppProtocol {
    // Used to send notifications from the extension's backend to Flutter.
    func fromFileProviderToApp(_ message: [UInt8])
}

