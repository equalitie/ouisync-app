//
//  OuisyncFile.swift
//
//
//  Created by Peter Jankuliak on 17/04/2024.
//
import Foundation
import System


public class Path {
    public let path: FilePath

    public init(_ path: FilePath) {
        self.path = path
    }

    public init(_ path: String) {
        self.path = FilePath(path)
    }

    public static func root() -> Path {
        return Path("/")
    }

    public func isRoot() -> Bool {
        return path.components.isEmpty
    }

    public func parent() -> Path? {
        if isRoot() {
            return nil
        } else {
            var parentPath = path
            parentPath.components.removeLast()
            return Path(parentPath)
        }
    }

    public func name() -> String? {
        return path.lastComponent?.string
    }
}
