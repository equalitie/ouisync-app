import AppKit
import FlutterMacOS


@main class AppDelegate: FlutterAppDelegate {
    // Fallback in case the delegate wasn't yet connected when MainFlutterWindow loaded.
    override func applicationDidFinishLaunching(_ notification: Notification) {
        super.applicationDidFinishLaunching(notification)
    }

    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    // The ouisync.net share links are relayed to Dart over a method channel, see the iOS AppDelegate.
    override func application(_ application: NSApplication,
                             continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([any NSUserActivityRestoring]) -> Void) -> Bool {
        if let url = userActivity.webpageURL, isOuiSyncShareLink(url) {
            pendingUniversalLink = url.absoluteString
            universalLinkChannel?.invokeMethod("onLink", arguments: nil)
            return true
        }

        return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }

    private func isOuiSyncShareLink(_ url: URL) -> Bool {
        url.scheme == "https" && url.host == "ouisync.net" && url.path == "/r" && url.fragment != nil
    }

    public let universalLinkChannelName = "org.equalitie.ouisync/universal_links"
    public var universalLinkChannel: FlutterMethodChannel?
    public var pendingUniversalLink: String?
}
