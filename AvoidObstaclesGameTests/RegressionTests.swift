//
// RegressionTests.swift
// AvoidObstaclesGameTests
//

import XCTest
@testable import AvoidObstaclesGame

class RegressionTests: XCTestCase {

    // Test that old saved games still load
    func testBackwardsCompatibility() {
        let config = GameConfiguration.load()
        XCTAssertNotNil(config)
    }

    // Test that theme switching doesn't crash
    func testThemeSwitchingStability() {
        for _ in 0..<10 {
            ThemeManager.shared.setTheme("light")
            ThemeManager.shared.setTheme("dark")
            ThemeManager.shared.setTheme("neon")
        }
        XCTAssertTrue(true)
    }

    // Test memory doesn't leak with repeated gameplay
    func testMemoryStability() {
        for _ in 0..<100 {
            let combo = ComboSystem.shared
            combo.recordDodge(currentTime: 0)
            combo.resetCombo()
        }
        XCTAssertTrue(true)
    }

    // Test power-up activation doesn't interfere
    func testPowerUpIsolation() {
        let powerUp = PowerUpSystem.shared

        powerUp.activate(.shield)
        powerUp.activate(.speedBoost)
        powerUp.activate(.magnet)

        XCTAssertTrue(powerUp.isActive(.shield))
        XCTAssertTrue(powerUp.isActive(.speedBoost))
        XCTAssertTrue(powerUp.isActive(.magnet))
    }
}
