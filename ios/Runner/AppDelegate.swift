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

        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    }

    override func application(_ application: UIApplication,
                              didFinishLaunchingWithOptions launchOptions: LaunchOptions) -> Bool {
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private var bag = [AnyObject]() // things that we don't need but should nonetheless be retained
}
