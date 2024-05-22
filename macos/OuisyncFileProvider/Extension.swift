//
//  FileProviderExtension.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 15/03/2024.
//

import FileProvider
import OuisyncLib

class State {
    var reposByName = Dictionary<RepoName, OuisyncRepository>()

    func repos() -> Set<OuisyncRepository> {
        return Set(reposByName.values)
    }
}

class Extension: NSObject, NSFileProviderReplicatedExtension {
    var ouisyncSession: OuisyncSession?
    let state = State()

    required init(domain: NSFileProviderDomain) {
        // TODO: The containing application must create a domain using
        // `NSFileProviderManager.add(_:, completionHandler:)`. The system will
        // then launch the application extension process, call
        // `FileProviderExtension.init(domain:)` to instantiate the extension
        // for that domain, and call methods on the instance.
        
        super.init()
    }

    func invalidate() {
        // TODO: cleanup any resources
    }
    
    func item(for identifier: NSFileProviderItemIdentifier, request: NSFileProviderRequest, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) -> Progress {
        // resolve the given identifier to a record in the model
        
        // TODO: implement the actual lookup

        Task {
            guard let session = ouisyncSession else {
                let id = ItemIdentifier(identifier)
                switch id {
                case .rootContainer: return completionHandler(RootContainerItem(), nil);
                case .trashContainer: return completionHandler(TrashContainerItem(), nil);
                case .workingSet: return completionHandler(WorkingSetItem(), nil);
                default:
                    fatalError("TODO")
                }
            }
            let item = try itemFromIdentifier(identifier, session, state)
            completionHandler(item, nil)
        }
        return Progress()
    }
    
    func fetchContents(for itemIdentifier: NSFileProviderItemIdentifier, version requestedVersion: NSFileProviderItemVersion?, request: NSFileProviderRequest, completionHandler: @escaping (URL?, NSFileProviderItem?, Error?) -> Void) -> Progress {
        // TODO: implement fetching of the contents for the itemIdentifier at the specified version
        
        completionHandler(nil, nil, NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
        return Progress()
    }
    
    func createItem(basedOn itemTemplate: NSFileProviderItem, fields: NSFileProviderItemFields, contents url: URL?, options: NSFileProviderCreateItemOptions = [], request: NSFileProviderRequest, completionHandler: @escaping (NSFileProviderItem?, NSFileProviderItemFields, Bool, Error?) -> Void) -> Progress {
        // TODO: a new item was created on disk, process the item's creation
        
        completionHandler(itemTemplate, [], false, nil)
        return Progress()
    }
    
    func modifyItem(_ item: NSFileProviderItem, baseVersion version: NSFileProviderItemVersion, changedFields: NSFileProviderItemFields, contents newContents: URL?, options: NSFileProviderModifyItemOptions = [], request: NSFileProviderRequest, completionHandler: @escaping (NSFileProviderItem?, NSFileProviderItemFields, Bool, Error?) -> Void) -> Progress {
        // TODO: an item was modified on disk, process the item's modification
        
        completionHandler(nil, [], false, NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
        return Progress()
    }
    
    func deleteItem(identifier: NSFileProviderItemIdentifier, baseVersion version: NSFileProviderItemVersion, options: NSFileProviderDeleteItemOptions = [], request: NSFileProviderRequest, completionHandler: @escaping (Error?) -> Void) -> Progress {
        // TODO: an item was deleted on disk, process the item's deletion
        
        completionHandler(NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
        return Progress()
    }
    
    func enumerator(for containerItemIdentifier: NSFileProviderItemIdentifier, request: NSFileProviderRequest) throws -> NSFileProviderEnumerator {
        var identifier = containerItemIdentifier

        if identifier == .workingSet {
            identifier = .rootContainer
        }

        guard let session = self.ouisyncSession else {
            return NoConnectionEnumerator()
        }

        let itemIdentifier = ItemIdentifier(identifier)
        Self.log("enumerator(for: \(identifier), request: \(request)")

        return try Enumerator(itemIdentifier, session, self.state)
    }

    static func log(_ str: String) {
        NSLog(">>>> FileProviderExtension: \(str)")
    }
}

