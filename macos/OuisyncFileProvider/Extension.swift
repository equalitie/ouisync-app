//
//  FileProviderExtension.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 15/03/2024.
//

import FileProvider
import OuisyncLib
import System
import OSLog

class Extension: NSObject, NSFileProviderReplicatedExtension {
    static let WRITE_CHUNK_SIZE: UInt64 = 32768 // TODO: Decide on optimal value
    static let READ_CHUNK_SIZE: Int = 32768 // TODO: Decide on optimal value

    var ouisyncSession: OuisyncSession?
    var currentAnchor: UInt64 = UInt64.random(in: UInt64.min ... UInt64.max)
    let domain: NSFileProviderDomain
    let temporaryDirectoryURL: URL
    let log: Log

    required init(domain: NSFileProviderDomain) {
        // TODO: The containing application must create a domain using
        // `NSFileProviderManager.add(_:, completionHandler:)`. The system will
        // then launch the application extension process, call
        // `FileProviderExtension.init(domain:)` to instantiate the extension
        // for that domain, and call methods on the instance.
        
        let log = Log("Extension")
        let manager = NSFileProviderManager(for: domain)!

        do {
            temporaryDirectoryURL = try manager.temporaryDirectoryURL()
        } catch {
            fatalError("Failed to get temporary directory: \(error)")
        }

        self.domain = domain
        self.log = log.level(.info)
        super.init()
    }

    func invalidate() {
        // TODO: cleanup any resources
    }
    
    func item(for identifier: NSFileProviderItemIdentifier, request: NSFileProviderRequest, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) -> Progress {
        let log = self.log.child("item").trace("invoked(\(identifier))")
        // resolve the given identifier to a record in the model
        
        let handler = { (item: NSFileProviderItem?, error: Error?) in
            if let error = error {
                log.error("Error: \(error)")
            } else {
                log.trace("Returning \(item as Optional)")
            }
            completionHandler(item, error)
        }

        guard let session = ouisyncSession else {
            handler(nil, ExtError.backendIsUnreachable)
            return Progress()
        }

        Task {
            do {
                let item = try await ItemIdentifier(identifier).loadItem(session)
                handler(item, nil)
            } catch let e as NSError where e.code == ExtError.noSuchItem.code {
                handler(nil, e)
            } catch {
                fatalError("Unrecognized exception error:\(error) itemIdentifier:\(identifier)")
            }
        }

        return Progress()
    }
    
    func fetchContents(for itemIdentifier: NSFileProviderItemIdentifier, version requestedVersion: NSFileProviderItemVersion?, request: NSFileProviderRequest, completionHandler: @escaping (URL?, NSFileProviderItem?, Error?) -> Void) -> Progress {
        let log = self.log.child("fetchContents").trace("invoked(\(itemIdentifier))")
        // TODO: implement fetching of the contents for the itemIdentifier at the specified version
        
        guard let session = ouisyncSession else {
            log.error("Backend is unreachable")
            completionHandler(nil, nil, ExtError.backendIsUnreachable)
            return Progress()
        }

        Task {
            var srcFile: OuisyncFile? = nil

            do {
                let identifier = ItemIdentifier(itemIdentifier)

                guard let fileItem = try await identifier.asFile()?.loadItem(session) else {
                    completionHandler(nil, nil, ExtError.featureNotSupported)
                    return
                }

                srcFile = try await fileItem.file.open()
                let url = self.makeTemporaryURL("fetchContents")

                var offset: UInt64 = 0
                var size: UInt64 = 0

                let dstFile = FileOnDisk(url)

                while true {
                    let data = try await srcFile!.read(offset, Self.WRITE_CHUNK_SIZE)

                    let dataSize = UInt64(exactly: data.count)!
                    size += dataSize

                    if data.isEmpty {
                        break
                    }

                    if offset == 0 {
                        try dstFile.write(data)
                    } else {
                        try dstFile.append(data)
                    }

                    offset += UInt64(exactly: data.count)!
                }

                fileItem.size = offset

                completionHandler(url, fileItem, nil)
            } catch let error as NSError {
                log.error("Error: \(error)")
                completionHandler(nil, nil, error)
            } catch {
                fatalError("Uncaught exception: \(error)")
            }

            do {
                if let f = srcFile {
                    try await f.close()
                }
            } catch {
                log.error("Failed to close OuisyncFile: \(error)")
            }
        }
        return Progress()
    }
    
    func createItem(basedOn itemTemplate: NSFileProviderItem, fields: NSFileProviderItemFields, contents url: URL?, options: NSFileProviderCreateItemOptions = [], request: NSFileProviderRequest, completionHandler: @escaping (NSFileProviderItem?, NSFileProviderItemFields, Bool, Error?) -> Void) -> Progress {
        // TODO: a new item was created on disk, process the item's creation
        let log = log.child("createItem").trace("invoked(itemTemplate:\(itemTemplate), fields:\(fields), url:\(url as Optional), options:\(options))")

        let handler = { (item: NSFileProviderItem?, fields: NSFileProviderItemFields, fetch: Bool, error: Error?) in
            if let error = error {
                log.error("Error: \(error)")
            }
            completionHandler(item, fields, fetch, error)
        }

        guard let session = ouisyncSession else {
            handler(itemTemplate, [], false, ExtError.backendIsUnreachable)
            return Progress()
        }

        let dstName = itemTemplate.filename
        let parentId: DirectoryIdentifier

        switch ItemIdentifier(itemTemplate.parentItemIdentifier) {
        case .entry(let entry):
            switch entry {
            case .directory(let id): parentId = id
            case .file: fatalError("Parent can't be a file")
            }
        default:
            handler(nil, fields, false, ExtError.featureNotSupported)
            return Progress()
        }

        enum Type {
            case file(URL)
            case folder
        }

        let type: Type

        // TODO: I don't know if this logic is correct
        if let templateType = itemTemplate.contentType, templateType == .folder {
            type = .folder
        } else if let u = url {
            type = .file(u)
        } else {
            type = .folder
        }

        Task {
            do {
                let repoName = parentId.repoName
                let repo = try await parentId.loadRepo(session)
                let dstPath = parentId.path.appending(dstName)

                switch type {
                case .file(let srcUrl):
                    let (written, version) = try await copyContentsAndClose(srcUrl, repo.fileEntry(dstPath), true)
                    let dstItem = FileItem(repo.fileEntry(dstPath), repoName, size: written, version: version)

                    handler(dstItem, [], false, nil)
                case .folder:
                    try await repo.createDirectory(dstPath)
                    let dstItem = DirectoryItem(repo.directoryEntry(dstPath), repoName)
                    handler(dstItem, [], false, nil)
                }
            } catch let error as NSError {
                handler(nil, [], false, error)
            } catch {
                fatalError("Uncaught exception in createItem: \(error)")
            }
        }
        return Progress()
    }
    
    func modifyItem(_ item: NSFileProviderItem, baseVersion version: NSFileProviderItemVersion, changedFields: NSFileProviderItemFields, contents newContents: URL?, options: NSFileProviderModifyItemOptions = [], request: NSFileProviderRequest, completionHandler: @escaping (NSFileProviderItem?, NSFileProviderItemFields, Bool, Error?) -> Void) -> Progress {
        // TODO: an item was modified on disk, process the item's modification
        let log = self.log.child("modifyItem").trace("invoked(\(item), changedFields: \(changedFields))")

        let handler = { (item: NSFileProviderItem?, fields: NSFileProviderItemFields, fetch, error: Error?) in
            if let error = error {
                log.error("Error: \(error)")
            } else {
                log.trace("Returning: item:\(item as Optional) fields:\(fields)")
            }
            completionHandler(item, fields, fetch, error)
        }

        guard let session = ouisyncSession else {
            handler(nil, [], false, ExtError.backendIsUnreachable)
            return Progress()
        }

        Task {
            do {
                let id = ItemIdentifier(item.itemIdentifier)
                var fields = changedFields
                var newItem: NSFileProviderItem = item

                if fields.contains(.filename) /* rename */ || fields.contains(.parentItemIdentifier) /* move */ {
                    let parentId = ItemIdentifier(item.parentItemIdentifier)

                    let dstParentPath: FilePath
                    let src: EntryIdentifier

                    switch (id, parentId) {
                    case (.rootContainer, _),
                         (.workingSet, _),
                         (.trashContainer, _),
                         (_, .rootContainer),
                         (_, .workingSet),
                         (_, .trashContainer):
                        handler(nil, [], false, ExtError.featureNotSupported)
                        return
                    case (.entry(let entry), .entry(.directory(let dstDir))):
                        src = entry
                        // TODO: Check that the source and destination repo is the same
                        dstParentPath = dstDir.path
                    case (_, .entry(.file(_))):
                        fatalError("Cannot move an entry to a file parent")
                    }

                    let repo = try await src.loadRepo(session)
                    let dstPath = dstParentPath.appending(item.filename)

                    try await repo.moveEntry(src.path(), dstPath)

                    fields.remove(.filename)
                    fields.remove(.parentItemIdentifier)

                    switch src.type() {
                    case .file:
                        newItem = try await FileIdentifier(dstPath, src.repoName()).loadItem(repo)
                    case .directory:
                        newItem = DirectoryItem(repo.directoryEntry(dstPath), src.repoName())
                    }
                }

                if fields.contains(.contents) {
                    let srcUrl = newContents!
                    let entry: OuisyncFileEntry
                    let repoName: String

                    switch id {
                    case .rootContainer, .workingSet, .trashContainer:
                        handler(nil, [], false, ExtError.featureNotSupported)
                        return
                    case .entry(.directory):
                        fatalError("Cannot change contents of a directory")
                    case .entry(.file(let fileId)):
                        repoName = fileId.repoName
                        entry = try await fileId.loadEntry(session)
                    }

                    let (written, version) = try await copyContentsAndClose(srcUrl, entry, false)

                    fields.remove(.contents)

                    newItem = FileItem(entry, repoName, size: written, version: version)
                }

                handler(newItem, fields, false, nil)
            } catch let error as NSError {
                handler(nil, [], false, error)
            } catch {
                fatalError("Uncaught exception in createItem: \(error)")
            }
        }

        return Progress()
    }
    
    func deleteItem(identifier: NSFileProviderItemIdentifier, baseVersion version: NSFileProviderItemVersion, options: NSFileProviderDeleteItemOptions = [], request: NSFileProviderRequest, completionHandler: @escaping (Error?) -> Void) -> Progress {
        // TODO: an item was deleted on disk, process the item's deletion
        let log = log.child("deleteItem").trace("invoked(\(identifier))")

        let handler = { (error: Error?) in
            if let error = error {
                log.error("\(error)")
            }
            completionHandler(error)
        }

        guard let session = ouisyncSession else {
            handler(ExtError.backendIsUnreachable)
            return Progress()
        }

        Task {
            do {
                switch ItemIdentifier(identifier) {
                case .rootContainer, .trashContainer, .workingSet:
                    throw ExtError.featureNotSupported
                case .entry(.file(let file)):
                    let path = file.path
                    let repo = try await file.loadRepo(session)
                    try await repo.deleteFile(path)
                case .entry(.directory(let dir)):
                    let path = dir.path
                    let repo = try await dir.loadRepo(session)
                    try await repo.deleteDirectory(path, recursive: true)
                }

                handler(nil)
            } catch let error as NSError {
                handler(error)
            } catch {
                fatalError("Uncaught exception in deleteItem: \(error)")
            }
        }

        return Progress()
    }
    
    func enumerator(for rawIdentifier: NSFileProviderItemIdentifier, request: NSFileProviderRequest) throws -> NSFileProviderEnumerator {
        let identifier = ItemIdentifier(rawIdentifier)

        let log = self.log.child("enumerator").level(.error).trace("invoked(\(identifier))")

        guard let session = self.ouisyncSession else {
            let error = ExtError.backendIsUnreachable
            log.error("\(error)")
            throw error
        }

        return Enumerator(identifier, session, currentAnchor, log)
    }

    // When the system requests to fetch a content from Ouisync, we create a temporary file at the URL location
    // and write the content there. Then pass that URL to a completion handler.
    func makeTemporaryURL(_ purpose: String) -> URL {
        return temporaryDirectoryURL.appendingPathComponent("\(purpose)-\(UUID().uuidString)")
    }
}
 
// TODO: I just couldn't find a sane way to write and append to a file in Swift
class FileOnDisk {
    let url: URL
    var handle: Foundation.FileHandle?

    init(_ url: URL) {
        self.url = url
    }

    func write(_ data: Data) throws {
        try data.write(to: url)
    }

    func append(_ data: Data) throws {
        if let h = getFileHandle() {
            h.seekToEndOfFile()
            h.write(data)
        }
        else {
            try data.write(to: url, options: .atomic)
        }
    }

    private func getFileHandle() -> Foundation.FileHandle? {
        if let h = handle {
            return h
        } else {
            handle = FileHandle(forWritingAtPath: url.path)
            return handle
        }
    }
}

// Returns number of bytes written and version vector hash
func copyContentsAndClose(_ src: URL, _ dstEntry: OuisyncFileEntry, _ createDst: Bool) async throws -> (UInt64, Version) {
    let srcFile = try FileHandle(forReadingFrom: src)

    var written: UInt64 = 0

    var dst: OuisyncFile

    if createDst {
        dst = try await dstEntry.create()
    } else {
        dst = try await dstEntry.open()
        try await dst.truncate(0)
    }

    while true {
        let readResult = Result { try srcFile.read(upToCount: Extension.READ_CHUNK_SIZE) }
        switch readResult {
        case .failure(let error):
            try? await dst.close()
            throw error
        case .success(let data):
            guard let data = data else {
                // TODO: We are getting a version of the file after we've written to it,
                // that may lead to race conditions where after our writing someone else
                // writes to it and we get the version hash after the second write. If that
                // happens File Provider won't notice that other change.
                let version = try await dstEntry.getVersionHash()
                try await dst.close()
                return (written, Version(Hash(version), written))
            }
            try await dst.write(written, data)
            written += UInt64(exactly: data.count)!
        }
    }
}
