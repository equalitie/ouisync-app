//
//  Anchor.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 24/05/2024.
//

import Foundation
import FileProvider

typealias Anchor = UInt64

extension NSFileProviderSyncAnchor {
    init(_ n: Anchor) {
        self.init(rawValue: String(n).data(using: .ascii)!)
    }

    func asInteger() -> Anchor? {
        guard let str = String(bytes: rawValue, encoding: .ascii) else {
            return nil
        }
        return UInt64(str)
    }
}

extension NSFileProviderSyncAnchor: CustomDebugStringConvertible {
    public var debugDescription: String {
        guard let str = String(bytes: rawValue, encoding: .ascii) else {
            fatalError("Invalid anchor")
        }
        return "Anchor(\(str))"
    }
}
