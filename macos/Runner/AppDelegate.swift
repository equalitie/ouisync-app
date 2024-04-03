import Cocoa
import FlutterMacOS
import AppKit
import OSLog


@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
    var fileProviderProxy: FileProviderProxy?;
    
    override init() {
        super.init()
    }

    override func applicationDidFinishLaunching(_ notification: Notification) {
        if fileProviderProxy == nil {
            fileProviderProxy = FileProviderProxy()
        }
    }

    
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
