//
//  FileProviderItem.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 15/03/2024.
//

import FileProvider
import UniformTypeIdentifiers
import MessagePack
import OuisyncLib
import System

class FileItem: NSObject, NSFileProviderItem {
    let repoName: String
    let file: OuisyncFileEntry
    var size: UInt64

    init(_ file: OuisyncFileEntry, _ repoName: String, size: UInt64) {
        self.repoName = repoName
        self.file = file
        self.size = size
    }

    func exists() async throws -> Bool {
        try await file.exists()
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
        NSFileProviderItemVersion(contentVersion: "a content version".data(using: .utf8)!, metadataVersion: "a metadata version".data(using: .utf8)!)
    }

    var filename: String {
        return file.name()
    }

    var contentType: UTType {
        .item
    }

    public override var debugDescription: String {
        "FileItem(\(repoName), \(file.path))"
    }

    var documentSize: NSNumber? {
        size as NSNumber
    }
}

class DirectoryItem: NSObject, NSFileProviderItem {
    let repoName: String
    let directory: OuisyncDirectoryEntry

    init(_ directory: OuisyncDirectoryEntry, _ repoName: String) {
        self.repoName = repoName
        self.directory = directory
    }

    // For when this directory represents a repository
    init(_ repo: OuisyncRepository, _ repoName: String) {
        self.repoName = repoName
        self.directory = OuisyncDirectoryEntry(FilePath(""), repo)
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
        var caps: NSFileProviderItemCapabilities = [.allowsReading, .allowsWriting]

        // We currently allow these *repository* operations only from the app
        if !DirectoryIdentifier(directory.path, repoName).isRepository() {
            caps.insert(.allowsDeleting)
            caps.insert(.allowsReparenting)
            caps.insert(.allowsRenaming)
        }

        return caps
    }

    var itemVersion: NSFileProviderItemVersion {
        NSFileProviderItemVersion(contentVersion: "a content version".data(using: .utf8)!, metadataVersion: "a metadata version".data(using: .utf8)!)
    }

    var filename: String {
        return OuisyncDirectoryEntry.name(FilePath.mergeRepoNameAndPath(repoName, directory.path))
    }

    var contentType: UTType {
        return .folder
    }

    public override var debugDescription: String {
        return "DirectoryItem(\(repoName), \(directory.path))"
    }
}

class RootContainerItem: NSObject, NSFileProviderItem {
    override init() { }

    var itemIdentifier: NSFileProviderItemIdentifier {
        return .rootContainer
    }

    var parentItemIdentifier: NSFileProviderItemIdentifier {
        return .rootContainer
    }

    var capabilities: NSFileProviderItemCapabilities {
        return [.allowsReading]
    }

    var itemVersion: NSFileProviderItemVersion {
        NSFileProviderItemVersion(contentVersion: "a content version".data(using: .utf8)!, metadataVersion: "a metadata version".data(using: .utf8)!)
    }

    var filename: String {
        return ".rootContainer"
    }

    var contentType: UTType {
        return .folder
    }

    public override var debugDescription: String {
        return "RootContainerItem()"
    }
}

class WorkingSetItem: NSObject, NSFileProviderItem {
    override init() { }

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
        NSFileProviderItemVersion(contentVersion: "a content version".data(using: .utf8)!, metadataVersion: "a metadata version".data(using: .utf8)!)
    }

    var filename: String {
        return ".workingSet"
    }

    var contentType: UTType {
        return .folder
    }

    public override var debugDescription: String {
        return "WorkingSetItem()"
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

func itemFromRepo(_ repo: OuisyncRepository, _ repoName: RepoName) -> NSFileProviderItem {
    return DirectoryItem(repo, repoName)
}
