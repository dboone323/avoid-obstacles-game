//
// HapticFeedbackManagerTests.swift
// AvoidObstaclesGameTests
//
// Tests for haptic feedback management
//

import XCTest
@testable import AvoidObstaclesGame

final class HapticFeedbackManagerTests: XCTestCase {
    
    var manager: HapticFeedbackManager!
    
    override func setUpWithError() throws {
        manager = HapticFeedbackManager.shared
    }
    
    // MARK: - Singleton Tests
    
    func testSharedInstance() {
        let instance1 = HapticFeedbackManager.shared
        let instance2 = HapticFeedbackManager.shared
        XCTAssertTrue(instance1 === instance2)
    }
    
    // MARK: - Haptic Pattern Tests
    
    func testCountdownPatternHasFourEvents() {
        let pattern = HapticPattern.countdown
        XCTAssertEqual(pattern.events.count, 4)
    }
    
    func testComboPatternHasThreeEvents() {
        let pattern = HapticPattern.combo
        XCTAssertEqual(pattern.events.count, 3)
    }
    
    func testAchievementPatternHasThreeEvents() {
        let pattern = HapticPattern.achievement
        XCTAssertEqual(pattern.events.count, 3)
    }
    
    func testPatternEventTypes() {
        let combo = HapticPattern.combo
        XCTAssertEqual(combo.events[0].type, .light)
        XCTAssertEqual(combo.events[1].type, .medium)
        XCTAssertEqual(combo.events[2].type, .heavy)
    }
    
    func testPatternEventDelays() {
        let combo = HapticPattern.combo
        XCTAssertEqual(combo.events[0].delay, 0.0)
        XCTAssertEqual(combo.events[1].delay, 0.1)
        XCTAssertEqual(combo.events[2].delay, 0.2)
    }
    
    // MARK: - Haptic Method Tests (Smoke Tests)
    // These verify methods don't crash; actual haptic output cannot be tested
    
    func testPrepareDoesNotCrash() {
        manager.prepare()
        // No assertion needed - just verify no crash
        XCTAssertTrue(true)
    }
    
    func testLightDoesNotCrash() {
        manager.light()
        XCTAssertTrue(true)
    }
    
    func testMediumDoesNotCrash() {
        manager.medium()
        XCTAssertTrue(true)
    }
    
    func testHeavyDoesNotCrash() {
        manager.heavy()
        XCTAssertTrue(true)
    }
    
    func testSelectionDoesNotCrash() {
        manager.selection()
        XCTAssertTrue(true)
    }
    
    func testSuccessDoesNotCrash() {
        manager.success()
        XCTAssertTrue(true)
    }
    
    func testWarningDoesNotCrash() {
        manager.warning()
        XCTAssertTrue(true)
    }
    
    func testErrorDoesNotCrash() {
        manager.error()
        XCTAssertTrue(true)
    }
    
    // MARK: - Game Event Tests
    
    func testGameEventMethodsDoNotCrash() {
        manager.obstacleDodged()
        manager.powerUpCollected()
        manager.collision()
        manager.scoreMilestone()
        manager.difficultyIncrease()
        manager.gameStart()
        manager.gamePause()
        manager.gameResume()
        XCTAssertTrue(true)
    }
    
    func testPlayPatternDoesNotCrash() {
        manager.playPattern(.combo)
        manager.playPattern(.countdown)
        manager.playPattern(.achievement)
        XCTAssertTrue(true)
    }
}
