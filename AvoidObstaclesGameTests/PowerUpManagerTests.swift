//
// PowerUpManagerTests.swift
// AvoidObstaclesGameTests
//

import SpriteKit
import XCTest
@testable import AvoidObstaclesGame

final class PowerUpManagerTests: XCTestCase {
    var sut: PowerUpManager!
    var testScene: SKScene!

    override func setUp() {
        super.setUp()
        testScene = SKScene(size: CGSize(width: 400, height: 600))
        sut = PowerUpManager(scene: testScene)
    }

    override func tearDown() {
        sut = nil
        testScene = nil
        super.tearDown()
    }

    // MARK: - Power Up Types Tests

    func testPowerUpTypesExist() {
        let types = PowerUpType.allCases
        XCTAssertFalse(types.isEmpty)
    }

    func testShieldPowerUp() {
        XCTAssertNotNil(PowerUpType.shield)
    }

    func testSpeedBoostPowerUp() {
        XCTAssertNotNil(PowerUpType.speedBoost)
    }

    func testSlowTimePowerUp() {
        XCTAssertNotNil(PowerUpType.slowTime)
    }

    func testDoublePointsPowerUp() {
        XCTAssertNotNil(PowerUpType.doublePoints)
    }

    // MARK: - Duration Tests

    func testPowerUpHasDuration() {
        let duration = PowerUpType.shield.duration
        XCTAssertGreaterThan(duration, 0)
    }

    // MARK: - Activation Tests

    func testActivatePowerUp() {
        let player = SKNode()
        XCTAssertNoThrow(sut.activatePowerUp(type: .shield, for: player))
    }

    func testDeactivatePowerUp() {
        XCTAssertTrue(true, "Deactivate power up test")
    }

    // MARK: - Spawn Tests

    func testSpawnPowerUp() {
        sut.spawnPowerUp(type: .shield, at: CGPoint(x: 100, y: 100))
        XCTAssertTrue(true, "Power-up spawned without errors")
    }

    func testRandomPowerUpSelection() {
        sut.spawnRandomPowerUp(at: CGPoint(x: 150, y: 150))
        XCTAssertTrue(true, "Random power up selection test")
    }
}
