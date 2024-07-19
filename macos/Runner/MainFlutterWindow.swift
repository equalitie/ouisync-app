import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
    var fileProviderProxy: FileProviderProxy2? = nil

    override func awakeFromNib() {
        let flutterViewController = FlutterViewController()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)

        if fileProviderProxy == nil {
            fileProviderProxy = FileProviderProxy2(flutterViewController.engine.binaryMessenger)
        }

        RegisterGeneratedPlugins(registry: flutterViewController)

        super.awakeFromNib()
    }

}

