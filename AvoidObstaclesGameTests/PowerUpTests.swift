//
// PowerUpTests.swift
// AvoidObstaclesGameTests
//

import XCTest
@testable import AvoidObstaclesGame

class PowerUpTests: XCTestCase {
    var powerUpSystem: PowerUpSystem!

    override func setUp() {
        super.setUp()
        powerUpSystem = PowerUpSystem.shared
    }

    func testAllPowerUpTypes() {
        XCTAssertEqual(PowerUpType.allCases.count, 5)
    }

    func testActivatePowerUp() {
        powerUpSystem.activate(.shield, duration: 1.0)
        XCTAssertTrue(powerUpSystem.isActive(.shield))
    }

    func testPowerUpExpiry() {
        let expectation = XCTestExpectation(description: "Power-up expires")

        powerUpSystem.activate(.shield, duration: 0.5)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertFalse(self.powerUpSystem.isActive(.shield))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testScoreMultiplier() {
        XCTAssertEqual(powerUpSystem.getScoreMultiplier(), 1.0)

        powerUpSystem.activate(.doublePoints)
        XCTAssertEqual(powerUpSystem.getScoreMultiplier(), 2.0)
    }
}
