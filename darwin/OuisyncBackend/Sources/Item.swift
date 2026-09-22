//
//  FileProviderItem.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 15/03/2024.
//
import FileProvider
import MessagePack
import OuisyncLib
import System
import UniformTypeIdentifiers


enum EntryItem: Hashable, Equatable, CustomDebugStringConvertible {
    case file(FileItem)
    case directory(DirectoryItem)

    func providerItem() -> NSFileProviderItem {
        switch self {
        case .file(let file): return file
        case .directory(let dir): return dir
        }
    }

    func id() -> EntryIdentifier {
        switch self {
        case .file(let file): return file.fileIdentifier().entry()
        case .directory(let dir): return dir.directoryIdentifier().entry()
        }
    }

    public var debugDescription: String {
        switch self {
        case .file(let file): return file.debugDescription
        case .directory(let dir): return dir.debugDescription
        }
    }
}

class FileItem: NSObject, NSFileProviderItem {
    let repoName: String
    // The file path is relative to the repository
    let path: FilePath
    var size: UInt64
    let version: Version

    init(_ path: FilePath, _ repoName: String, size: UInt64, version: Version) {
        self.repoName = repoName
        self.path = path
        self.size = size
        self.version = version
    }

    func fileIdentifier() -> FileIdentifier {
        FileIdentifier(path, repoName)
    }

    var itemIdentifier: NSFileProviderItemIdentifier {
        return FileIdentifier(path, repoName).item().serialize()
    }

    var parentItemIdentifier: NSFileProviderItemIdentifier {
        return DirectoryIdentifier(path.removingLastComponent(), repoName).item().serialize()
    }

    var capabilities: NSFileProviderItemCapabilities {
        // TODO: Do we ever want to support .allowsTrashing?
        [.allowsReading, .allowsWriting, .allowsRenaming, .allowsDeleting, .allowsReparenting]
    }

    var itemVersion: NSFileProviderItemVersion {
        let data = version.serialize()
        return NSFileProviderItemVersion(contentVersion: data, metadataVersion: data)
    }

    var filename: String {
        return path.lastComponent?.string ?? ""
    }

    var contentType: UTType {
        .item
    }

    public override var debugDescription: String {
        "FileItem(\(repoName), \(path), \(version))"
    }

    var documentSize: NSNumber? {
        return size as NSNumber
    }
}

class DirectoryItem: NSObject, NSFileProviderItem {
    let repoName: String
    // The directory path is relative to the repository (empty path means the repository root)
    let path: FilePath
    let version: Version

    fileprivate init(_ path: FilePath, _ repoName: String, _ version: Version) {
        self.repoName = repoName
        self.path = path
        self.version = version
    }

    static func load(_ repo: Repository, _ path: FilePath, _ repoName: String) async throws -> DirectoryItem {
        // TODO(stopgap): synthesized version; new service API lacks per-entry version hash
        let version = Version(try await synthesizeDirectoryVersionHash(repo, path), 0)
        return DirectoryItem(path, repoName, version)
    }

    // For when this directory represents a repository
    static func load(_ repo: Repository, _ repoName: String) async throws -> DirectoryItem {
        return try await load(repo, FilePath(""), repoName)
    }

    func directoryIdentifier() -> DirectoryIdentifier {
        DirectoryIdentifier(path, repoName)
    }

    var itemIdentifier: NSFileProviderItemIdentifier {
        return DirectoryIdentifier(path, repoName).item().serialize()
    }

    var parentItemIdentifier: NSFileProviderItemIdentifier {
        if path.components.isEmpty {
            return .rootContainer
        } else {
            return DirectoryIdentifier(path.removingLastComponent(), repoName).item().serialize()
        }
    }

    var capabilities: NSFileProviderItemCapabilities {
        var caps: NSFileProviderItemCapabilities = [.allowsReading, .allowsWriting, .allowsAddingSubItems, .allowsContentEnumerating]

        // We currently allow these *repository* operations only from the app
        if !DirectoryIdentifier(path, repoName).isRepository() {
            caps.insert(.allowsDeleting)
            caps.insert(.allowsReparenting)
            caps.insert(.allowsRenaming)
        }

        return caps
    }

    var itemVersion: NSFileProviderItemVersion {
        let data = version.serialize()
        return NSFileProviderItemVersion(contentVersion: data, metadataVersion: data)
    }

    var filename: String {
        // When this directory is the repository root its path is empty; use the repository name.
        return path.lastComponent?.string ?? repoName
    }

    var contentType: UTType {
        return .folder
    }

    public override var debugDescription: String {
        return "DirectoryItem(\(repoName), \(path), \(version), \(parentItemIdentifier))"
    }
}

class RootContainerItem: NSObject, NSFileProviderItem {
    let version: NSFileProviderSyncAnchor

    init(_ version: NSFileProviderSyncAnchor) {
        self.version = version
    }

    var itemIdentifier: NSFileProviderItemIdentifier {
        return .rootContainer
    }

    var parentItemIdentifier: NSFileProviderItemIdentifier {
        return .rootContainer
    }

    var capabilities: NSFileProviderItemCapabilities {
        return [.allowsReading, .allowsContentEnumerating]
    }

    var itemVersion: NSFileProviderItemVersion {
        let v = version.rawValue
        return NSFileProviderItemVersion(contentVersion: v, metadataVersion: v)
    }

    var filename: String {
        return ".rootContainer"
    }

    var contentType: UTType {
        return .folder
    }

    public override var debugDescription: String {
        return "RootContainerItem(\(version))"
    }
}

class WorkingSetItem: NSObject, NSFileProviderItem {
    let version: NSFileProviderSyncAnchor

    init(_ version: NSFileProviderSyncAnchor) {
        self.version = version
    }

    var itemIdentifier: NSFileProviderItemIdentifier {
        return .workingSet
    }

    var parentItemIdentifier: NSFileProviderItemIdentifier {
        return .workingSet
    }

    var capabilities: NSFileProviderItemCapabilities {
        return [.allowsReading]
    }

    var itemVersion: NSFileProviderItemVersion {
        let v = version.rawValue
        return NSFileProviderItemVersion(contentVersion: v, metadataVersion: v)
    }

    var filename: String {
        return ".workingSet"
    }

    var contentType: UTType {
        return .folder
    }

    public override var debugDescription: String {
        return "WorkingSetItem(\(version))"
    }
}

class TrashContainerItem: NSObject, NSFileProviderItem {
    override init() {}

    var itemIdentifier: NSFileProviderItemIdentifier {
        return .trashContainer
    }

    var parentItemIdentifier: NSFileProviderItemIdentifier {
        return .trashContainer
    }

    var capabilities: NSFileProviderItemCapabilities {
        return [.allowsReading]
    }

    var itemVersion: NSFileProviderItemVersion {
        NSFileProviderItemVersion(contentVersion: "a content version".data(using: .utf8)!, metadataVersion: "a metadata version".data(using: .utf8)!)
    }

    var filename: String {
        return ".trashContainer"
    }

    var contentType: UTType {
        return .folder
    }

    public override var debugDescription: String {
        return "TrashContainerItem()"
    }
}

func getRepoByName(_ session: Session, _ repoName: String) async -> Repository? {
    // Repositories are now keyed by name; `findRepository` throws when there is no match, so we
    // map that (and any other lookup failure) back to the previous "return nil" behavior.
    return try? await session.findRepository(repoName)
}

// TODO(stopgap): synthesized version; new service API lacks per-entry version hash.
// Derive a deterministic content-version hash from the file's size (the 8 bytes of the UInt64).
func synthesizeFileVersionHash(_ size: UInt64) -> Hash {
    var value = size.littleEndian
    let data = Swift.withUnsafeBytes(of: &value) { Data($0) }
    return Hash(data)
}

// TODO(stopgap): synthesized version; new service API lacks per-entry version hash.
// Derive a stable directory version hash from the sorted "name:entryType" child listing.
func synthesizeDirectoryVersionHash(_ repo: Repository, _ path: FilePath) async throws -> Hash {
    let entries = try await repo.readDirectory(path.string)
    let joined = entries
        .map { "\($0.name):\($0.entryType.rawValue)" }
        .sorted()
        .joined(separator: "\n")
    return Hash(Data(joined.utf8))
}
