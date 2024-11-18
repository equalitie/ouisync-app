import XCTest
@testable import Ouisync
@testable import Common
@testable import Backend


class EnvironmentTests: XCTestCase {
    func testAlwaysOkay() {
        // never fails once compiled: only serves to validate the environment and target config
        XCTAssertNotNil(FileProviderProxy.self)  // from runner
        XCTAssertNotNil(SuccessfulTask.self)     // from common
        XCTAssertNotNil(AppToBackendProxy.self)  // from extension
    }
}
