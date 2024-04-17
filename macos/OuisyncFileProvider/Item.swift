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

enum ItemEnum: CustomDebugStringConvertible {
    case repositoryList
    case trash
    case workingSet
    case entry(Entry)

    init(_ entry: Entry) {
        self = .entry(entry)
    }

    init(_ entry: FileEntry) {
        self = .entry(.file(entry))
    }

    init(_ entry: DirectoryEntry) {
        self = .entry(.directory(entry))
    }
    
    init(_ identifier: NSFileProviderItemIdentifier) {
        switch identifier {
        case .rootContainer:
            self = .repositoryList
        case .trashContainer:
            self = .trash
        case .workingSet:
            self = .workingSet
        default:
            self = .entry(Entry.deserialize(identifier.rawValue)!)
        }
    }

    func identifier() -> NSFileProviderItemIdentifier {
        switch self {
        case .repositoryList: return .rootContainer
        case .trash: return .trashContainer
        case .workingSet: return .workingSet
        case .entry(let entry): return NSFileProviderItemIdentifier(entry.serialize())
        }
    }

    func hasChildren() -> Bool {
        switch self {
        case .repositoryList: return true
        case .entry(let entry):
            return entry.hasChildren()
        default: return false
        }
    }

    var debugDescription: String {
        switch self {
        case .repositoryList:
            return "ItemEnum(.repositoryList)"
        case .trash:
            return "ItemEnum(.trash)"
        case .workingSet:
            return "ItemEnum(.workingSet)"
        case .entry(let entry):
            return "ItemEnum(.entry(\(entry.serialize())))"
        }
    }
}

class Item: NSObject, NSFileProviderItem {
    let item: ItemEnum
    let name: String

    init(_ item: ItemEnum, _ name: String) {
        self.item = item
        self.name = name
    }

    init(_ entry: OuisyncEntry) {
        self.item = .entry(Entry(entry))
        self.name = entry.name()
    }

    public static func fromOuisyncRepository(_ repo: OuisyncRepository) async throws -> Item {
        let name = try await repo.getName()
        return Item(.entry(Entry(DirectoryEntry.root(repo.handle))), name)
    }

    public static func fromIdentifier(_ identifier: NSFileProviderItemIdentifier, _ session: OuisyncSession?) async throws -> Item {
        let item = ItemEnum(identifier)
        
        switch item {
        case .repositoryList: return Item(item, ".repositoryList")
        case .trash: return Item(item, ".trash")
        case .workingSet: return Item(item, ".workingSet")
        case .entry(let entry):
            switch entry {
            case .directory(let entry):
                return Item(item, entry.name())
            case .file(let entry):
                return Item(item, entry.name())
            }
        }
    }

    var itemIdentifier: NSFileProviderItemIdentifier {
        return item.identifier()
    }
    
    var parentItemIdentifier: NSFileProviderItemIdentifier {
        switch item {
        case .repositoryList: return .rootContainer
        case .trash: return .trashContainer
        case .workingSet: return .workingSet
        case .entry(let entry):
            switch entry {
            case .file(let file):
                return ItemEnum(FileEntry(OuisyncFile.parent(file.path), file.repositoryHandle)).identifier()
            case .directory(let dir):
                guard let parentPath = OuisyncDirectory.parent(dir.path) else {
                    // It's the root of a repository so the .rootContainer
                    return .rootContainer
                }
                return ItemEnum(DirectoryEntry(parentPath, dir.repositoryHandle)).identifier()
            }
        }
    }
    
    var capabilities: NSFileProviderItemCapabilities {
        return [.allowsReading, .allowsWriting, .allowsRenaming, .allowsReparenting, .allowsTrashing, .allowsDeleting]
    }
    
    var itemVersion: NSFileProviderItemVersion {
        NSFileProviderItemVersion(contentVersion: "a content version".data(using: .utf8)!, metadataVersion: "a metadata version".data(using: .utf8)!)
    }
    
    var filename: String {
        return name
    }
    
    var contentType: UTType {
        return item.hasChildren() ? .folder : .plainText
    }
}
