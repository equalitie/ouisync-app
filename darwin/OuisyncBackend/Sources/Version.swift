//
//  Version.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 18/06/2024.
//
import FileProvider
import Foundation


enum Version: Codable, CustomDebugStringConvertible {
    case valid(ValidVersion)
    case invalid(InvalidVersion)

    init(_ data: Data) {
        self = Self.tryDeserialize(data)!
    }

    init(_ hash: Hash, _ size: UInt64) { self = .valid(ValidVersion(hash, size)) }
    init(_ v: ValidVersion) { self = .valid(v) }
    init(_ v: InvalidVersion) { self = .invalid(v) }
    init(_ v: NSFileProviderItemVersion) { self = Self.tryDeserialize(v.contentVersion)! }

    static func invalid() -> Self { .invalid(InvalidVersion()) }

    static func tryDeserialize(_ data: Data) -> Self? {
        return try? JSONDecoder().decode(Self.self, from: data)
    }

    public func serialize() -> Data {
        let encoder = JSONEncoder()
        // Without .sortedKeys the encoder would encode the keys in a random order, but
        // the system expects consistent strings to identify items. With .sortedKeys
        // the resulting string is deterministic.
        encoder.outputFormatting = .sortedKeys
        // We don't expect this to fail
        return try! encoder.encode(self)
    }

    var debugDescription: String {
        switch self {
        case .valid(let v): return v.debugDescription
        case .invalid(let v): return v.debugDescription
        }
    }

    func knownSize() -> UInt64? {
        switch self {
        case .valid(let v): return v.size
        case .invalid: return nil
        }
    }
}

class ValidVersion: Codable, CustomDebugStringConvertible {
    let hash: Hash
    let size: UInt64

    init(_ hash: Hash, _ size: UInt64) {
        self.hash = hash
        self.size = size
    }

    var debugDescription: String {
        "ValidVersion(\(hash), \(size))"
    }
}

class InvalidVersion: Codable, CustomDebugStringConvertible {
    let randomInt: UInt64

    init() {
        randomInt = UInt64.random(in: UInt64.min ... UInt64.max)
    }

    var debugDescription: String {
        "InvalidVersion(\(randomInt))"
    }
}
