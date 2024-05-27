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
    let file: OuisyncFile

    init(_ file: OuisyncFile, _ repoName: String) {
        self.repoName = repoName
        self.file = file
    }

    var itemIdentifier: NSFileProviderItemIdentifier {
        ItemIdentifier.file(repoName, file.path).serialize()
    }

    var parentItemIdentifier: NSFileProviderItemIdentifier {
        return ItemIdentifier.directory(repoName, file.parent().path).serialize()
    }

    var capabilities: NSFileProviderItemCapabilities {
        return [.allowsReading, .allowsWriting, .allowsRenaming, .allowsReparenting, .allowsTrashing, .allowsDeleting]
    }

    var itemVersion: NSFileProviderItemVersion {
        NSFileProviderItemVersion(contentVersion: "a content version".data(using: .utf8)!, metadataVersion: "a metadata version".data(using: .utf8)!)
    }

    var filename: String {
        return file.name()
    }

    var contentType: UTType {
        return .plainText
    }

    public override var debugDescription: String {
        return "FileItem(\(repoName), \(file.path))"
    }
}

class DirectoryItem: NSObject, NSFileProviderItem {
    let repoName: String
    let directory: OuisyncDirectory

    init(_ directory: OuisyncDirectory, _ repoName: String) {
        self.repoName = repoName
        self.directory = directory
    }

    // For when this directory represents a repository
    init(_ repo: OuisyncRepository, _ repoName: String) {
        self.repoName = repoName
        self.directory = OuisyncDirectory(FilePath("/"), repo)
    }
    
    static func fromIdentifier(_ path: FilePath, _ repoName: String, _ session: OuisyncSession) async throws -> DirectoryItem {
        guard let repo = await getRepoByName(session, repoName) else {
            throw ExtError.noSuchRepository
        }
        return DirectoryItem(OuisyncDirectory(path, repo), repoName)
    }

    var itemIdentifier: NSFileProviderItemIdentifier {
        ItemIdentifier.directory(repoName, directory.path).serialize()
    }

    var parentItemIdentifier: NSFileProviderItemIdentifier {
        if let parent = directory.parent() {
            return ItemIdentifier.directory(repoName, parent.path).serialize()
        } else {
            return .rootContainer
        }
    }

    var capabilities: NSFileProviderItemCapabilities {
        return [.allowsReading, .allowsWriting, .allowsRenaming, .allowsReparenting, .allowsTrashing, .allowsDeleting]
    }

    var itemVersion: NSFileProviderItemVersion {
        NSFileProviderItemVersion(contentVersion: "a content version".data(using: .utf8)!, metadataVersion: "a metadata version".data(using: .utf8)!)
    }

    var filename: String {
        return OuisyncDirectory.name(FilePath.mergeRepoNameAndPath(repoName, directory.path))
    }

    var contentType: UTType {
        return .folder
    }

    public override var debugDescription: String {
        return "DirectoryItem(\(repoName), \(directory.path), parent:\(parentItemIdentifier))"
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

func itemFromIdentifier(
        _ identifier: NSFileProviderItemIdentifier,
        _ session: OuisyncSession) async throws -> NSFileProviderItem {
    return try await itemFromIdentifier(ItemIdentifier(identifier), session)
}

func itemFromIdentifier(
        _ identifier: ItemIdentifier,
        _ session: OuisyncSession) async throws -> NSFileProviderItem {
    switch identifier {
    case .rootContainer: return RootContainerItem()
    case .trashContainer: return TrashContainerItem()
    case .workingSet: return WorkingSetItem()
    case .directory(let repoName, let path):
        return try await DirectoryItem.fromIdentifier(path, repoName, session)
//        guard let repo = await getRepoByName(session, repoName) else {
//            throw ExtError.noSuchRepository
//        }
//        return DirectoryItem(OuisyncDirectory(path, repo), repoName)
    case .file(let repoName, let path):
        guard let repo = await getRepoByName(session, repoName) else {
            throw ExtError.noSuchRepository
        }
        return FileItem(OuisyncFile(path, repo), repoName)
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

func itemFromEntry(_ entry: OuisyncEntry, _ repoName: RepoName) -> NSFileProviderItem {
    switch entry {
    case .directory(let dir): return DirectoryItem(dir, repoName)
    case .file(let file): return FileItem(file, repoName)
    }
}

func itemFromRepo(_ repo: OuisyncRepository, _ repoName: RepoName) -> NSFileProviderItem {
    return DirectoryItem(repo, repoName)
}
