//
// ComboSystemTests.swift
// AvoidObstaclesGameTests
//

import XCTest
@testable import AvoidObstaclesGame

@MainActor

class ComboSystemTests: XCTestCase {
    var comboSystem: ComboSystem!

    override func setUp() {
        super.setUp()
        comboSystem = ComboSystem.shared
        comboSystem.resetCombo()
    }

    func testInitialState() {
        XCTAssertEqual(comboSystem.getCurrentCombo(), 0)
    }

    func testRecordDodge() {
        comboSystem.recordDodge(currentTime: 0)
        XCTAssertEqual(comboSystem.getCurrentCombo(), 1)

        comboSystem.recordDodge(currentTime: 1.0)
        XCTAssertEqual(comboSystem.getCurrentCombo(), 2)
    }

    func testComboTimeout() {
        comboSystem.recordDodge(currentTime: 0)
        XCTAssertEqual(comboSystem.getCurrentCombo(), 1)

        // Wait for timeout
        comboSystem.recordDodge(currentTime: 3.0)
        XCTAssertEqual(comboSystem.getCurrentCombo(), 1) // Reset to 1
    }

    func testComboPoints() {
        // First point calculation at combo 1
        comboSystem.recordDodge(currentTime: 0)
        let points1 = comboSystem.calculatePoints() // combo=1: 1 + 1/10 = 1

        // Do 9 more dodges to reach combo 10
        for i in 1..<10 {
            comboSystem.recordDodge(currentTime: Double(i) * 0.5)
        }
        let points2 = comboSystem.calculatePoints() // combo=10: 1 + 10/10 = 2

        XCTAssertGreaterThan(points2, points1)
    }

    func testComboMultiplier() {
        let initial = comboSystem.getMultiplier()

        comboSystem.recordDodge(currentTime: 0)
        let after = comboSystem.getMultiplier()

        XCTAssertGreaterThan(after, initial)
    }

    func testResetCombo() {
        comboSystem.recordDodge(currentTime: 0)
        XCTAssertGreaterThan(comboSystem.getCurrentCombo(), 0)

        comboSystem.resetCombo()
        XCTAssertEqual(comboSystem.getCurrentCombo(), 0)
    }
}
