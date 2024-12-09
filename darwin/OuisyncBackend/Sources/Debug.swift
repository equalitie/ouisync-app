//
//  Debug.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 04/06/2024.
//
import FileProvider
import Foundation


extension NSFileProviderItemFields: CustomDebugStringConvertible {
    static public var debugDescriptions: [(Self, String)] = [
        (.filename, ".filename"),
        (.contents, ".contents"),
        (.parentItemIdentifier, ".parentItemIdentifier"),
        (.contentModificationDate, ".contentModificationDate"),
        (.creationDate, ".creationDate"),
        (.extendedAttributes, ".extendedAttributes"),
        (.fileSystemFlags, ".fileSystemFlags"),
        (.tagData, ".tagData"),
        (.favoriteRank, ".favoriteRank"),
        (.typeAndCreator, ".typeAndCreator")
    ]

    public var debugDescription: String {
        var copy = NSFileProviderItemFields(rawValue: rawValue)
        let collect: [String] = Self.debugDescriptions.filter {
            copy.remove($0.0)
            return contains($0.0)
        }.map { $0.1 }

        let joined = collect.joined(separator: ", ")

        if copy.isEmpty {
            return "[\(joined)]"
        } else {
            return "[\(joined),... \(copy.rawValue)]"
        }
    }
}

extension NSFileProviderItemIdentifier: CustomDebugStringConvertible {
    public var debugDescription: String {
        if let deserialized = ItemIdentifier.tryDeserialize(self) {
            return deserialized.debugDescription
        } else {
            return "!!!\(self.debugDescription)!!!"
        }
    }
}

