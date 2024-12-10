import FlutterMacOS
import FileProvider
import LaunchAtLogin
import OuisyncCommon


class MainFlutterWindow: NSWindow {
    var fileProviderProxy: FileProviderProxy? = nil
    var flutterMethodChannel: FlutterMethodChannel? = nil

    override func awakeFromNib() {
        let flutterViewController = FlutterViewController()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)

        let flutterBinaryMessenger = flutterViewController.engine.binaryMessenger
        setupFlutterToExtensionProxy(flutterBinaryMessenger)
        setupFlutterMethodChannel(flutterBinaryMessenger)
        setupFlutterAutostartChannel(flutterBinaryMessenger)

        RegisterGeneratedPlugins(registry: flutterViewController)

        super.awakeFromNib()
    }

    override public func order(_ place: NSWindow.OrderingMode, relativeTo otherWin: Int) {
        super.order(place, relativeTo: otherWin)
        hiddenWindowAtLaunch()
    }

    // ------------------------------------------------------------------
    // Autostart requires some custom platform integration as per:
    // https://pub.dev/packages/launch_at_startup#macos-support
    // ------------------------------------------------------------------
    fileprivate func setupFlutterAutostartChannel(_ binaryMessenger: FlutterBinaryMessenger) {
        FlutterMethodChannel(name: "launch_at_startup",
                             binaryMessenger: binaryMessenger)
        .setMethodCallHandler { call, result in
            switch call.method {
            case "launchAtStartupSetEnabled":
                if let arguments = call.arguments as? [String: Any],
                   let value = arguments["setEnabledValue"] as? Bool {
                    LaunchAtLogin.isEnabled = value
                }
                fallthrough
            case "launchAtStartupIsEnabled": result(LaunchAtLogin.isEnabled)
            default: result(FlutterMethodNotImplemented)
            }
        }
    }

    // ------------------------------------------------------------------
    // Setup proxy between flutter and the file provider extension
    // ------------------------------------------------------------------
    fileprivate func setupFlutterToExtensionProxy(_ binaryMessenger: FlutterBinaryMessenger) {
        if fileProviderProxy == nil {
            fileProviderProxy = FileProviderProxy(binaryMessenger)
        }
    }

    // ------------------------------------------------------------------
    // Setup handing of message from flutter to this app instance
    // ------------------------------------------------------------------
    fileprivate func setupFlutterMethodChannel(_ binaryMessenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: Constants.flutterConfigChannel, binaryMessenger: binaryMessenger)
        channel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else { return }
            handleFlutterMethodCall(call, result: result)
        })
        flutterMethodChannel = channel
    }

    private func handleFlutterMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getSharedDir": result(Directories.rootPath)
        case "getMountRootDirectory": Task {
            let manager = NSFileProviderManager(for: ouisyncFileProviderDomain)!
            let userVisibleRootUrl = try! await manager.getUserVisibleURL(for: .rootContainer)
            var path = userVisibleRootUrl.path(percentEncoded: false)
            if path.last == "/" {
                path = String(path.dropLast())
            }
            result(path)
        }
        default: result(FlutterError(code: "OS06",
                                     message: "Method \"\(call.method)\" not exported by host",
                                     details: nil))
        }
    }
}

