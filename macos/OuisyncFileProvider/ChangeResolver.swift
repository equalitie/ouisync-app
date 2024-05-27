//
//  ChangeResolver.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 27/05/2024.
//

import Foundation
import FileProvider
import OuisyncLib

// Given an ItemIdentifier of a materialized* item and OuisyncSession, find which
// of it's entries have changed, which are new and which have been deleted.
class ChangeResolver {
    let materializedItemId: NSFileProviderItemIdentifier
    let ouisync: OuisyncSession

    init(_ materializedItemId: NSFileProviderItemIdentifier, _ ouisync: OuisyncSession) {
        self.materializedItemId = materializedItemId
        self.ouisync = ouisync
    }
}
