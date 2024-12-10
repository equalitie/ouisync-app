//
//  Anchor.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 24/05/2024.
//
import FileProvider
import Foundation


extension NSFileProviderSyncAnchor: CustomDebugStringConvertible {
    public var debugDescription: String {
        guard let str = String(bytes: rawValue, encoding: .ascii) else {
            return "InvalidAnchor(non-ascii)"
        }
        let strs = str.components(separatedBy: "-")
        if strs.count != 2 {
            return "InvalidAnchor(separator-wont-split-into-two)"
        }
        var runtimeId = strs[1]
        if runtimeId.count > 8 {
            runtimeId = "\(runtimeId.prefix(6)).."
        }
        return "\(strs[0])-\(runtimeId)"
    }
}

class AnchorGenerator {
    let runtimeId: UInt64
    var nextAnchorId: UInt64 = 0

    init () {
        runtimeId = UInt64.random(in: UInt64.min ... UInt64.max)
    }

    func generate() -> NSFileProviderSyncAnchor {
        let id = nextAnchorId
        nextAnchorId += 1
        return NSFileProviderSyncAnchor(rawValue: "\(id)-\(runtimeId)".data(using: .ascii)!)
    }
}
