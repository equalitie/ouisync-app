//
//  Logger.swift
//  Common
//
//  Created by Peter Jankuliak on 04/06/2024.
//
import Foundation


public class Log {
    public enum Level: UInt8 {
        case trace = 0
        case info
        case error
    }

    fileprivate static var nextRootId: UInt64 = 0

    fileprivate let parent: Log?
    fileprivate var label: String
    fileprivate var id: UInt64
    fileprivate var nextChildId: UInt64 = 0
    var selfLevel: Level? = nil

    public init(_ label: String) {
        self.parent = nil
        self.label = label
        self.id = Self.nextRootId
        Self.nextRootId += 1
    }

    fileprivate init(_ label: String, _ parent: Log, _ level: Level?) {
        self.parent = parent
        self.label = label
        self.id = parent.nextChildId
        self.selfLevel = level
        parent.nextChildId += 1
    }

    public func child(_ label: String) -> Log {
        Log(label, self, selfLevel)
    }

    @discardableResult
    public func trace(_ msg: String) -> Log {
        print(.trace, msg)
    }

    @discardableResult
    public func info(_ msg: String) -> Log {
        print(.info, msg)
    }

    @discardableResult
    public func error(_ msg: String) -> Log {
        print(.error, msg)
    }

    @discardableResult
    fileprivate func print(_ level: Level, _ msg: String) -> Log {
        if !shouldPrint(level) { return self }
        let path = self.path()
        NSLog("\(levelBadge(level)) \(labels(path)): \(msg)")
        return self
    }

    public func level(_ l: Level) -> Log {
        self.selfLevel = l
        return self
    }

    fileprivate func levelBadge(_ level: Level) -> String {
        switch level {
        case .trace: return "🧩"
        case .info: return "👉"
        case .error: return "😡"
        }
    }
    fileprivate func labels(_ path: [Log]) -> String {
        return path.map({ "\($0.label):\($0.id)" }).joined(separator: "/")
    }

    fileprivate func shouldPrint(_ level: Level) -> Bool {
        var cur = self
        while true {
            if let curSelfLevel = cur.selfLevel {
                return level.rawValue >= curSelfLevel.rawValue
            }
            if let parent = cur.parent { cur = parent } else { break }
        }

        return true
    }

    func path() -> [Log] {
        var current: Log? = self
        var ret: [Log] = []

        while let c = current {
            ret.append(c)
            current = c.parent
        }

        return ret.reversed()
    }

    func pathFromSelf() -> [Log] {
        var current: Log? = self
        var ret: [Log] = []

        while let c = current {
            ret.append(c)
            current = c.parent
        }

        return ret
    }
}
