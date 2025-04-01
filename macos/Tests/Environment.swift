import XCTest
@testable import OuisyncRunner
@testable import OuisyncCommon
@testable import OuisyncBackend


class EnvironmentTests: XCTestCase {
    func testAlwaysOkay() {
        // never fails once compiled: only serves to validate the environment and target config
        XCTAssertNotNil(FileProviderProxy.self)  // from runner
        XCTAssertNotNil(FromFileProviderToAppProtocol.self)  // from common
        XCTAssertNotNil(AppToBackendProxy.self)  // from extension
    }
}
