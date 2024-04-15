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

enum OuisyncItem: Equatable {
    case repo(RepositoryHandle)
    case entry(OuisyncEntry)

    init(_ identifier: NSFileProviderItemIdentifier) {
        let arr = identifier.rawValue.components(separatedBy: "-")
        if arr[0] == "repo" {
            self = .repo(RepositoryHandle(arr[1])!)
        } else if arr[0] == "entry" {
            var type: OuisyncEntry.EntryType

            switch arr[1] {
            case "file": type = .file
            case "directory": type = .directory
            default:
                fatalError("Invalid OuisyncEntry.EntryType")
            }

            self = .entry(OuisyncEntry(FilePath(arr[2]), type))
        }
        fatalError("Failed to parse NSFileProviderItemIdentifier into OuisyncItem")
    }

    func identifier() -> NSFileProviderItemIdentifier {
        switch self {
        case .repo(let handle): return NSFileProviderItemIdentifier("repo-\(handle)")
        case .entry(let entry):
            let typeStr: String?

            switch entry.type {
            case .file: typeStr = "file"
            case .directory: typeStr = "directory"
            }

            return NSFileProviderItemIdentifier("entry-\(typeStr!)-\(entry.path)")
        }
    }
}
enum ItemEnum: Equatable {
    case root
    case trash
    case workingSet
    case handle(OuisyncItem)

    init(_ identifier: NSFileProviderItemIdentifier) {
        switch identifier {
        case .rootContainer:
            self = .root
        case .trashContainer:
            self = .trash
        case .workingSet:
            self = .workingSet
        default:
            self = .handle(OuisyncItem(identifier))
        }
    }

    func identifier() -> NSFileProviderItemIdentifier {
        switch self {
        case .root: return .rootContainer
        case .trash: return .trashContainer
        case .workingSet: return .workingSet
        case .handle(let handle): return handle.identifier()
        }
    }

    func toString() -> String {
        switch self {
        case .root: return ".rootContainer"
        case .trash: return ".trashContainer"
        case .workingSet: return ".workingSet"
        case .handle(let handle): return "handle-\(handle)"
        }
    }

    func isHandle() -> Bool {
        switch self {
        case .handle: return true
        default: return false
        }
    }
}

class FileProviderItem: NSObject, NSFileProviderItem {
    let item: ItemEnum
    let name: String

    init(_ item: ItemEnum, _ name: String) {
        self.item = item
        self.name = name
    }

    public static func fromOuisyncRepository(_ repo: OuisyncRepository) async throws -> FileProviderItem {
        let name = try await repo.getName()
        return FileProviderItem(.handle(.repo(repo.handle)), name)
    }

    public static func fromIdentifier(_ identifier: NSFileProviderItemIdentifier, _ session: OuisyncSession?) async throws -> FileProviderItem {
        let item = ItemEnum(identifier)
        
        switch item {
        case .root: return FileProviderItem(item, ".root")
        case .trash: return FileProviderItem(item, ".trash")
        case .workingSet: return FileProviderItem(item, ".workingSet")
        case .handle(let ouisyncItem):
            switch ouisyncItem {
            case .repo(let handle):
                let repo = OuisyncRepository(handle, session!)
                let name = try await repo.getName()
                return FileProviderItem(item, name)
            case .entry(let entry):
                return FileProviderItem(item, entry.name())
            }
        }
    }

    var itemIdentifier: NSFileProviderItemIdentifier {
        return item.identifier()
    }
    
    var parentItemIdentifier: NSFileProviderItemIdentifier {
        return .rootContainer
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
        return item == .root || item.isHandle() ? .folder : .plainText
        //return item == .root ? .folder : .plainText
    }
}
