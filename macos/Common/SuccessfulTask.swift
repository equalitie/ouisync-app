//
//  SuccessfulTask.swift
//  Common
//
//  Created by Peter Jankuliak on 03/06/2024.
//

import Foundation

// Task that report any thrown Error from `operation` with `fatalError`
public class SuccessfulTask {
    @discardableResult
    public init(_ operation: @escaping @Sendable () async throws -> Void) {
        Task {
            do {
                try await operation()
            } catch {
                fatalError("Task finished with unexpected error: \(error)")
            }
        }
    }
}
