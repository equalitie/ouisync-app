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
        self.log = log
        super.init()
    }

    func invalidate() {
        // TODO: cleanup any resources
    }
    
    func item(for identifier: NSFileProviderItemIdentifier, request: NSFileProviderRequest, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) -> Progress {
        let log = self.log.child("item").trace("(\(identifier))")
        // resolve the given identifier to a record in the model
        
        let handler = { (item: NSFileProviderItem?, error: Error?) in
            if let error = error {
                log.error("Error: \(error)")
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
        let log = self.log.child("fetchContents").trace("(\(itemIdentifier))")
        // TODO: implement fetching of the contents for the itemIdentifier at the specified version
        
        guard let session = ouisyncSession else {
            log.error("Backend is unreachable")
            completionHandler(nil, nil, ExtError.backendIsUnreachable)
            return Progress()
        }

        Task {
            var srcFile: OuisyncFile? = nil

            do {
                let fileItem: FileItem
                let identifier = ItemIdentifier(itemIdentifier)

                switch identifier {
                case .file(let identifier):
                    fileItem = try await identifier.loadItem(session)
                default:
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
        let log = log.child("createItem").trace("(itemTemplate:\(itemTemplate), fields:\(fields), url:\(url as Optional), options:\(options))")

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
        case .directory(let id): parentId = id
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

                var dstFile: OuisyncFile? = nil

                switch type {
                case .file(let srcUrl):
                    dstFile = try await repo.createFile(dstPath)

                    let srcFile = try FileHandle(forReadingFrom: srcUrl)

                    var written: UInt64 = 0

                    while let data = try srcFile.read(upToCount: Self.READ_CHUNK_SIZE) {
                        try await dstFile!.write(written, data)
                        written += UInt64(exactly: data.count)!
                    }

                    let dstItem = FileItem(OuisyncFileEntry(dstPath, repo), repoName, size: written)

                    handler(dstItem, [], false, nil)
                case .folder:
                    try await repo.createDirectory(dstPath)
                    let dstItem = DirectoryItem(OuisyncDirectoryEntry(dstPath, repo), repoName)
                    handler(dstItem, [], false, nil)
                }

                if let file = dstFile {
                    try await file.close()
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
        let log = self.log.child("modifyItem").trace("(\(item), changedFields: \(changedFields))")

        let handler = { (item: NSFileProviderItem?, fields, fetch, error: Error?) in
            if let error = error {
                log.error("Error: \(error)")
            }
            completionHandler(item, fields, fetch, error)
        }

        guard let session = ouisyncSession else {
            handler(nil, [], false, ExtError.backendIsUnreachable)
            return Progress()
        }

        Task {
            do {
                var fields = changedFields
                var newItem: NSFileProviderItem = item

                if fields.contains(.filename) {
                    let id = ItemIdentifier(item.itemIdentifier)

                    let repo: OuisyncRepository
                    let repoName: String
                    let srcPath: FilePath
                    let isFile: Bool

                    switch id {
                    case .rootContainer, .trashContainer, .workingSet:
                        handler(nil, [], false, ExtError.featureNotSupported)
                        return
                    case .directory(let dir):
                        repo = try await dir.loadRepo(session)
                        srcPath = dir.path
                        repoName = dir.repoName
                        isFile = false
                    case .file(let file):
                        repo = try await file.loadRepo(session)
                        srcPath = file.path
                        repoName = file.repoName
                        isFile = true
                    }

                    var dstPath = srcPath
                    dstPath.removeLastComponent()
                    dstPath.append(item.filename)

                    try await repo.moveEntry(srcPath, dstPath)

                    fields.remove(.filename)

                    if isFile {
                        newItem = FileItem(OuisyncFileEntry(dstPath, repo), repoName, size: UInt64(exactly: item.documentSize!!)!)
                    } else {
                        newItem = DirectoryItem(OuisyncDirectoryEntry(dstPath, repo), repoName)
                    }
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
        log.trace("deleteItem(\(identifier))")

        completionHandler(NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
        return Progress()
    }
    
    func enumerator(for rawIdentifier: NSFileProviderItemIdentifier, request: NSFileProviderRequest) throws -> NSFileProviderEnumerator {
        let identifier = ItemIdentifier(rawIdentifier)

        let log = self.log.child("enumerator").trace("(\(identifier))")

        guard let session = self.ouisyncSession else {
            throw ExtError.syncAnchorExpired
        }

        return try Enumerator(identifier, session, currentAnchor, log)
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
