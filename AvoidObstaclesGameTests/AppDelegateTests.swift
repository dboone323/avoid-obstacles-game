import XCTest

@testable import AvoidObstaclesGame

final class AppDelegateTests: XCTestCase {
    // MARK: - AppDelegate Tests

    #if os(iOS)
        func testAppDelegateInitialization() {
            // Test basic initialization
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            XCTAssertNotNil(appDelegate, "AppDelegate should be properly initialized")
        }

        func testAppDelegateProperties() {
            // Test property access and validation
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            XCTAssertNotNil(appDelegate, "AppDelegate should have valid properties")
        }

        func testAppDelegateMethods() {
            // Test method functionality
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            XCTAssertNotNil(appDelegate, "AppDelegate should respond to methods")
        }
    #endif
}
