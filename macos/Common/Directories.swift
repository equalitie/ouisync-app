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
        // Returns a path that is shared between the app and the file provider extension.
        let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: applicationGroupIdentifier)!
        rootPath = appGroupURL.path(percentEncoded: false)
        configsPath = rootPath + "configs"
        logsPath = rootPath + "logs"
        repositoriesPath = rootPath + "repositories"
    }
}
