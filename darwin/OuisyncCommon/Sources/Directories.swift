//
//  Directories.swift
//  Common
//
//  Created by Peter Jankuliak on 23/07/2024.
//

import Foundation


#if os(macOS)
private let appGroup = "5SR9R72Z83.org.equalitie.ouisync"
#else
private let appGroup = "group.org.equalitie"
#endif
private let rootURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)!


public class Directories {
    public static let rootPath = rootURL.path(percentEncoded: false)
    public static let configsPath = rootPath + "config"
    public static let logsPath = rootPath + "logs/ouisync.log"
    public static let repositoriesPath = rootPath + "repositories"
}
