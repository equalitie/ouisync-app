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
            // Resolving the File Provider mount root is best-effort and MUST NOT block app
            // startup: this call is on the `Dirs.init()` critical path, and both
            // `NSFileProviderManager.add` and `getUserVisibleURL` can block indefinitely when the
            // File Provider domain/extension isn't ready. If we can't resolve it quickly we return
            // `nil`, which the Dart side treats as "mounting disabled" and continues launching.
            let path: String? = await Self.resolveMountRoot()
            DispatchQueue.main.async { result(path) }
        }
        default: result(FlutterError(code: "OS06",
                                     message: "Method \"\(call.method)\" not exported by host",
                                     details: nil))
        }
    }

    // Best-effort resolution of the File Provider mount root, time-bounded so it can NEVER hang
    // app startup. Registers the domain (idempotent) and asks for the root container's
    // user-visible URL, but if that doesn't resolve within `timeout` seconds we give up and return
    // nil ("mounting disabled"). Both `NSFileProviderManager.add` and `getUserVisibleURL` can block
    // indefinitely when the File Provider extension/domain isn't ready, so we race them against a
    // timer and never await the (possibly stuck) system call before returning.
    static func resolveMountRoot(timeout seconds: Double = 5) async -> String? {
        await withCheckedContinuation { (cont: CheckedContinuation<String?, Never>) in
            let gate = ResumeOnce()

            // Worker: register the domain and resolve the user-visible root URL.
            Task {
                var value: String? = nil
                do {
                    try await NSFileProviderManager.add(ouisyncFileProviderDomain)
                    if let manager = NSFileProviderManager(for: ouisyncFileProviderDomain) {
                        let url = try await manager.getUserVisibleURL(for: .rootContainer)
                        var path = url.path(percentEncoded: false)
                        if path.last == "/" { path = String(path.dropLast()) }
                        value = path
                    }
                } catch {
                    NSLog("getMountRootDirectory: failed to resolve mount root: \(error)")
                }
                gate.resume(cont, with: value)
            }

            // Timeout: don't let a stuck File Provider call hang startup.
            Task {
                try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                NSLog("getMountRootDirectory: timed out; continuing with mounting disabled")
                gate.resume(cont, with: nil)
            }
        }
    }
}

// Resumes a continuation at most once, so racing worker/timeout tasks can't double-resume.
private final class ResumeOnce {
    private let lock = NSLock()
    private var done = false

    func resume(_ cont: CheckedContinuation<String?, Never>, with value: String?) {
        lock.lock()
        defer { lock.unlock() }
        guard !done else { return }
        done = true
        cont.resume(returning: value)
    }
}

