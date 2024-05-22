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
    // The file path here is relative to the repository
    case directory(RepoName, FilePath)
    case file(RepoName, FilePath)

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
                self = .directory(repoName, path)
            } else if (arr[0] == "file") {
                let (repoName, path) = FilePath.splitRepoNameAndPath(String(arr[1]))
                self = .file(repoName, path)
            } else {
                fatalError("Failed to parse NSFileProviderItemIdentifier: \(serialized)")
            }
        }
    }

    public func serialize() -> NSFileProviderItemIdentifier {
        switch self {
        case .rootContainer: return .rootContainer
        case .trashContainer: return .trashContainer
        case .workingSet: return .workingSet
        case .directory(let repoName, let path): return NSFileProviderItemIdentifier("directory-\(FilePath.mergeRepoNameAndPath(repoName, path))")
        case .file(let repoName, let path): return NSFileProviderItemIdentifier("file-\(FilePath.mergeRepoNameAndPath(repoName, path))")
        }
    }

    public var debugDescription: String {
        switch self {
        case .rootContainer: return "ItemIdentifier(.rootContainer)"
        case .trashContainer: return "ItemIdentifier(.trashContainer)"
        case .workingSet: return "ItemIdentifier(.workingSet)"
        case .directory(let repoName, let path): return "ItemIdentifier(directory-\(FilePath.mergeRepoNameAndPath(repoName, path)))"
        case .file(let repoName, let path): return "ItemIdentifier(file-\(FilePath.mergeRepoNameAndPath(repoName, path)))"
        }
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
