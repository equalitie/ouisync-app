//
//  Directories.swift
//  Common
//
//  Created by Peter Jankuliak on 23/07/2024.
//

import Foundation

public class Directories {
    public let rootPath: String
    public let configsPath: String
    public let logsPath: String
    public let repositoriesPath: String

    public init() {
        let rootURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "5SR9R72Z83.org.equalitie.ouisync")!
        rootPath = rootURL.path(percentEncoded: false)
        configsPath = rootPath + "config"
        logsPath = rootPath + "log"
        repositoriesPath = rootPath + "repositories"
    }
}
