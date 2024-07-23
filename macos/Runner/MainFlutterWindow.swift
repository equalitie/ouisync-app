import Cocoa
import FlutterMacOS
import Common

class MainFlutterWindow: NSWindow {
    var fileProviderProxy: FileProviderProxy? = nil
    var flutterMethodChannel: FlutterMethodChannel? = nil
    let methodChannelName: String = "org.equalitie.ouisync_app/native"

    override func awakeFromNib() {
        let flutterViewController = FlutterViewController()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)

        let flutterBinaryMessenger = flutterViewController.engine.binaryMessenger
        setupFlutterToExtensionProxy(flutterBinaryMessenger)
        setupFlutterMethodChannel(flutterBinaryMessenger)

        RegisterGeneratedPlugins(registry: flutterViewController)

        super.awakeFromNib()
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
        let channel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: binaryMessenger)
        channel.setMethodCallHandler(handleFlutterMethodCall)
        flutterMethodChannel = channel
    }

    private func handleFlutterMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getDefaultRepositoriesDirectory":
            let commonDirs = Common.Directories()
            result(commonDirs.repositoriesPath)
        default:
            result(FlutterMethodNotImplemented)
            fatalError("Unknown method '\(call.method)' passed to channel '\(methodChannelName)'")
        }
    }
}

