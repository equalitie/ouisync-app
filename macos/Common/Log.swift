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
    fileprivate var label: String
    fileprivate var id: UInt64
    fileprivate var nextChildId: UInt64 = 0
    fileprivate var enabled: Bool = true

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
        let (enabled, labels) = collect()
        if !enabled { return self }
        NSLog("🧩 \(labels)\(msg)")
        return self
    }

    func info(_ msg: String) {
        let (enabled, labels) = collect()
        if !enabled { return }
        NSLog("🧩 \(labels)\(msg)")
    }

    func error(_ msg: String) {
        let (enabled, labels) = collect()
        if !enabled { return }
        NSLog("😡 \(labels)\(msg)")
    }

    func disable() -> Log {
        enabled = false
        return self
    }

    fileprivate func collect() -> (enabled: Bool, labels: String) {
        let path = self.path()
        return (
            enabled: path.reduce(true, { $0 && $1.enabled }),
            labels: path.map({ "\($0.label):\($0.id)" }).joined(separator: "/") + ": "
        )
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
