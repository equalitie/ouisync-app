//
//  DeserializedIdentifier.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 22/05/2024.
//

import Foundation
import FileProvider
import OuisyncLib
import System // for FilePath

typealias RepoName = String

enum ItemIdentifier: CustomDebugStringConvertible {
    case rootContainer
    case trashContainer
    case workingSet
    case directory(DirectoryIdentifier)
    case file(FileIdentifier)

    init(_ serialized: NSFileProviderItemIdentifier) {
        switch serialized {
        case .rootContainer:
            self = .rootContainer
        case .trashContainer:
            self = .trashContainer
        case .workingSet:
            self = .workingSet
        default:
            let str = serialized.rawValue
            let arr = str.split(separator: "-", maxSplits: 1)
            if (arr[0] == "directory") {
                let (repoName, path) = FilePath.splitRepoNameAndPath(String(arr[1]))
                self = .directory(DirectoryIdentifier(path, repoName))
            } else if (arr[0] == "file") {
                let (repoName, path) = FilePath.splitRepoNameAndPath(String(arr[1]))
                self = .file(FileIdentifier(path, repoName))
            } else {
                fatalError("Failed to parse NSFileProviderItemIdentifier: \(serialized)")
            }
        }
    }

    init(_ ouisyncEntry: OuisyncEntry, _ repoName: RepoName) {
        switch ouisyncEntry {
        case .directory(let entry): self = .directory(DirectoryIdentifier(entry.path, repoName))
        case .file(let entry): self = .directory(DirectoryIdentifier(entry.path, repoName))
        }
    }

    public func serialize() -> NSFileProviderItemIdentifier {
        switch self {
        case .rootContainer: return .rootContainer
        case .trashContainer: return .trashContainer
        case .workingSet: return .workingSet
        case .directory(let id): return id.serialize()
        case .file(let id): return id.serialize()
        }
    }

    public var debugDescription: String {
        switch self {
        case .rootContainer: return "ItemIdentifier(.rootContainer)"
        case .trashContainer: return "ItemIdentifier(.trashContainer)"
        case .workingSet: return "ItemIdentifier(.workingSet)"
        case .directory(let id): return "ItemIdentifier(directory-\(FilePath.mergeRepoNameAndPath(id.repoName, id.path)))"
        case .file(let id): return "ItemIdentifier(file-\(FilePath.mergeRepoNameAndPath(id.repoName, id.path)))"
        }
    }

    func loadItem(_ session: OuisyncSession) async throws -> NSFileProviderItem {
        switch self {
        case .rootContainer: return RootContainerItem()
        case .trashContainer: return TrashContainerItem()
        case .workingSet: return WorkingSetItem()
        case .directory(let identifier):
            return try await identifier.loadItem(session)
        case .file(let identifier):
            return try await identifier.loadItem(session)
        }
    }
}

class FileIdentifier {
    // The file path is relative to the repository
    let path: FilePath
    let repoName: RepoName

    init(_ path: FilePath, _ repoName: RepoName) {
        self.path = path
        self.repoName = repoName
    }

    func loadItem(_ session: OuisyncSession) async throws -> FileItem {
        guard let repo = await getRepoByName(session, repoName) else {
            throw ExtError.noSuchItem
        }

        let entry = OuisyncFileEntry(path, repo)

        let size: UInt64

        do {
            let file = try await entry.open()
            size = try await file.size()
        } catch let error as OuisyncError {
            if error.code == .EntryNotFound {
                throw ExtError.noSuchItem
            } else {
                fatalError("Unhandled Ouisync error:\(error), repo:\(repoName), path:\(path)")
            }
        } catch {
            fatalError("Unhandled exception error:\(error), repo:\(repoName), path:\(path)")
        }

        return FileItem(OuisyncFileEntry(path, repo), repoName, size: size)
    }

    func loadRepo(_ session: OuisyncSession) async throws -> OuisyncRepository {
        guard let repo = await getRepoByName(session, repoName) else {
            throw ExtError.noSuchItem
        }
        return repo
    }

    func serialize() -> NSFileProviderItemIdentifier {
        NSFileProviderItemIdentifier("file-\(FilePath.mergeRepoNameAndPath(repoName, path))")
    }
}

class DirectoryIdentifier {
    // The file path is relative to the repository
    let path: FilePath
    let repoName: RepoName

    init(_ path: FilePath, _ repoName: RepoName) {
        self.path = path
        self.repoName = repoName
    }

    func loadItem(_ session: OuisyncSession) async throws -> DirectoryItem {
        let repo = try await loadRepo(session)

        let entry = OuisyncDirectoryEntry(path, repo)

        if try await entry.exists() == false {
            throw ExtError.noSuchItem
        }

        return DirectoryItem(OuisyncDirectoryEntry(path, repo), repoName)
    }

    func loadRepo(_ session: OuisyncSession) async throws -> OuisyncRepository {
        guard let repo = await getRepoByName(session, repoName) else {
            throw ExtError.noSuchItem
        }
        return repo
    }

    public func serialize() -> NSFileProviderItemIdentifier {
        NSFileProviderItemIdentifier("directory-\(FilePath.mergeRepoNameAndPath(repoName, path))")
    }
}

extension FilePath {
    static func mergeRepoNameAndPath(_ repoName: RepoName, _ path: FilePath) -> FilePath {
        return FilePath("\(repoName)/\(path)")
    }

    static func splitRepoNameAndPath(_ path: FilePath) -> (RepoName, FilePath) {
        let repoName = path.components.first!.string
        return (repoName, FilePath(root: nil, path.components.dropFirst()))
    }

    static func splitRepoNameAndPath(_ pathStr: String) -> (RepoName, FilePath) {
        let path = FilePath(pathStr)
        let repoName = path.components.first!.string
        return (repoName, FilePath(root: nil, path.components.dropFirst()))
    }
}

extension NSFileProviderItemIdentifier: CustomDebugStringConvertible {
    public var debugDescription: String {
        return ItemIdentifier(self).debugDescription
    }
}
