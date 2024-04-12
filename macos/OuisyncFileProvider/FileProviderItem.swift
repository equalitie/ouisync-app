//
//  FileProviderItem.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 15/03/2024.
//

import FileProvider
import UniformTypeIdentifiers

enum Entry: Equatable {
    case root
    case trash
    case workingSet
    case handle(UInt64)

    init(_ handle: UInt64) {
        self = .handle(handle)
    }

    init?(_ identifier: NSFileProviderItemIdentifier) {
        if identifier == .rootContainer {
            self = .root
            return
        } else if identifier == .trashContainer {
            self = .trash
            return
        } else if identifier == .workingSet {
            self = .workingSet
            return
        } else {
            guard let handle = UInt64(identifier.rawValue) else {
                return nil
            }
            self = .handle(handle)
        }
        return nil
    }

    func identifier() -> NSFileProviderItemIdentifier {
        switch self {
        case .root: return .rootContainer
        case .trash: return .trashContainer
        case .workingSet: return .workingSet
        case .handle(let handle): return NSFileProviderItemIdentifier(String(handle))
        }
    }

    func asHandle() -> UInt64? {
        if case .handle(let handle) = self {
            return handle
        }
        return nil
    }

    func toString() -> String {
        switch self {
        case .root: return ".rootContainer"
        case .trash: return ".trashContainer"
        case .workingSet: return ".workingSet"
        case .handle(let handle): return "file-\(handle)"
        }
    }
}

class FileProviderItem: NSObject, NSFileProviderItem {

    // TODO: implement an initializer to create an item from your extension's backing model
    // TODO: implement the accessors to return the values from your extension's backing model
    
    let entry: Entry

    init(_ entry: Entry) {
        self.entry = entry
    }

    var itemIdentifier: NSFileProviderItemIdentifier {
        return entry.identifier()
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
        return entry.toString()
    }
    
    var contentType: UTType {
        return entry == Entry.root ? .folder : .plainText
    }

    // Temporary until naming is sorted
    public static func handleToName(_ handle: UInt64) -> String {
        return "ouisyncfile-\(handle)"
    }
}
