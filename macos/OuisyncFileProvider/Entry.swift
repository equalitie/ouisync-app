//
//  Entry.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 16/04/2024.
//

import Foundation
import System
import OuisyncLib

enum Entry: Equatable {
    case directory(DirectoryEntry)
    case file(FileEntry)

    init(_ r: OuisyncRepository) {
        self = .directory(DirectoryEntry.root(r.handle))
    }

    init(_ e: DirectoryEntry) {
        self = .directory(e)
    }

    init(_ e: FileEntry) {
        self = .file(e)
    }

    init(_ e: OuisyncEntry) {
        switch e {
        case .file(let e):
            self = .file(FileEntry(e))
        case .directory(let e):
            self = .directory(DirectoryEntry(e))
        }
    }

    func serialize() -> String {
        switch self {
        case .directory(let e): return e.serialize()
        case .file(let e): return e.serialize()
        }
    }

    func path() -> FilePath {
        switch self {
        case .directory(let e): return e.path
        case .file(let e): return e.path
        }
    }

    func repositoryHandle() -> RepositoryHandle {
        switch self {
        case .directory(let e): return e.repositoryHandle
        case .file(let e): return e.repositoryHandle
        }
    }

    func hasChildren() -> Bool {
        switch self {
        case .directory: return true
        case .file:return false
        }
    }

    static func deserialize(_ str: String) -> Entry? {
        if let entry = DirectoryEntry.deserialize(str) {
            return Entry(entry)
        }
        if let entry = FileEntry.deserialize(str) {
            return Entry(entry)
        }
        return nil
    }

    public static func == (lhs: Entry, rhs: Entry) -> Bool {
        if case .directory(let l) = lhs, case .directory(let r) = rhs {
            return l == r
        }
        if case .file(let l) = lhs, case .file(let r) = rhs {
            return l == r
        }
        return false
    }
}

class DirectoryEntry: Equatable {
    let repositoryHandle: RepositoryHandle
    let path: FilePath

    init(_ path: FilePath, _ repositoryHandle: RepositoryHandle) {
        self.repositoryHandle = repositoryHandle
        self.path = path
    }

    init(_ directory: OuisyncDirectory) {
        self.repositoryHandle = directory.repository.handle
        self.path = directory.path
    }

    static func root(_ repositoryHandle: RepositoryHandle) -> DirectoryEntry {
        return DirectoryEntry("/", repositoryHandle)
    }

    func name() -> String {
        return OuisyncFile.name(path)
    }

    func serialize() -> String {
        return "directory-\(repositoryHandle)-\(path)"
    }

    static func deserialize(_ str: String) -> DirectoryEntry? {
        let arr = str.components(separatedBy: "-")
        if arr[0] != "directory" { return nil }
        let handle = RepositoryHandle(arr[1])!
        let path = FilePath(arr[2])
        return DirectoryEntry(path, handle)
    }

    public static func == (lhs: DirectoryEntry, rhs: DirectoryEntry) -> Bool {
        return lhs.repositoryHandle == rhs.repositoryHandle && lhs.path == rhs.path
    }
}

class FileEntry: Equatable {
    let repositoryHandle: RepositoryHandle
    let path: FilePath

    init(_ path: FilePath, _ repositoryHandle: RepositoryHandle) {
        self.repositoryHandle = repositoryHandle
        self.path = path
    }

    init(_ file: OuisyncFile) {
        self.repositoryHandle = file.repository.handle
        self.path = file.path
    }

    func name() -> String {
        return path.lastComponent!.string
    }

    func serialize() -> String {
        return "file-\(repositoryHandle)-\(path)"
    }

    static func deserialize(_ str: String) -> FileEntry? {
        let arr = str.components(separatedBy: "-")
        if arr[0] != "file" { return nil }
        let handle = RepositoryHandle(arr[1])!
        let path = FilePath(arr[2])
        return FileEntry(path, handle)
    }

    public static func == (lhs: FileEntry, rhs: FileEntry) -> Bool {
        return lhs.repositoryHandle == rhs.repositoryHandle && lhs.path == rhs.path
    }
}
