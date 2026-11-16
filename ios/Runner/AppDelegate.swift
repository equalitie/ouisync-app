import FileProvider
import Flutter
import OuisyncCommon
import UIKit


@main @objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]?

    // With the UIScene lifecycle the window belongs to SceneDelegate, so the app's window and
    // root view controller are not available in application(_:didFinishLaunchingWithOptions:).
    // The engine is set up here instead, once Flutter has created it.
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        let messenger = engineBridge.applicationRegistrar.messenger()

        FlutterMethodChannel(name: Constants.flutterConfigChannel,
                             binaryMessenger: messenger)
        .setMethodCallHandler { call, result in
            switch call.method {
            case "getSharedDir": result(Directories.rootPath)
            // case "getMountRootDirectory": Not supported on iOS
            default: result(FlutterError(code: "OS06",
                                         message: "Method \"\(call.method)\" not exported by host",
                                         details: nil))
            }
        }

        bag.append(FileProviderProxy(messenger))

        // Register the File Provider domain so the extension is available in the Files app. This
        // used to happen lazily via the app<->extension XPC "initialize" call, but that tunnel is
        // gone in the new client/service architecture (the app talks to the shared service
        // directly), so nothing was registering the domain. `add` is idempotent: registering an
        // already-registered domain succeeds.
        Task {
            do {
                try await NSFileProviderManager.add(ouisyncFileProviderDomain)
            } catch {
                NSLog("Failed to register Ouisync File Provider domain: \(error)")
            }
        }

        universalLinkChannel = FlutterMethodChannel(name: universalLinkChannelName,
                                                    binaryMessenger: messenger)
        universalLinkChannel?.setMethodCallHandler { [weak self] call, result in
            switch call.method {
            case "getInitialLink":
                result(self?.pendingUniversalLink)
                self?.pendingUniversalLink = nil
            default: result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    }

    override func application(_ application: UIApplication,
                              didFinishLaunchingWithOptions launchOptions: LaunchOptions) -> Bool {
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // With scenes, iOS delivers universal links to SceneDelegate instead of this method. This is
    // kept for the case where it is called anyway.
    override func application(_ application: UIApplication,
                              continue userActivity: NSUserActivity,
                              restorationHandler: @escaping ([any UIUserActivityRestoring]?) -> Void) -> Bool {
        if let url = userActivity.webpageURL, handleUniversalLink(url) {
            return true
        }

        return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }

    // The receive_sharing_intent plugin only forwards ShareMedia-prefixed URLs, so universal links
    // to https://ouisync.net/r#... are relayed to Dart here. Returns false for any other URL.
    // Called by SceneDelegate as well, for links that arrive through the UIScene lifecycle.
    @discardableResult
    func handleUniversalLink(_ url: URL) -> Bool {
        guard isOuiSyncShareLink(url) else {
            return false
        }

        pendingUniversalLink = url.absoluteString
        universalLinkChannel?.invokeMethod("onLink", arguments: nil)
        return true
    }

    private func isOuiSyncShareLink(_ url: URL) -> Bool {
        url.scheme == "https" && url.host == "ouisync.net" && url.path == "/r" && url.fragment != nil
    }

    private let universalLinkChannelName = "org.equalitie.ouisync/universal_links"
    private var universalLinkChannel: FlutterMethodChannel?
    private var pendingUniversalLink: String?

    private var bag = [AnyObject]() // things that we don't need but should nonetheless be retained
}
