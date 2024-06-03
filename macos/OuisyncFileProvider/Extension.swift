//
//  FileProviderExtension.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 15/03/2024.
//

import FileProvider
import OuisyncLib

class Extension: NSObject, NSFileProviderReplicatedExtension {
    static let WRITE_CHUNK_SIZE: UInt64 = 32768 // TODO: Decide on optimal value
    static let READ_CHUNK_SIZE: Int = 32768 // TODO: Decide on optimal value

    var ouisyncSession: OuisyncSession?
    var currentAnchor: UInt64 = UInt64.random(in: UInt64.min ... UInt64.max)
    let domain: NSFileProviderDomain
    let temporaryDirectoryURL: URL

    required init(domain: NSFileProviderDomain) {
        // TODO: The containing application must create a domain using
        // `NSFileProviderManager.add(_:, completionHandler:)`. The system will
        // then launch the application extension process, call
        // `FileProviderExtension.init(domain:)` to instantiate the extension
        // for that domain, and call methods on the instance.
        
        let manager = NSFileProviderManager(for: domain)!

        do {
            temporaryDirectoryURL = try manager.temporaryDirectoryURL()
        } catch {
            fatalError("Failed to get temporary directory: \(error)")
        }

        self.domain = domain
        super.init()
    }

    func invalidate() {
        // TODO: cleanup any resources
    }
    
    func item(for identifier: NSFileProviderItemIdentifier, request: NSFileProviderRequest, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) -> Progress {
        Self.log("item(\(identifier))")
        // resolve the given identifier to a record in the model
        
        guard let session = ouisyncSession else {
            completionHandler(nil, ExtError.backendIsUnreachable)
            return Progress()
        }

        Task {
            do {
                let item = try await ItemIdentifier(identifier).loadItem(session)
                completionHandler(item, nil)
            } catch let e as NSError where e.code == ExtError.noSuchItem.code {
                completionHandler(nil, e)
            } catch {
                fatalError("Unrecognized exception error:\(error) itemIdentifier:\(identifier)")
            }
        }

        return Progress()
    }
    
    func fetchContents(for itemIdentifier: NSFileProviderItemIdentifier, version requestedVersion: NSFileProviderItemVersion?, request: NSFileProviderRequest, completionHandler: @escaping (URL?, NSFileProviderItem?, Error?) -> Void) -> Progress {
        Self.log("fetchContents(\(itemIdentifier))")
        // TODO: implement fetching of the contents for the itemIdentifier at the specified version
        
        guard let session = ouisyncSession else {
            completionHandler(nil, nil, ExtError.backendIsUnreachable)
            return Progress()
        }

        SuccessfulTask {
            let fileItem: FileItem
            let identifier = ItemIdentifier(itemIdentifier)

            switch identifier {
            case .file(let identifier):
                fileItem = try await identifier.loadItem(session)
            default:
                completionHandler(nil, nil, ExtError.featureNotSupported)
                return
            }

            let file = try await fileItem.file.open()
            let url = self.makeTemporaryURL("fetchContents")

            var offset: UInt64 = 0
            var size: UInt64 = 0

            let outFile = FileOnDisk(url)

            while true {
                let data = try await file.read(offset, Self.WRITE_CHUNK_SIZE)

                let dataSize = UInt64(exactly: data.count)!
                size += dataSize

                if data.isEmpty {
                    break
                }

                if offset == 0 {
                    try outFile.write(data)
                } else {
                    try outFile.append(data)
                }

                offset += UInt64(exactly: data.count)!
            }

            fileItem.size = offset

            completionHandler(url, fileItem, nil)
        }
        return Progress()
    }
    
    func createItem(basedOn itemTemplate: NSFileProviderItem, fields: NSFileProviderItemFields, contents url: URL?, options: NSFileProviderCreateItemOptions = [], request: NSFileProviderRequest, completionHandler: @escaping (NSFileProviderItem?, NSFileProviderItemFields, Bool, Error?) -> Void) -> Progress {
        // TODO: a new item was created on disk, process the item's creation
        Self.log("createItem(itemTemplate:\(itemTemplate), fields:\(fields), url:\(url as Optional), options:\(options)")

        guard let session = ouisyncSession else {
            completionHandler(itemTemplate, [], false, ExtError.backendIsUnreachable)
            return Progress()
        }

        let dstName = itemTemplate.filename
        let parentId: DirectoryIdentifier

        switch ItemIdentifier(itemTemplate.parentItemIdentifier) {
        case .directory(let id): parentId = id
        default:
            completionHandler(nil, fields, false, ExtError.featureNotSupported)
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
                    let dstFile = try await repo.createFile(dstPath)

                    let srcFile = try FileHandle(forReadingFrom: srcUrl)

                    var written: UInt64 = 0

                    while let data = try srcFile.read(upToCount: Self.READ_CHUNK_SIZE) {
                        try await dstFile.write(written, data)
                        written += UInt64(exactly: data.count)!
                    }

                    let dstItem = FileItem(OuisyncFileEntry(dstPath, repo), repoName, size: written)

                    completionHandler(dstItem, [], false, nil)
                case .folder:
                    try await repo.createDirectory(dstPath)
                    let dstItem = DirectoryItem(OuisyncDirectoryEntry(dstPath, repo), repoName)
                    completionHandler(dstItem, [], false, nil)
                }
            } catch let error as NSError {
                completionHandler(nil, [], false, error)
            } catch {
                fatalError("Uncaught exception in createItem: \(error)")
            }
        }
        return Progress()
    }
    
    func modifyItem(_ item: NSFileProviderItem, baseVersion version: NSFileProviderItemVersion, changedFields: NSFileProviderItemFields, contents newContents: URL?, options: NSFileProviderModifyItemOptions = [], request: NSFileProviderRequest, completionHandler: @escaping (NSFileProviderItem?, NSFileProviderItemFields, Bool, Error?) -> Void) -> Progress {
        // TODO: an item was modified on disk, process the item's modification
        Self.log("modifyItem(\(item))")

        completionHandler(nil, [], false, NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
        return Progress()
    }
    
    func deleteItem(identifier: NSFileProviderItemIdentifier, baseVersion version: NSFileProviderItemVersion, options: NSFileProviderDeleteItemOptions = [], request: NSFileProviderRequest, completionHandler: @escaping (Error?) -> Void) -> Progress {
        // TODO: an item was deleted on disk, process the item's deletion
        Self.log("deleteItem(\(item))")

        completionHandler(NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
        return Progress()
    }
    
    func enumerator(for rawIdentifier: NSFileProviderItemIdentifier, request: NSFileProviderRequest) throws -> NSFileProviderEnumerator {
        let identifier = ItemIdentifier(rawIdentifier)

        Self.log("enumerator(\(identifier))")

        guard let session = self.ouisyncSession else {
            throw ExtError.syncAnchorExpired
        }

        return try Enumerator(identifier, session, currentAnchor)
    }

    static func log(_ str: String) {
        NSLog("🧩 FileProviderExtension: \(str)")
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
