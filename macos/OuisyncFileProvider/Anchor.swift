//
//  Anchor.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 24/05/2024.
//

import Foundation
import FileProvider

extension NSFileProviderSyncAnchor {
    static func random() -> NSFileProviderSyncAnchor {
        let value = UInt64.random(in: UInt64.min ... UInt64.max)
        return NSFileProviderSyncAnchor(rawValue: String(value).data(using: .ascii)!)
    }
}

extension NSFileProviderSyncAnchor: CustomDebugStringConvertible {
    public var debugDescription: String {
        guard let str = String(bytes: rawValue, encoding: .ascii) else {
            return "InvalidAnchor"
        }
        return "Anchor(\(str))"
    }
}
