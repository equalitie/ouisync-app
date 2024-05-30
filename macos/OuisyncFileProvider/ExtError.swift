//
//  Error+Presentable.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 25/03/2024.
//

import Common
import FileProvider
import OuisyncLib

enum ExtError : Error {
    case noSuchItem
    case backendIsUnreachable
    case syncAnchorExpired
    case featureNotSupported
}

extension ExtError {
    func toNSError() -> NSError {
        switch self {
        case .noSuchItem:
            return NSError(
                domain: NSFileProviderErrorDomain,
                code: NSFileProviderError.noSuchItem.rawValue,
                userInfo: nil
            )
        case .backendIsUnreachable:
            return NSError(
                domain: NSFileProviderErrorDomain,
                code: NSFileProviderError.serverUnreachable.rawValue,
                userInfo: nil
            )
        case .syncAnchorExpired:
            return NSError(
                domain: NSFileProviderErrorDomain,
                code: NSFileProviderError.syncAnchorExpired.rawValue,
                userInfo: nil
            )
        case .featureNotSupported:
            return NSError(
                domain: NSCocoaErrorDomain,
                code: NSFeatureUnsupportedError,
                userInfo:[:]
            )
        }
    }
}
