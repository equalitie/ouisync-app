import Flutter
import OuisyncCommon
import UIKit


@main @objc class AppDelegate: FlutterAppDelegate {
    typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]?
    override func application(_ application: UIApplication,
                              didFinishLaunchingWithOptions launchOptions: LaunchOptions) -> Bool {
        guard let flutter = window.rootViewController as? FlutterViewController else {
            print("App root view controller is not flutter")
            return false
        }

        FlutterMethodChannel(name: Constants.flutterConfigChannel,
                             binaryMessenger: flutter.binaryMessenger)
        .setMethodCallHandler { call, result in
            switch call.method {
            case "getSharedDir": result(Directories.rootPath)
            // case "getMountRootDirectory": Not supported on iOS
            default: result(FlutterError(code: "OS06",
                                         message: "Method \"\(call.method)\" not exported by host",
                                         details: nil))
            }
        }

        bag.append(FileProviderProxy(flutter.binaryMessenger))

        GeneratedPluginRegistrant.register(with: self)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private var bag = [AnyObject]() // things that we don't need but should nonetheless be retained
}
