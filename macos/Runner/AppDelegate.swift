import Cocoa
import FlutterMacOS
import AppKit
import FileProvider
import OSLog

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
    override init() {
        super.init()
        
    }
    
    override func applicationDidFinishLaunching(_ notification: Notification) {
        let domain = NSFileProviderDomain(identifier: NSFileProviderDomainIdentifier(rawValue: "mydomain"), displayName: "mydisplayname")
        
        NSFileProviderManager.add(domain, completionHandler: {error in
            if let error = error {
                NSLog("!!! Error starting file provider for domain \(domain): \(String(describing: error))")
            } else {
                NSLog("NSFileProviderManager added domain successfully");
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
