import Cocoa
import FlutterMacOS
import AppKit
import FileProvider
import OSLog

extension Logger {
    /// Using your bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    /// Logs the view cycles like a view that appeared.
    static let viewCycle = Logger(subsystem: subsystem, category: "viewcycle")
    
    /// All logs related to tracking and analytics.
    static let statistics = Logger(subsystem: subsystem, category: "statistics")
}

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
    override init() {
        super.init()
        
    }
    
    override func applicationDidFinishLaunching(_ notification: Notification) {
        let domain = NSFileProviderDomain(identifier: NSFileProviderDomainIdentifier(rawValue: "mydomain"), displayName: "mydisplayname")
        
        NSLog("===========================task data:")
        NSFileProviderManager.add(domain, completionHandler: {error in
            if let error = error {
                NSLog("------------ Error starting file provider for domain \(domain): \(String(describing: error))")
            } else {
                NSLog("------------ NSFileProviderManager added domain successfully");
            }
        })
    }
    
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    //override func applicationDidBecomeActive(_ notification: Notification) {
    //    super.applicationDidBecomeActive(notification)
    //}
}
