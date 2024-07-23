import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
    var fileProviderProxy: FileProviderProxy? = nil

    override func awakeFromNib() {
        let flutterViewController = FlutterViewController()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)

        if fileProviderProxy == nil {
            fileProviderProxy = FileProviderProxy(flutterViewController.engine.binaryMessenger)
        }

        RegisterGeneratedPlugins(registry: flutterViewController)

        super.awakeFromNib()
    }

}

