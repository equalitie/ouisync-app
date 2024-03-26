//
//  Error+Presentable.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 25/03/2024.
//

import Common
import FileProvider

extension Error {
    func toPresentableError() -> NSError {
        guard let commonError = self as? CommonError else {
            let error = self as NSError
            switch (error.domain, error.code) {
            default:
                return NSError(domain: NSCocoaErrorDomain, code: NSXPCConnectionReplyInvalid, userInfo: nil)
            }
        }

        switch commonError {
        default:
            return NSError(domain: NSCocoaErrorDomain, code: NSXPCConnectionReplyInvalid, userInfo: [NSUnderlyingErrorKey: commonError])
        }
    }
}
