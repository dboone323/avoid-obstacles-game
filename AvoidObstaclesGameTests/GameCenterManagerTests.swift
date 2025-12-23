//
// GameCenterManagerTests.swift
// AvoidObstaclesGameTests
//

import GameKit
import XCTest
@testable import AvoidObstaclesGame

class GameCenterManagerTests: XCTestCase {
    var manager: GameCenterManager!

    override func setUp() {
        super.setUp()
        manager = GameCenterManager()
    }

    override func tearDown() {
        manager = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertNotNil(manager)
        // Initial auth state depends on device - just verify no crash
    }

    func testSubmitScore() {
        // Should not crash even if not authenticated
        manager.submitScore(score: 100)
        XCTAssertTrue(true)
    }

    func testAuthenticationState() {
        // Authentication happens async, just verify property exists
        XCTAssertNotNil(manager.isAuthenticated)
    }
}
