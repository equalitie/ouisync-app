//
//  Error+Presentable.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 25/03/2024.
//

import Common
import FileProvider
import OuisyncLib

class ExtError {
    static var noSuchItem: NSError {
        NSError(
            domain: NSFileProviderErrorDomain,
            code: NSFileProviderError.noSuchItem.rawValue,
            userInfo: [:]
        )
    }

    static var backendIsUnreachable: NSError {
        NSError(
            domain: NSFileProviderErrorDomain,
            code: NSFileProviderError.serverUnreachable.rawValue,
            userInfo: [:]
        )
    }

    static var syncAnchorExpired: NSError {
        NSError(
            domain: NSFileProviderErrorDomain,
            code: NSFileProviderError.syncAnchorExpired.rawValue,
            userInfo: [:]
        )
    }

    static var featureNotSupported: NSError {
        NSError(
            domain: NSCocoaErrorDomain,
            code: NSFeatureUnsupportedError,
            userInfo: [:]
        )
    }
}
