import FileProvider
import OuisyncCommon
import Ouisync


fileprivate let log = Log("Enumerator")
fileprivate let defaultPageSize = 128 // only used if the operating system doesn't provide a value

/* The enumerator is a (de facto) single-use async-iterator for the contents of a folder */
class Enumerator: NSObject, NSFileProviderEnumerator {
    let client: Future<Client>
    let item: NSFileProviderItemIdentifier
    var version: Data?

    init(_ client: Future<Client>, _ item: NSFileProviderItemIdentifier) {
        log.debug("Enumerator requested for \(item)")
        self.client = client
        self.item = item
        super.init()
    }

    func invalidate() {
        log.debug("Enumerator for \(item) going away")
    }

    deinit {
        log.debug("Enumerator for \(item) out of scope")
    }

    /**
     Enumerate items starting from the specified page, typically
     NSFileProviderInitialPageSortedByDate or NSFileProviderInitialPageSortedByName.

     Pagination allows large collections to be enumerated in multiple batches.  The
     sort order specified in the initial page is important even if the enumeration
     results will actually be sorted again before display.  If results are sorted
     correctly across pages, then the new results will be appended at the bottom of
     the list, probably not on screen, which is the best user experience.  Otherwise
     results from the second page might be inserted in the results from the first
     page, causing bizarre animations.

     The page data should contain whatever information is needed to resume the
     enumeration after the previous page.  If a file provider sends batches of 200
     items to -[NSFileProviderEnumerationObserver didEnumerateItems:] for example,
     then successive pages might contain offsets in increments of 200.

     Execution time:
     ---------------
     This method is not expected to take more than a few seconds to complete the
     enumeration of a page of items. If the enumeration may not complete in a reasonable
     amount of time because, for instance, of bad network conditions, it is recommended
     to either report an error (for instance NSFileProviderErrorServerUnreachable) or
     return everything that is readily available and wait for the enumeration of the
     next page. */
    func enumerateItems(for observer: any NSFileProviderEnumerationObserver,
                        startingAt page: NSFileProviderPage) {
        let size = observer.suggestedPageSize ?? defaultPageSize
        guard let page = Page(page) else {
            log.fault("enumerateItems called with invalid page: \(page.rawValue.base64EncodedString())")
            return observer.finishEnumeratingWithError(NSFileProviderError(.versionNoLongerAvailable))
        }

        Task {
            do {
                let cli = try await client.value
                switch folder {
                case .rootContainer:

                // FIXME: handle special folders: `cache:/` and `trash:/`
                case .trashContainer, .workingSet: observer.finishEnumerating(upTo: nil)
                default:
                    guard let (repoName, folderName) = item.path
                        let repo = await cli.repositories.first { try await $0.path == folder.path }
                }

                guard case .Directory(let version) = try await repo.entryType(at: path)
                else { return observer.finishEnumeratingWithError(NSFileProviderError(.noSuchItem)) }

                // FIXME: implement sorting & pagination library-side cause this ain't gonna cut it
                let all = try await repo.listDirectory(at: path).sorted { $0.name < $1.name }
                let values = all[page.offset..<page.offset + size].map { Entry($0, in: folder) }

                observer.didEnumerate(values)
                observer.finishEnumerating(upTo: page.advanced(by: min(size, values.count)))
            } catch {
                log.fault("enumerateItems failed with \(error)")
                observer.finishEnumeratingWithError(NSFileProviderError(.serverUnreachable))
            }
        }
    }

    /** Enumerate changes starting from a sync anchor. This should enumerate /all/
     changes (not restricted to a specific page) since the given sync anchor.

     Until the enumeration update is invalidated, a call to -[NSFileProviderManager
     signalEnumeratorForContainerItemIdentifier:completionHandler:] will trigger a
     call to enumerateFromSyncAnchor with the latest known sync anchor, giving the
     file provider (app or extension) a chance to notify about changes.

     The anchor data should contain whatever information is needed to resume
     enumerating changes from the previous synchronization point.  A naive sync
     anchor might for example be the date of the last change that was sent from the
     server to the client, meaning that at that date, the client was in sync with
     all the server changes.  A request to enumerate changes from that sync anchor
     would only return the changes that happened after that date, which are
     therefore changes that the client doesn't yet know about.

     NOTE that the change-based observation methods are marked optional for historical
     reasons, but are really required. System performance will be severely degraded if
     they are not implemented.

     Execution time:
     ---------------
     This method is not expected to take more than a few seconds to complete the
     enumeration of a batch of items. If the enumeration may not complete in a reasonable
     amount of time because, for instance, of bad network conditions, it is recommended
     to either report an error (for instance NSFileProviderErrorServerUnreachable) or
     return everything that is readily available and wait for the enumeration of the
     next batch. */
    func enumerateChanges(for observer: any NSFileProviderChangeObserver,
                          from syncAnchor: NSFileProviderSyncAnchor) {

    }

    /** Request the current sync anchor.
     To keep an enumeration updated, the system will typically
     - request the current sync anchor (1)
     - enumerate items starting with an initial page
     - continue enumerating pages, each time from the page returned in the previous
       enumeration, until finishEnumeratingUpToPage: is called with nextPage set to
       nil
     - enumerate changes starting from the sync anchor returned in (1), until
       finishEnumeratingChangesUpToSyncAnchor: is called with the latest sync anchor.
       If moreComing is YES, continue enumerating changes, using the latest sync anchor returned.
       If moreComing is NO, stop enumerating.
     - When the extension calls -[NSFileProviderManager signalEnumeratorForContainerItemIdentifier:
       completionHandler:] to signal more changes, the system will again enumerate changes,
       starting at the latest known sync anchor from finishEnumeratingChangesUpToSyncAnchor. */
    func currentSyncAnchor() async -> NSFileProviderSyncAnchor? {
        // undocumented async budget, presuming a few seconds like all other enumerator calls
        nil
    }
}


struct Page {
    static let firstByDate = NSFileProviderPage.initialPageSortedByDate as Data // FPPageSortedByDate\0
    static let firstByName = NSFileProviderPage.initialPageSortedByName as Data // FPPageSortedByName\0

    enum Order: UInt8 { case byDate, byName }
    let order: Order
    let offset: Int

    init?(_ page: NSFileProviderPage) {
        let data = page.rawValue
        switch data {
        case Self.firstByDate: order = .byDate; offset = 0
        case Self.firstByName: order = .byName; offset = 1
        default:
            guard data.count == Self.SIZE else { return nil }
            let val = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: 1, as: Int.self) }
            switch data[0] {
            case 0: order = .byDate; offset = val
            case 1: order = .byName; offset = val
            default: return nil
            }
        }
    }

    func advanced(by count: Int) -> NSFileProviderPage {
        var data = Data(capacity: Self.SIZE)
        data.withUnsafeMutableBytes { data in
            data[0] = order.rawValue
            data.storeBytes(of: offset + count, toByteOffset: 1, as: Int.self)
        }
        return NSFileProviderPage(rawValue: data)
    }

    fileprivate static let SIZE = MemoryLayout<Int>.stride + 1
}


fileprivate extension NSFileProviderItemIdentifier {
    var url: String {
        switch self {
        case .rootContainer: return: ""
        case .trashContainer: return "trash:"
        case .workingSet: return "cache:"
        default: return rawValue
        }
    }

    var location: (String, String) {
        guard let sep = rawValue.firstIndex(of: ":") else { return (rawValue, "") }
        return (String(rawValue.prefix(upTo: sep)),
                String(rawValue.suffix(from: rawValue.index(after: sep))))
    }
}


class Entry: NSObject, NSFileProviderItemProtocol {
    let itemIdentifier: NSFileProviderItemIdentifier
    let parentItemIdentifier: NSFileProviderItemIdentifier
    var filename: String

    init(_ entry: DirectoryEntry, in parent: NSFileProviderItemIdentifier) {
        filename = entry.name
        parentItemIdentifier = parent

        // FIXME:
        if case .rootContainer = parent {
            itemIdentifier = .init(filename + ":")
        } else {
            itemIdentifier = .init(rawValue: "\(parent.url)/\(filename)")
        }
    }
}
