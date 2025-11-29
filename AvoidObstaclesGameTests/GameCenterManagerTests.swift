//
// GameCenterManagerTests.swift
// AvoidObstaclesGameTests
//

import XCTest
import GameKit
@testable import AvoidObstaclesGame

class GameCenterManagerTests: XCTestCase {
    var manager: GameCenterManager!
    
    override func setUp() {
        super.setUp()
        manager = GameCenterManager.shared
    }
    
    func testSingleton() {
        XCTAssertTrue(GameCenterManager.shared === manager)
    }
    
    func testInitialState() {
        // Authentication state depends on device/simulator
        XCTAssertNotNil(manager)
    }
    
    func testSubmitScore() {
        // Should not crash even if not authenticated
        manager.submitScore(100)
        XCTAssertTrue(true)
    }
    
    func testReportAchievement() {
        // Should not crash
        manager.reportAchievement("test_achievement")
        XCTAssertTrue(true)
    }
}
