//
//  FileProviderServiceProtocol.swift
//  Common
//
//  Created by Peter Jankuliak on 26/03/2024.
//

import Foundation

public let ouisyncFileProviderServiceName = NSFileProviderServiceName("org.equalitie.Ouisync")

@objc public protocol OuisyncFileProviderClientProtocol {
    func requestForClient(_ request: [UInt8], _ respond: @escaping ([UInt8]) -> Void)
}

@objc public protocol OuisyncFileProviderServerProtocol {
    func requestForServer(_ request: [UInt8], _ respond: @escaping ([UInt8]) -> Void)
}
