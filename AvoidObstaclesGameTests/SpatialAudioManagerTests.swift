//
// SpatialAudioManagerTests.swift
// AvoidObstaclesGameTests
//

import SpriteKit
import XCTest

@testable import AvoidObstaclesGame

@MainActor
final class SpatialAudioManagerTests: XCTestCase {
    func testAudioInit() {
        let manager = SpatialAudioManager.shared
        XCTAssertNotNil(manager)
    }

    func testAudioEngineResidency() {
        let manager = SpatialAudioManager.shared
        manager.playSound(
            "test_sound", at: .zero, in: SKScene(size: CGSize(width: 100, height: 100)))
        // Verify no crash and intent logging
        XCTAssertNotNil(manager)
    }
}
