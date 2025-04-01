import Foundation


#if os(macOS)
private let appGroup = "5SR9R72Z83.org.equalitie.ouisync"
#else
private let appGroup = "group.org.equalitie"
#endif
private let rootURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)!


public class Constants {
    public static let baseBundle = "org.equalitie.ouisync"
    public static let rootPath = rootURL.path(percentEncoded: false)
    public static let configsPath = rootPath + "config"
    public static let logsPath = rootPath + "logs/ouisync.log"
    public static let repositoriesPath = rootPath + "repositories"

    // TODO: merge the following in a single channel:
    public static let uiFlutterChannel = "\(baseBundle)/native"
    public static let bindingsChannel = "\(baseBundle).lib"
}
