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
    let file: OuisyncFileEntry
    var size: UInt64
    let version: Version

    init(_ file: OuisyncFileEntry, _ repoName: String, size: UInt64, version: Version) {
        self.repoName = repoName
        self.file = file
        self.size = size
        self.version = version
    }

    func exists() async throws -> Bool {
        try await file.exists()
    }

    func fileIdentifier() -> FileIdentifier {
        FileIdentifier(file.path, repoName)
    }

    var itemIdentifier: NSFileProviderItemIdentifier {
        return FileIdentifier(file.path, repoName).item().serialize()
    }

    var parentItemIdentifier: NSFileProviderItemIdentifier {
        return DirectoryIdentifier(file.parent().path, repoName).item().serialize()
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
        return file.name()
    }

    var contentType: UTType {
        .item
    }

    public override var debugDescription: String {
        "FileItem(\(repoName), \(file.path), \(version))"
    }

    var documentSize: NSNumber? {
        return size as NSNumber
    }
}

class DirectoryItem: NSObject, NSFileProviderItem {
    let repoName: String
    let directory: OuisyncDirectoryEntry
    let version: Version

    fileprivate init(_ directory: OuisyncDirectoryEntry, _ repoName: String, _ version: Version) {
        self.repoName = repoName
        self.directory = directory
        self.version = version
    }

    static func load(_ directory: OuisyncDirectoryEntry, _ repoName: String) async throws -> DirectoryItem {
        let version = Version(Hash(try await directory.repository.getEntryVersionHash("/")), 0)
        return DirectoryItem(directory, repoName, version)
    }

    // For when this directory represents a repository
    static func load(_ repo: OuisyncRepository, _ repoName: String) async throws -> DirectoryItem {
        let directory = OuisyncDirectoryEntry(FilePath(""), repo)
        return try await load(directory, repoName)
    }
    
    func directoryIdentifier() -> DirectoryIdentifier {
        DirectoryIdentifier(directory.path, repoName)
    }

    func exists() async throws -> Bool {
        try await directory.exists()
    }

    var itemIdentifier: NSFileProviderItemIdentifier {
        return DirectoryIdentifier(directory.path, repoName).item().serialize()
    }

    var parentItemIdentifier: NSFileProviderItemIdentifier {
        if let parent = directory.parent() {
            return DirectoryIdentifier(parent.path, repoName).item().serialize()
        } else {
            return .rootContainer
        }
    }

    var capabilities: NSFileProviderItemCapabilities {
        var caps: NSFileProviderItemCapabilities = [.allowsReading, .allowsWriting, .allowsAddingSubItems, .allowsContentEnumerating]

        // We currently allow these *repository* operations only from the app
        if !DirectoryIdentifier(directory.path, repoName).isRepository() {
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
        return OuisyncDirectoryEntry.name(FilePath.mergeRepoNameAndPath(repoName, directory.path))
    }

    var contentType: UTType {
        return .folder
    }

    public override var debugDescription: String {
        return "DirectoryItem(\(repoName), \(directory.path), \(version), \(parentItemIdentifier))"
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

func getRepoByName(_ session: OuisyncSession, _ repoName: String) async -> OuisyncRepository? {
    // TODO: the unwraps

    let repos = (try? await session.listRepositories())!

    for repo in repos {
        let name = (try? await repo.getName())!
        if name == repoName {
            return repo
        }
    }

    return nil
}
