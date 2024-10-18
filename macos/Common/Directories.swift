//
//  Directories.swift
//  Common
//
//  Created by Peter Jankuliak on 23/07/2024.
//

import Foundation

public class Directories {
    private static let rootURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "5SR9R72Z83.org.equalitie.ouisync")!
    public static let rootPath = rootURL.path(percentEncoded: false)
    public static let configsPath = rootPath + "config"
    public static let logsPath = rootPath + "logs/ouisync.log"
    public static let repositoriesPath = rootPath + "repositories"
}
