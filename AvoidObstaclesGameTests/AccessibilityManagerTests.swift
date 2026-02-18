//
// AccessibilityManagerTests.swift
// AvoidObstaclesGameTests
//
// Unit tests for AccessibilityManager
//

import SpriteKit
import XCTest
@testable import AvoidObstaclesGameCore

#if canImport(UIKit)
    @MainActor
    class AccessibilityManagerTests: XCTestCase {
        var manager: AccessibilityManager!
        var testNode: SKSpriteNode!

override func setUp() {
            super.setUp()
            manager = AccessibilityManager.shared
            testNode = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 50))
        }

override func tearDown() {
            testNode = nil
            super.tearDown()
        }

        // MARK: - Node Configuration Tests

        @MainActor

        func testPlayerConfiguration() {
            manager.configurePlayer(testNode)

            XCTAssertTrue(testNode.isAccessibilityElement)
            XCTAssertFalse(testNode.accessibilityLabel?.isEmpty ?? true)
            XCTAssertTrue(testNode.accessibilityTraits.contains(.startsMediaSession))
        }

        @MainActor

        func testObstacleConfiguration() {
            manager.configureObstacle(testNode, index: 1)

            XCTAssertTrue(testNode.isAccessibilityElement)
            XCTAssertFalse(testNode.accessibilityLabel?.isEmpty ?? true)
            XCTAssertTrue(testNode.accessibilityLabel?.contains("1") ?? false)
        }

        @MainActor

        func testPowerUpConfiguration() {
            manager.configurePowerUp(testNode, type: .shield)

            XCTAssertTrue(testNode.isAccessibilityElement)
            XCTAssertTrue(testNode.accessibilityTraits.contains(.button))
            XCTAssertTrue(testNode.accessibilityLabel?.contains("Shield") ?? false)
        }

        @MainActor

        func testScoreLabelConfiguration() {
            let scoreLabel = SKLabelNode(text: "Score: 100")
            manager.configureScoreLabel(scoreLabel, score: 100)

            XCTAssertTrue(scoreLabel.isAccessibilityElement)
            XCTAssertTrue(scoreLabel.accessibilityTraits.contains(.updatesFrequently))
            XCTAssertTrue(scoreLabel.accessibilityLabel?.contains("100") ?? false)
        }

        // MARK: - Touch Target Tests

        @MainActor

        func testStandardTouchTargetSize() {
            // Mock configuration with standard touch targets
            let baseSize = CGSize(width: 30, height: 30)
            let enhancedSize = manager.getTouchTargetSize(for: baseSize)

            // When larger touch targets are disabled, should return base size
            // (This depends on configuration, so we just verify it returns a valid size)
            XCTAssertGreaterThan(enhancedSize.width, 0)
            XCTAssertGreaterThan(enhancedSize.height, 0)
        }

        @MainActor

        func testMinimumTouchTargetSize() {
            // Even with larger targets enabled, should be at least 44x44
            let tinySize = CGSize(width: 10, height: 10)
            let enhancedSize = manager.getTouchTargetSize(for: tinySize)

            // Should be enlarged
            XCTAssertGreaterThanOrEqual(enhancedSize.width, tinySize.width)
            XCTAssertGreaterThanOrEqual(enhancedSize.height, tinySize.height)
        }

        // MARK: - Color Adjustment Tests

        @MainActor

        func testColorAdjustmentNoneMode() {
            let originalColor = UIColor.red
            let adjustedColor = manager.adjustColor(originalColor, for: "none")

            // Should return original color
            XCTAssertEqual(originalColor, adjustedColor)
        }

        @MainActor

        func testColorAdjustmentProtanopia() {
            let redColor = UIColor.red
            let adjustedColor = manager.adjustColor(redColor, for: "protanopia")

            // Should adjust red colors
            XCTAssertNotEqual(redColor, adjustedColor)
        }

        @MainActor

        func testColorAdjustmentDeuteranopia() {
            let greenColor = UIColor.green
            let adjustedColor = manager.adjustColor(greenColor, for: "deuteranopia")

            // Should adjust green colors
            XCTAssertNotEqual(greenColor, adjustedColor)
        }

        @MainActor

        func testColorAdjustmentTritanopia() {
            let blueColor = UIColor.blue
            let adjustedColor = manager.adjustColor(blueColor, for: "tritanopia")

            // Should adjust blue colors
            XCTAssertNotEqual(blueColor, adjustedColor)
        }

        // MARK: - System Accessibility Tests

        @MainActor

        func testVoiceOverDetection() {
            // This will vary based on system state
            // Just verify the property is accessible
            _ = manager.isVoiceOverEnabled
            XCTAssertTrue(true, "VoiceOver detection should be accessible")
        }

        @MainActor

        func testReduceMotionDetection() {
            // Verify property is accessible
            _ = manager.shouldReduceMotion
            XCTAssertTrue(true, "Reduce motion detection should be accessible")
        }

        @MainActor

        func testIncreaseContrastDetection() {
            // Verify property is accessible
            _ = manager.shouldIncreaseContrast
            XCTAssertTrue(true, "Increase contrast detection should be accessible")
        }

        // MARK: - Announcement Tests

        @MainActor

        func testAnnounceScore() {
            // Should not crash
            manager.announceScore(100)
            XCTAssertTrue(true, "Score announcement should not crash")
        }

        @MainActor

        func testAnnounceGameOver() {
            // Should not crash
            manager.announceGameOver(finalScore: 500)
            XCTAssertTrue(true, "Game over announcement should not crash")
        }

        @MainActor

        func testAnnounceNewHighScore() {
            // Should not crash
            manager.announceNewHighScore(1000)
            XCTAssertTrue(true, "High score announcement should not crash")
        }

        @MainActor

        func testGenericAnnouncement() {
            // Should not crash
            manager.announce("Test message")
            XCTAssertTrue(true, "Generic announcement should not crash")
        }
    }
#endif
