import Cocoa
import FlutterMacOS
import AppKit
import FileProvider
import OSLog

@objc public protocol OuisyncServiceV1 {
    //func versions(for url: URL) async throws -> ([NSData], NSData)
    //func keep(versions: [NSNumber], baseVersion: NSData, for url: URL) async throws
    func test()
}

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
    override init() {
        super.init()
        
    }
    
    override func applicationDidFinishLaunching(_ notification: Notification) {
        let domain = self.getDomain();
        
        NSFileProviderManager.add(domain, completionHandler: {error in
            if let error = error {
                NSLog("!!! Error starting file provider for domain \(domain): \(String(describing: error))")
            } else {
                NSLog("NSFileProviderManager added domain successfully");
            }
        })
        Task {
            NSLog("=========================== 1")
            let manager = NSFileProviderManager(for: domain)!
            NSLog("=========================== 2")
            let service = try await manager.service(named: NSFileProviderServiceName("org.equalitie.Ouisync"), for: NSFileProviderItemIdentifier.rootContainer)
            NSLog("=========================== \(service?.name)")
            guard let service = service else {
                return;
            }
            let connection = try await service.fileProviderConnection()
            connection.remoteObjectInterface = NSXPCInterface(with: OuisyncServiceV1.self)
            
            connection.interruptionHandler = {
                NSLog("=========================== connection to XPC service has been interrupted")
            }

            connection.invalidationHandler = {
                NSLog("=========================== connection to XPC service has been invalidated")
            }
            
            connection.resume();
            
            let proxy = connection.remoteObjectProxy() as! OuisyncServiceV1;
            
            while true {
                try await proxy.test()
                try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
            }
        }
    }
    
    func getDomain() -> NSFileProviderDomain {
        return NSFileProviderDomain(identifier: NSFileProviderDomainIdentifier(rawValue: "mydomain"), displayName: "mydisplayname")
    }
    
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    //override func applicationDidBecomeActive(_ notification: Notification) {
    //    super.applicationDidBecomeActive(notification)
    //}
}
