//
//  FileProviderExtension.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 15/03/2024.
//
import FileProvider
import Network
import OuisyncLib
import OuisyncCommon
import OSLog
import System


open class Extension: NSObject, NSFileProviderReplicatedExtension {
    static let WRITE_CHUNK_SIZE: UInt64 = 32768 // TODO: Decide on optimal value
    static let READ_CHUNK_SIZE: Int = 32768 // TODO: Decide on optimal value

    // The Ouisync service now runs out of process and `Session.create` is async, so we can't
    // create the session synchronously in `init`. Instead we lazily create it (once) on first use
    // via a cached `Task`. WARN: only mutate `ouisyncSessionTask` while holding a lock on self.
    var ouisyncSessionTask: Task<Session, Error>? = nil
    let anchorGenerator: AnchorGenerator = AnchorGenerator()
    var currentAnchor: NSFileProviderSyncAnchor
    let domain: NSFileProviderDomain
    let temporaryDirectoryURL: URL
    let log: Log
    let pastEnumerations: PastEnumerations?
    let manager: NSFileProviderManager

    public required init(domain: NSFileProviderDomain) {
        // TODO: The containing application must create a domain using
        // `NSFileProviderManager.add(_:, completionHandler:)`. The system will
        // then launch the application extension process, call
        // `FileProviderExtension.init(domain:)` to instantiate the extension
        // for that domain, and call methods on the instance.

        let log = Log("Extension")
        self.manager = NSFileProviderManager(for: domain)!

        do {
            temporaryDirectoryURL = try manager.temporaryDirectoryURL()
        } catch {
            fatalError("Failed to get temporary directory: \(error)")
        }

        currentAnchor = anchorGenerator.generate()

        // Path that is accessible by both the app and this extension.

        NSLog("-------------------------------------------------")
        NSLog("Using directories:")
        NSLog("configs:      \(Directories.configsPath)")
        NSLog("repositories: \(Directories.repositoriesPath)")
        NSLog("logs:         \(Directories.logsPath)")
        NSLog("-------------------------------------------------")

        // NOTE: the session is created lazily (see `getSession()`); we intentionally do NOT block
        // `init` on the async `Session.create`.

        // TODO: This doesn't work yet
        //pastEnumerations = PastEnumerations()
        pastEnumerations = nil

        self.domain = domain
        self.log = log.level(.trace)
        super.init()

        startListeningToRepoChanges()
    }

    // Lazily create (once) and return the shared Ouisync session. The service runs out of process
    // and is reached as a TCP client via `Session.create(configPath:)`.
    func getSession() async throws -> Session {
        let task: Task<Session, Error> = synchronized(self) {
            if let existing = self.ouisyncSessionTask {
                return existing
            }
            let created = Task { try await Session.create(configPath: Directories.configsPath) }
            self.ouisyncSessionTask = created
            return created
        }
        return try await task.value
    }

    // Start watchin to changes in Ouisync: Everytime a repository is added or removed, and
    // everytime a repository changes we ask the file provider to refresh it's content.
    func startListeningToRepoChanges() {
        let log = self.log.child("RepoChange")
        let this = self

        // TODO(stopgap): polling; new API has no repo-list-change stream.
        // The old in-process API exposed `subscribeToRepositoryListChange()`; the new client/service
        // API does not, so we poll `listRepositories()` on an interval instead. Repositories are now
        // keyed by name (there is no exposed `RepositoryHandle`), so the watch tasks are keyed by name.
        //
        // TODO:
        // 1. Need to ensure that the task finishes when the extension is `invalidate`d
        // 2. Check that repos are removed from `repoWatchingTasks` when a repo is removed.
        Task {
            weak var weakExt = this

            let session: Session
            do {
                guard let ext = weakExt else { return }
                session = try await ext.getSession()
            } catch {
                return
            }

            var repoWatchingTasks: [RepoName: Task<Void, Never>] = [:]

            while true {
                guard let ext = weakExt else {
                    NSLog("❗Stopping the refresh of repo changes because the extension was destroyed")
                    for (_, task) in repoWatchingTasks { task.cancel() }
                    return
                }

                let currentRepos: [RepoName: Repository]

                do {
                    currentRepos = try await session.listRepositories()
                } catch is OuisyncError {
                    // The new API has no exact equivalent of the old `.ConnectionLost`; treat any
                    // Ouisync error here as "stop the loop" rather than crashing.
                    for (_, task) in repoWatchingTasks { task.cancel() }
                    return
                } catch {
                    fatalError("😡 Unexpected exception: \(error)")
                }

                let watchedRepoNames = Set(repoWatchingTasks.keys)
                let currentRepoNames = Set(currentRepos.keys)

                let reposToAdd = currentRepoNames.subtracting(watchedRepoNames)
                let reposToRemove = watchedRepoNames.subtracting(currentRepoNames)

                for name in reposToAdd {
                    guard let repo = currentRepos[name] else { continue }
                    guard let stream = try? await repo.subscribe() else {
                        continue
                    }
                    log.info("Added repository \(name)")
                    repoWatchingTasks[name] = Task {
                        weak var weakExt = this
                        for await _ in stream {
                            guard let ext = weakExt else {
                                return
                            }
                            await ext.signalRefresh()
                        }
                    }
                }

                for name in reposToRemove {
                    log.info("Removed repository \(name)")
                    if let task = repoWatchingTasks.removeValue(forKey: name) {
                        task.cancel()
                    }
                }

                if !reposToAdd.isEmpty || !reposToRemove.isEmpty {
                    await ext.signalRefresh()
                }

                // Poll for repository-list changes.
                do {
                    try await Task.sleep(nanoseconds: 3_000_000_000)
                } catch {
                    return
                }
            }
        }
    }

    // WARN: only mutate these while holding a lock on self
    var active = true // this is set to false when shutting down
    var invalidators: [@Sendable () async -> Void] = [] // list of things called on invalidate(); only append if active = true!
    public func invalidate() {
        let active = synchronized(self) {
            defer { self.active = false }
            return self.active
        }
        guard active else { return }
        Task {
            NSLog("👋 The File Provider extension is shutting down")
            let sessionTask = synchronized(self) { self.ouisyncSessionTask }
            if let session = try? await sessionTask?.value {
                await session.close()
            }
            await withTaskGroup(of: Void.self) {
                for invalidator in invalidators {
                    $0.addTask(operation: invalidator)
                }
                invalidators.removeAll() // just in case they were holding strong refs
            }
        }
    }
    
    public func item(for identifier: NSFileProviderItemIdentifier, request: NSFileProviderRequest, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) -> Foundation.Progress {
        let log = self.log.child("item").trace("invoked(\(identifier))")

        let handler = { (item: NSFileProviderItem?, error: Error?) in
            if let error = error {
                log.error("Error: \(error)")
            } else {
                log.trace("Returning \(item as Optional)")
            }
            completionHandler(item, error)
        }

        Task {
            do {
                let item: NSFileProviderItem
                switch ItemIdentifier(identifier) {
                case .rootContainer: item = RootContainerItem(currentAnchor)
                case .trashContainer: item = TrashContainerItem()
                case .workingSet: item = WorkingSetItem(currentAnchor)
                case .entry(let entry): item = try await entry.loadItem(getSession())
                }
                handler(item, nil)
            } catch let e as NSError where e.code == ExtError.noSuchItem.code {
                handler(nil, e)
            } catch {
                fatalError("Unrecognized exception error:\(error) itemIdentifier:\(identifier)")
            }
        }

        return Foundation.Progress()
    }
    
    public func fetchContents(for itemIdentifier: NSFileProviderItemIdentifier, version requestedVersion: NSFileProviderItemVersion?, request: NSFileProviderRequest, completionHandler: @escaping (URL?, NSFileProviderItem?, Error?) -> Void) -> Foundation.Progress {
        let log = self.log.child("fetchContents").info("invoked(\(itemIdentifier), \(requestedVersion.flatMap{Version($0)} as Optional)")
        // TODO: implement fetching of the contents for the itemIdentifier at the specified version
        
        let handler = { (url: URL?, item: NSFileProviderItem?, error: Error?) in

            if let error = error {
                log.error("\(error)")
            }
            completionHandler(url, item, error)
        }

        let progress = Foundation.Progress()

        Task {
            var srcFile: File? = nil

            var retError: NSFileProviderError? = nil
            var retUrl: URL? = nil
            var retFileItem: FileItem? = nil

            var offset: UInt64 = 0

            do {
                let session = try await getSession()
                let identifier = ItemIdentifier(itemIdentifier)

                guard let fileId = identifier.asFile() else {
                    handler(nil, nil, ExtError.featureNotSupported)
                    return
                }
                let repo = try await fileId.loadRepo(session)
                let fileItem = try await fileId.loadItem(repo)
                retFileItem = fileItem

                progress.totalUnitCount = Int64(fileItem.size)

                let url = self.makeTemporaryURL("fetchContents")
                retUrl = url

                let dstFile = FileOnDisk(url)

                try dstFile.write(Data())

                do {
                    srcFile = try await repo.openFile(fileItem.path.string)
                } catch let error as OuisyncError where error.code == .storeError {
                    fileItem.size = 0
                    handler(url, fileItem, nil)
                    return
                }

                while true {
                    let data = try await srcFile!.read(offset, Self.WRITE_CHUNK_SIZE)

                    if data.isEmpty {
                        break
                    }

                    try dstFile.append(data)


                    offset += UInt64(exactly: data.count)!
                    progress.completedUnitCount = Int64(offset)

                    if progress.isCancelled {
                        break
                    }
                }

            } catch let error as NSFileProviderError {
                retError = error
            } catch let error as OuisyncError where error.code == ErrorCode.storeError && retFileItem != nil {
                // Ignore, we'll return whatever we wrote to the temporary file (if anything)
            } catch {
                fatalError("Uncaught exception: \(error)")
            }

            do {
                if let f = srcFile {
                    try await f.close()
                }
            } catch {
                log.error("Failed to close File: \(error)")
            }

            if let error = retError {
                handler(nil, nil, error)
            } else {
                retFileItem!.size = offset
                handler(retUrl!, retFileItem!, nil)
            }
        }

        return progress
    }
    
    public func createItem(basedOn itemTemplate: NSFileProviderItem, fields: NSFileProviderItemFields, contents url: URL?, options: NSFileProviderCreateItemOptions = [], request: NSFileProviderRequest, completionHandler: @escaping (NSFileProviderItem?, NSFileProviderItemFields, Bool, Error?) -> Void) -> Foundation.Progress {
        // TODO: a new item was created on disk, process the item's creation
        let log = log.child("createItem").trace("invoked(itemTemplate:\(itemTemplate), fields:\(fields), url:\(url as Optional), options:\(options))")

        let handler = { (item: NSFileProviderItem?, fields: NSFileProviderItemFields, fetch: Bool, error: Error?) in
            if let error = error {
                log.error("Error: \(error)")
            }
            completionHandler(item, fields, fetch, error)
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
            return Foundation.Progress()
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
                let repo = try await parentId.loadRepo(getSession())
                let dstPath = parentId.path.appending(dstName)

                switch type {
                case .file(let srcUrl):
                    let (written, version) = try await copyContentsAndClose(srcUrl, repo, dstPath, true)
                    let dstItem = FileItem(dstPath, repoName, size: written, version: version)

                    handler(dstItem, [], false, nil)
                case .folder:
                    try await repo.createDirectory(dstPath.string)
                    let dstItem = try await DirectoryItem.load(repo, dstPath, repoName)
                    handler(dstItem, [], false, nil)
                }
            } catch let error as NSFileProviderError {
                handler(nil, [], false, error)
            } catch {
                fatalError("Uncaught exception in createItem: \(error)")
            }
        }
        return Foundation.Progress()
    }
    
    public func modifyItem(_ item: NSFileProviderItem, baseVersion version: NSFileProviderItemVersion, changedFields: NSFileProviderItemFields, contents newContents: URL?, options: NSFileProviderModifyItemOptions = [], request: NSFileProviderRequest, completionHandler: @escaping (NSFileProviderItem?, NSFileProviderItemFields, Bool, Error?) -> Void) -> Foundation.Progress {
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

        Task {
            do {
                let session = try await getSession()
                let id = ItemIdentifier(item.itemIdentifier)
                var fields = changedFields
                var newItem: NSFileProviderItem? = nil

                if fields.contains(.filename) /* rename */ || fields.contains(.parentItemIdentifier) /* move */ {
                    log.info("Requested rename or move \(id)")
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

                    try await repo.moveEntry(src.path().string, dstPath.string)

                    fields.remove(.filename)
                    fields.remove(.parentItemIdentifier)

                    switch src.type() {
                    case .file:
                        newItem = try await FileIdentifier(dstPath, src.repoName()).loadItem(repo)
                    case .directory:
                        newItem = try await DirectoryIdentifier(dstPath, src.repoName()).loadItem(repo)
                    }
                }

                if fields.contains(.contents) {
                    log.info("Requested content change \(id)")
                    let srcUrl = newContents!
                    let repo: Repository
                    let filePath: FilePath
                    let repoName: String

                    switch id {
                    case .rootContainer, .workingSet, .trashContainer:
                        handler(nil, [], false, ExtError.featureNotSupported)
                        return
                    case .entry(.directory):
                        fatalError("Cannot change contents of a directory")
                    case .entry(.file(let fileId)):
                        repoName = fileId.repoName
                        filePath = fileId.path
                        repo = try await fileId.loadRepo(session)
                    }

                    let (written, version) = try await copyContentsAndClose(srcUrl, repo, filePath, false)

                    fields.remove(.contents)

                    newItem = FileItem(filePath, repoName, size: written, version: version)
                }

                if newItem == nil {
                    // We can't return the item that was passed to us because the system expects the version
                    // (and possibly other things as well) to have been changed.
                    // https://stackoverflow.com/questions/74490453/why-is-fetchcontents-called-when-opening-an-already-materialized-file

                    let entryId: EntryIdentifier

                    switch id {
                    case .rootContainer, .workingSet, .trashContainer:
                        fatalError("TODO?")
                    case .entry(.directory(let dirId)):
                        entryId = EntryIdentifier(dirId)
                    case .entry(.file(let fileId)):
                        entryId = EntryIdentifier(fileId)
                    }

                    newItem = try await entryId.loadItem(session)
                }

                handler(newItem, fields, false, nil)
            } catch let error as NSFileProviderError {
                handler(nil, [], false, error)
            } catch {
                fatalError("Uncaught exception in createItem: \(error)")
            }
        }

        return Foundation.Progress()
    }
    
    public func deleteItem(identifier: NSFileProviderItemIdentifier, baseVersion version: NSFileProviderItemVersion, options: NSFileProviderDeleteItemOptions = [], request: NSFileProviderRequest, completionHandler: @escaping (Error?) -> Void) -> Foundation.Progress {
        // TODO: an item was deleted on disk, process the item's deletion
        let log = log.child("deleteItem").trace("invoked(\(identifier))")

        let handler = { (error: Error?) in
            if let error = error {
                log.error("\(error)")
            }
            completionHandler(error)
        }

        Task {
            do {
                switch ItemIdentifier(identifier) {
                case .rootContainer, .trashContainer, .workingSet:
                    throw ExtError.featureNotSupported
                case .entry(.file(let file)):
                    let path = file.path
                    let repo = try await file.loadRepo(getSession())
                    try await repo.removeFile(path.string)
                case .entry(.directory(let dir)):
                    let path = dir.path
                    let repo = try await dir.loadRepo(getSession())
                    try await repo.removeDirectory(path.string, true)
                }

                handler(nil)
            } catch let error as NSFileProviderError {
                handler(error)
            } catch {
                fatalError("Uncaught exception in deleteItem: \(error)")
            }
        }

        return Foundation.Progress()
    }
    
    public func enumerator(for rawIdentifier: NSFileProviderItemIdentifier, request: NSFileProviderRequest) throws -> NSFileProviderEnumerator {
        let identifier = ItemIdentifier(rawIdentifier)

        let log = self.log.child("enumerator").level(.trace).trace("invoked(\(identifier))")

        // `enumerator(for:)` is synchronous but the session is created asynchronously, so we hand
        // the enumerator an async provider that resolves the session on demand.
        return Enumerator(identifier, { [weak self] in
            guard let self else { throw ExtError.noSuchItem }
            return try await self.getSession()
        }, currentAnchor, log, pastEnumerations)
    }

    // When the system requests to fetch a content from Ouisync, we create a temporary file at the URL location
    // and write the content there. Then pass that URL to a completion handler.
    func makeTemporaryURL(_ purpose: String) -> URL {
        return temporaryDirectoryURL.appendingPathComponent("\(purpose)-\(UUID().uuidString)")
    }

    // This signals to the file provider to refresh
    // https://developer.apple.com/documentation/fileprovider/replicated_file_provider_extension/synchronizing_files_using_file_provider_extensions#4099755
    func signalRefresh() async {
        let oldAnchor = currentAnchor
        currentAnchor = anchorGenerator.generate()
        NSLog("🚀 Refreshing FileProvider and updating anchor \(oldAnchor) -> \(currentAnchor)")

        do {
            try await manager.signalEnumerator(for: .workingSet)
        } catch let error as NSError {
            NSLog("❌ failed to signal working set for \(ouisyncFileProviderDomain): \(error)")
        }
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
func copyContentsAndClose(_ src: URL, _ repo: Repository, _ dstPath: FilePath, _ createDst: Bool) async throws -> (UInt64, Version) {
    let srcFile = try FileHandle(forReadingFrom: src)

    var written: UInt64 = 0

    var dst: File

    if createDst {
        dst = try await repo.createFile(dstPath.string)
    } else {
        dst = try await repo.openFile(dstPath.string)
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
                // TODO(stopgap): synthesized version; new service API lacks per-entry version hash.
                // The version is derived from the number of bytes written.
                try await dst.close()
                return (written, Version(synthesizeFileVersionHash(written), written))
            }
            try await dst.write(written, data)
            written += UInt64(exactly: data.count)!
        }
    }
}

class PastEnumerations {
    var enumerations: [ItemIdentifier: [EntryIdentifier: EntryItem]] = [:]

    func setFor(_ itemId: ItemIdentifier, _ enums: [EntryIdentifier: EntryItem]) {
        self.enumerations[itemId] = enums
    }
}
