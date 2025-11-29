//
// ComboSystemTests.swift
// AvoidObstaclesGameTests
//

import XCTest
@testable import AvoidObstaclesGame

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
        comboSystem.recordDodge(currentTime: 0)
        let points1 = comboSystem.calculatePoints()
        
        comboSystem.recordDodge(currentTime: 1.0)
        let points2 = comboSystem.calculatePoints()
        
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
