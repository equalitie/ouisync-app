//
//  FileProviderItem.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 15/03/2024.
//

import FileProvider
import UniformTypeIdentifiers
import MessagePack

class Entry: Equatable {
    let handle: UInt64

    init(_ handle: UInt64) {
        self.handle = handle
    }

    func encode() -> String {
        return pack(MessagePackValue.uint(handle)).base64EncodedString()
    }

    static func decode(_ encoded: String) -> Entry? {
        guard let data = Data(base64Encoded: encoded) else {
            return nil
        }
        guard let (unpacked, _) = try? unpack(data) else {
            return nil
        }
        guard let(handle) = unpacked.uint64Value else {
            return nil
        }
        return Entry(handle)
    }

    static func == (lhs: Entry, rhs: Entry) -> Bool {
        return
            lhs.handle == rhs.handle
    }
}

enum ItemEnum: Equatable {
    case root
    case trash
    case workingSet
    case entry(Entry)

    func identifier() -> NSFileProviderItemIdentifier {
        switch self {
        case .root: return .rootContainer
        case .trash: return .trashContainer
        case .workingSet: return .workingSet
        case .entry(let entry): return NSFileProviderItemIdentifier(entry.encode())
        }
    }

    func toString() -> String {
        switch self {
        case .root: return ".rootContainer"
        case .trash: return ".trashContainer"
        case .workingSet: return ".workingSet"
        case .entry(let entry): return "entry-\(entry.handle)"
        }
    }
}

class FileProviderItem: NSObject, NSFileProviderItem {

    // TODO: implement an initializer to create an item from your extension's backing model
    // TODO: implement the accessors to return the values from your extension's backing model
    
    let item: ItemEnum

    init(_ entry: Entry) {
        self.item = .entry(entry)
    }

    init?(_ identifier: NSFileProviderItemIdentifier) {
        if identifier == .rootContainer {
            item = .root
            return
        } else if identifier == .trashContainer {
            item = .trash
            return
        } else if identifier == .workingSet {
            item = .workingSet
            return
        } else {
            guard let entry = Entry.decode(identifier.rawValue) else {
                return nil
            }
            item = .entry(entry)
            return
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
        return item.toString()
    }
    
    var contentType: UTType {
        return item == .root ? .folder : .plainText
    }

    // Temporary until naming is sorted
    public static func handleToName(_ handle: UInt64) -> String {
        return "ouisyncfile-\(handle)"
    }
}
