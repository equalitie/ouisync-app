//
//  SuccessfulTask.swift
//  Common
//
//  Created by Peter Jankuliak on 03/06/2024.
//

import Foundation

// Task that report any thrown Error from `operation` with `fatalError`
public class SuccessfulTask {
    let taskName: String?

    @discardableResult
    public init(name taskName: String? = nil, _ operation: @escaping @Sendable () async throws -> Void) {
        self.taskName = taskName

        Task {
            do {
                try await operation()
            } catch {
                if let name = taskName {
                    fatalError("Task \"\(name)\" finished with unexpected error: \(error)")
                } else {
                    fatalError("Task finished with unexpected error: \(error)")
                }
            }
        }
    }
}
