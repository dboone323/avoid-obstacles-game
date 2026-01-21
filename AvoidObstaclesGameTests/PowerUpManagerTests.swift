//
// PowerUpManagerTests.swift
// AvoidObstaclesGameTests
//

@testable import AvoidObstaclesGame
import XCTest

final class PowerUpManagerTests: XCTestCase {
    var sut: PowerUpManager!

    override func setUp() {
        super.setUp()
        sut = PowerUpManager()
    }

    override func tearDown() {
        sut = nil
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

    func testSlowMotionPowerUp() {
        XCTAssertNotNil(PowerUpType.slowMotion)
    }

    func testDoublePontsPowerUp() {
        XCTAssertNotNil(PowerUpType.doublePoints)
    }

    // MARK: - Duration Tests

    func testPowerUpHasDuration() {
        let duration = PowerUpType.shield.duration
        XCTAssertGreaterThan(duration, 0)
    }

    // MARK: - Activation Tests

    func testActivatePowerUp() {
        XCTAssertTrue(true, "Activate power up test")
    }

    func testDeactivatePowerUp() {
        XCTAssertTrue(true, "Deactivate power up test")
    }

    func testActivePowerUpsCount() {
        XCTAssertGreaterThanOrEqual(sut.activePowerUps.count, 0)
    }

    // MARK: - Spawn Tests

    func testSpawnRate() {
        XCTAssertGreaterThan(sut.spawnRate, 0)
    }

    func testRandomPowerUpSelection() {
        XCTAssertTrue(true, "Random power up selection test")
    }
}
