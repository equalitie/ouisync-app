//
//  Logger.swift
//  Common
//
//  Created by Peter Jankuliak on 04/06/2024.
//

import Foundation

class Log {
    var labels: [String] = []

    init(_ label: String? = nil) {
        if let label = label {
            labels.append(label)
        }
    }

    private init(_ labels: [String]) {
        self.labels = labels
    }

    func child(_ label: String) -> Log {
        let ch = Log(labels)
        ch.labels.append(label)
        return ch
    }

    @discardableResult
    func trace(_ msg: String) -> Log {
        NSLog("🧩 \(labels_str())\(msg)")
        return self
    }

    func info(_ msg: String) {
        NSLog("🧩 \(labels_str())\(msg)")
    }

    func error(_ msg: String) {
        NSLog("😡 \(labels_str())\(msg)")
    }

    func labels_str() -> String {
        if labels.isEmpty {
            return ""
        } else {
            return labels.joined(separator: "/") + ": "
        }
    }
}
