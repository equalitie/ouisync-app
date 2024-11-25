//
//  DeserializedIdentifier.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 22/05/2024.
//
import FileProvider
import Foundation
import OuisyncLib
import System // for FilePath


typealias RepoName = String


enum ItemIdentifier: CustomDebugStringConvertible, Hashable, Equatable {
    case rootContainer
    case trashContainer
    case workingSet
    case entry(EntryIdentifier)

    init(_ serialized: NSFileProviderItemIdentifier) {
        guard let deserialized = Self.tryDeserialize(serialized) else {
            fatalError("Failed to parse NSFileProviderItemIdentifier: \(serialized)")
        }
        self = deserialized
    }

    init(_ ouisyncEntry: OuisyncEntry, _ repoName: RepoName) {
        switch ouisyncEntry {
        case .directory(let entry): self = .entry(DirectoryIdentifier(entry.path, repoName).entry())
        case .file(let entry): self = .entry(FileIdentifier(entry.path, repoName).entry())
        }
    }

    init(_ entryId: EntryIdentifier) {
        self = .entry(entryId)
    }

    static func tryDeserialize(_ serialized: NSFileProviderItemIdentifier) -> Self? {
        switch serialized {
        case .rootContainer:
            return .rootContainer
        case .trashContainer:
            return .trashContainer
        case .workingSet:
            return .workingSet
        default:
            let entry: EntryIdentifier? =
                try? JSONDecoder()
                    .decode(EntryIdentifier.self, from: serialized.rawValue.data(using: .utf8)!)

            guard let entry = entry else { return nil }

            return .entry(entry)
        }
    }

    public func serialize() -> NSFileProviderItemIdentifier {
        switch self {
        case .rootContainer: return .rootContainer
        case .trashContainer: return .trashContainer
        case .workingSet: return .workingSet
        case .entry(let entry):
            let encoder = JSONEncoder()
            // Without .sortedKeys the encoder would encode the keys in a random order, but
            // the system expects consistent strings to identify items. With .sortedKeys
            // the resulting string is deterministic.
            encoder.outputFormatting = .sortedKeys
            // We don't expect this to fail
            let json = try! encoder.encode(entry)
            let str = String(data: json, encoding: .utf8)
            return NSFileProviderItemIdentifier(str!)
        }
    }

    public func asFile() -> FileIdentifier? {
        switch self {
        case .entry(.file(let file)): return file
        default: return nil
        }
    }

    public func isRepository() -> Bool {
        switch self {
        case .entry(.directory(let dir)): return dir.isRepository()
        default: return false
        }
    }

    public var debugDescription: String {
        switch self {
        case .rootContainer: return ".rootContainer"
        case .trashContainer: return ".trashContainer"
        case .workingSet: return ".workingSet"
        case .entry(let entry): return entry.debugDescription
        }
    }
}

enum EntryIdentifier: CustomDebugStringConvertible, Codable, Equatable, Hashable {
    case file(FileIdentifier)
    case directory(DirectoryIdentifier)

    init(_ file: FileIdentifier) {
        self = .file(file)
    }

    init(_ dir: DirectoryIdentifier) {
        self = .directory(dir)
    }

    func loadItem(_ session: OuisyncSession) async throws -> NSFileProviderItem {
        switch self {
        case .file(let id): return try await id.loadItem(session)
        case .directory(let id): return try await id.loadItem(session)
        }
    }

    func loadItem(_ repo: OuisyncRepository) async throws -> NSFileProviderItem {
        switch self {
        case .file(let id): return try await id.loadItem(repo)
        case .directory(let id): return try await id.loadItem(repo)
        }
    }

    func loadRepo(_ session: OuisyncSession) async throws -> OuisyncRepository {
        switch self {
        case .file(let id): return try await id.loadRepo(session)
        case .directory(let id): return try await id.loadRepo(session)
        }
    }

    func path() -> FilePath {
        switch self {
        case .file(let id): return id.path
        case .directory(let id): return id.path
        }
    }

    func repoName() -> String {
        switch self {
        case .file(let id): return id.repoName
        case .directory(let id): return id.repoName
        }
    }

    public func type() -> OuisyncEntryType {
        switch self {
        case .file: return .file
        case .directory: return .directory
        }
    }

    public var debugDescription: String {
        switch self {
        case .file(let file): return file.debugDescription
        case .directory(let dir): return dir.debugDescription
        }
    }

    func item() -> ItemIdentifier {
        ItemIdentifier(self)
    }
}

struct FileIdentifier: CustomDebugStringConvertible, Codable, Hashable, Equatable {
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

        return try await loadItem(repo)
    }

    func loadItem(_ repo: OuisyncRepository) async throws -> FileItem {
        let entry = OuisyncFileEntry(path, repo)

        var file: OuisyncFile? = nil
        var size: UInt64 = 0

        // When a directory lists a file Ouisync may not yet have it and thus it may not
        // be able to determine it's size. The FileItem we want to return here doesn't
        // require a OuisyncFile, so we may still proceed as if the file was there but
        // with size == 0.
        do {
            file = try await entry.open()
            size = try await file!.size()
            try await file!.close()
        } catch let error as OuisyncError {
            if error.code == .EntryNotFound {
                throw ExtError.noSuchItem
            } else if error.code == .Store {
                // We likely don't yet have the first block which tells us the file size
                size = 0
            } else {
                fatalError("Unhandled Ouisync error:\(error), repo:\(repoName), path:\(path)")
            }
        } catch {
            fatalError("Unhandled exception error:\(error), repo:\(repoName), path:\(path)")
        }

        var version = Version.invalid()

        do {
            // If the file is open returning it's version vector hash should succeed because
            // that information is stored in that file's parent directory.
            version = Version(Hash(try await entry.getVersionHash()), size)
        } catch let error as OuisyncError where error.code == OuisyncErrorCode.Store {
            NSLog("WARNING: Block to file not found")
        } catch let error as OuisyncError where error.code == OuisyncErrorCode.EntryNotFound {
            throw ExtError.noSuchItem.from("\(self):L\(#line)")
        } catch {
            fatalError("Unhandled exception when retrieving file version:\(error)")
        }

        return FileItem(entry, repoName, size: size, version: version)
    }

    func loadEntry(_ session: OuisyncSession) async throws -> OuisyncFileEntry {
        guard let repo = await getRepoByName(session, repoName) else {
            throw ExtError.noSuchItem
        }

        return OuisyncFileEntry(path, repo)
    }

    func loadRepo(_ session: OuisyncSession) async throws -> OuisyncRepository {
        guard let repo = await getRepoByName(session, repoName) else {
            throw ExtError.noSuchItem
        }
        return repo
    }

    func entry() -> EntryIdentifier {
        EntryIdentifier(self)
    }

    func item() -> ItemIdentifier {
        ItemIdentifier(entry())
    }

    public var debugDescription: String {
        ".file(\(repoName)\(path.isEmpty ? "" : "/")\(path))"
    }
}

struct DirectoryIdentifier: CustomDebugStringConvertible, Codable, Hashable, Equatable {
    // The file path is relative to the repository
    let path: FilePath
    let repoName: RepoName

    init(_ path: FilePath, _ repoName: RepoName) {
        self.path = path
        self.repoName = repoName
    }

    public func isRepository() -> Bool {
        path.components.isEmpty
    }

    func loadItem(_ session: OuisyncSession) async throws -> DirectoryItem {
        let repo = try await loadRepo(session)
        return try await loadItem(repo)
    }

    func loadItem(_ repo: OuisyncRepository) async throws -> DirectoryItem {
        let entry = OuisyncDirectoryEntry(path, repo)

        if try await entry.exists() == false {
            throw ExtError.noSuchItem
        }

        return try await DirectoryItem.load(OuisyncDirectoryEntry(path, repo), repoName)
    }

    func loadRepo(_ session: OuisyncSession) async throws -> OuisyncRepository {
        guard let repo = await getRepoByName(session, repoName) else {
            throw ExtError.noSuchItem
        }
        return repo
    }

    func listEntries(_ session: OuisyncSession) async throws -> [EntryIdentifier] {
        let repo = try await loadRepo(session)
        let entry = OuisyncDirectoryEntry(path, repo)
        return try await entry.listEntries().map { e in
            switch e {
            case .directory(let dirEntry): return EntryIdentifier(DirectoryIdentifier(dirEntry.path, repoName))
            case .file(let fileEntry): return EntryIdentifier(FileIdentifier(fileEntry.path, repoName))
            }
        }
    }

    func entry() -> EntryIdentifier {
        EntryIdentifier(self)
    }

    func item() -> ItemIdentifier {
        ItemIdentifier(entry())
    }

    public var debugDescription: String {
        ".directory(\(repoName)\(path.isEmpty ? "" : "/")\(path))"
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
