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

enum ItemEnum: Equatable {
    case root
    case trash
    case workingSet
    case handle(RepositoryHandle)

    func identifier() -> NSFileProviderItemIdentifier {
        switch self {
        case .root: return .rootContainer
        case .trash: return .trashContainer
        case .workingSet: return .workingSet
        case .handle(let handle): return NSFileProviderItemIdentifier(String(handle))
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
        return FileProviderItem(.handle(repo.handle), name)
    }

    public static func fromIdentifier(_ identifier: NSFileProviderItemIdentifier, _ session: OuisyncSession?) async throws -> FileProviderItem {
        if identifier == .rootContainer {
            return FileProviderItem(.root, ".root")
        } else if identifier == .trashContainer {
            return FileProviderItem(.trash, ".trash")
        } else if identifier == .workingSet {
            return FileProviderItem(.workingSet, ".workingSet")
        } else {
            let handle = RepositoryHandle(identifier.rawValue)!
            let repo = OuisyncRepository(handle, session!)
            let name = try await repo.getName()
            return FileProviderItem(.handle(handle), name)
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
        return item == .root ? .folder : .plainText
    }
}
