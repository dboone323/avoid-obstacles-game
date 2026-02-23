import XCTest
@testable import AvoidObstaclesGame

/// Comprehensive tests for HapticFeedbackManager

@MainActor

final class HapticFeedbackManagerTests: XCTestCase {
    var sut: HapticFeedbackManager!

    override func setUp() {
        super.setUp()
        sut = HapticFeedbackManager.shared
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testSharedInstance() {
        XCTAssertNotNil(sut)
        XCTAssertTrue(sut === HapticFeedbackManager.shared, "Should return same shared instance")
    }

    func testPrepare() {
        XCTAssertNoThrow(sut.prepare())
    }

    // MARK: - Impact Feedback Tests

    func testLightImpact() {
        XCTAssertNoThrow(sut.light())
    }

    func testMediumImpact() {
        XCTAssertNoThrow(sut.medium())
    }

    func testHeavyImpact() {
        XCTAssertNoThrow(sut.heavy())
    }

    func testCustomIntensityImpact() {
        if #available(iOS 13.0, *) {
            XCTAssertNoThrow(sut.impact(intensity: 0.5))
            XCTAssertNoThrow(sut.impact(intensity: 0.0))
            XCTAssertNoThrow(sut.impact(intensity: 1.0))
        }
    }

    // MARK: - Selection Feedback Tests

    func testSelection() {
        XCTAssertNoThrow(sut.selection())
    }

    // MARK: - Notification Feedback Tests

    func testSuccess() {
        XCTAssertNoThrow(sut.success())
    }

    func testWarning() {
        XCTAssertNoThrow(sut.warning())
    }

    func testError() {
        XCTAssertNoThrow(sut.error())
    }

    // MARK: - Game-Specific Feedback Tests

    func testObstacleDodged() {
        XCTAssertNoThrow(sut.obstacleDodged())
    }

    func testPowerUpCollected() {
        XCTAssertNoThrow(sut.powerUpCollected())
    }

    func testCollision() {
        XCTAssertNoThrow(sut.collision())
    }

    func testScoreMilestone() {
        XCTAssertNoThrow(sut.scoreMilestone())
    }

    func testDifficultyIncrease() {
        XCTAssertNoThrow(sut.difficultyIncrease())
    }

    func testGameStart() {
        XCTAssertNoThrow(sut.gameStart())
    }

    func testGamePause() {
        XCTAssertNoThrow(sut.gamePause())
    }

    func testGameResume() {
        XCTAssertNoThrow(sut.gameResume())
    }

    // MARK: - Pattern Feedback Tests

    func testPlayPattern_Countdown() {
        XCTAssertNoThrow(sut.playPattern(.countdown))
    }

    func testPlayPattern_Combo() {
        XCTAssertNoThrow(sut.playPattern(.combo))
    }

    func testPlayPattern_Achievement() {
        XCTAssertNoThrow(sut.playPattern(.achievement))
    }

    func testPlayPattern_CustomPattern() {
        let customPattern = HapticPattern(events: [
            HapticPattern.Event(type: .light, delay: 0.0),
            HapticPattern.Event(type: .success, delay: 0.1),
        ])
        XCTAssertNoThrow(sut.playPattern(customPattern))
    }

    func testPlayPattern_EmptyPattern() {
        let emptyPattern = HapticPattern(events: [])
        XCTAssertNoThrow(sut.playPattern(emptyPattern))
    }

    // MARK: - Integration Tests

    func testMultipleHapticsInSequence() {
        XCTAssertNoThrow(
            {
                sut.light()
                sut.medium()
                sut.heavy()
                sut.selection()
                sut.success()
            }()
        )
    }

    func testRapidFireHaptics() {
        for _ in 0..<10 {
            XCTAssertNoThrow(sut.light())
        }
    }

    // MARK: - Haptic Pattern Tests

    func testHapticPatternEventTypes() {
        let allTypes: [HapticPattern.Event.EventType] = [
            .light, .medium, .heavy,
            .selection,
            .success, .warning, .error,
        ]

        for eventType in allTypes {
            let event = HapticPattern.Event(type: eventType, delay: 0.0)
            XCTAssertEqual(event.delay, 0.0)
        }
    }

    func testPredefinedPatterns() {
        // Countdown pattern
        XCTAssertEqual(HapticPattern.countdown.events.count, 4)

        // Combo pattern
        XCTAssertEqual(HapticPattern.combo.events.count, 3)

        // Achievement pattern
        XCTAssertEqual(HapticPattern.achievement.events.count, 3)
    }
}
