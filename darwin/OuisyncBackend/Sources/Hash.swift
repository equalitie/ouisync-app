//
//  Hash.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 10/06/2024.
//
import Foundation


struct Hash: Codable, Equatable, CustomDebugStringConvertible {
    let data: Data

    init(_ data: Data) {
        self.data = data
    }

    static func == (lhs: Hash, rhs: Hash) -> Bool {
        lhs.data == rhs.data
    }

    var debugDescription: String {
        if data == Data() {
            return "IvalidHash"
        } else {
            return data[0..<8].map { String(format: "%02hhx", $0) }.joined()
        }
    }
}
