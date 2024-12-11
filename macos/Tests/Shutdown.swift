import XCTest
@testable import OuisyncCommon
@testable import OuisyncBackend


class ExtensionTest: XCTestCase {
    func testGracefulShutdown() async throws {
        // tests that the library is shut down when `invalidate()` is called
        // no assertions are performed, this used to cause a SIGSEGV
        print("spawning extension")
        var ext: Extension? = .init(domain: ouisyncFileProviderDomain) // TODO: use test domain
        try await Task.sleep(for: .seconds(5))

        print("shutting down")
        ext!.invalidate()
        try await Task.sleep(for: .seconds(5))

        print("dropping reference")
        ext = nil
        try await Task.sleep(for: .seconds(5))
    }
}
