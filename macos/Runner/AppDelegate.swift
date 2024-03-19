import Cocoa
import FlutterMacOS
import AppKit
import FileProvider

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationDidBecomeActive(_ notification: Notification) {
    let domain = NSFileProviderDomain(identifier: NSFileProviderDomainIdentifier(rawValue: "mydomain"), displayName: "mydisplayname")

    NSFileProviderManager.add(domain, completionHandler: {error in
      if let error = error {
        print("Error starting file provider for domain \(domain): \(String(describing: error))")
      }
    })
  }
}
