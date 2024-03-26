//
//  Errors.swift
//  OuisyncFileProvider
//
//  Created by Peter Jankuliak on 25/03/2024.
//

import Foundation

public enum CommonError: Error, Codable, LocalizedError {
    public static let errorHeader = "X-API-Error"

    internal enum Values: String, Codable {
        case internalError
    }

    internal enum CodingKeys: String, CodingKey {
        case value
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Values.self, forKey: .value) {
        case .internalError:
            self = .internalError
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .internalError:
            try container.encode(Values.internalError, forKey: .value)
        }
    }

    case internalError

    public var errorDescription: String? {
        return "\(self)"
    }
}

