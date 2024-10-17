import Cocoa
import FlutterMacOS
import AppKit
import OSLog


// https://developer.apple.com/documentation/uikit/uiapplicationdelegate
@main
class AppDelegate: FlutterAppDelegate {
//    var fileProviderProxy: FileProviderProxy?;

    override init() {
        super.init()
    }

//    override func applicationDidFinishLaunching(_ notification: Notification) {
//        if fileProviderProxy == nil {
//            fileProviderProxy = FileProviderProxy()
//        }
//    }
//
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

//    override func applicationWillTerminate(_ notification: Notification) {
//        // This removes the file provider from Finder when Ouisync exits cleanly
//        if let proxy = fileProviderProxy {
//            let semaphore = DispatchSemaphore(value: 0)
//            Task.detached {
//                do {
//                    try await proxy.invalidate()
//                } catch {
//                    NSLog("😡 Failed to stop ouisync file provider extension")
//                }
//                semaphore.signal()
//            }
//            semaphore.wait()
//        }
//
//        super.applicationWillTerminate(notification)
//    }
}
