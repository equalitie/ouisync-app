//
//  Logger.swift
//  Common
//
//  Created by Peter Jankuliak on 04/06/2024.
//

import Foundation

class Log {
    fileprivate static var nextRootId: UInt64 = 0

    fileprivate let parent: Log?
    var label: String
    var id: UInt64
    var nextChildId: UInt64 = 0

    init(_ label: String) {
        self.parent = nil
        self.label = label
        self.id = Self.nextRootId
        Self.nextRootId += 1
    }

    fileprivate init(_ label: String, _ parent: Log) {
        self.parent = parent
        self.label = label
        self.id = parent.nextChildId
        parent.nextChildId += 1
    }

    func child(_ label: String) -> Log {
        Log(label, self)
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
        let path = self.path()
        return path.map({ "\($0.label):\($0.id)" }).joined(separator: "/") + ": "
    }

    fileprivate func path() -> [Log] {
        var current: Log? = self
        var ret: [Log] = []

        while let c = current {
            ret.append(c)
            current = c.parent
        }

        return ret.reversed()
    }
}
