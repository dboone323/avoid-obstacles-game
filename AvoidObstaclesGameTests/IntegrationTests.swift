//
// IntegrationTests.swift
// AvoidObstaclesGameTests
//

import XCTest
@testable import AvoidObstaclesGame

class IntegrationTests: XCTestCase {
    
    func testFullGameFlow() {
        // Initialize all managers
        _ = GameConfiguration.load()
        _ = ThemeManager.shared
        _ = LocalizationManager.shared
        _ = AccessibilityManager.shared
        
        // Simulate game start
        AnalyticsManager.shared.trackGameStart()
        
        // Simulate gameplay
        for i in 0..<10 {
            ComboSystem.shared.recordDodge(currentTime: Double(i) * 0.5)
        }
        
        // Simulate game over
        let score = ComboSystem.shared.calculatePoints()
        AnalyticsManager.shared.trackGameOver(score: score, survivalTime: 10.0)
        
        XCTAssertGreaterThan(score, 0)
    }
    
    func testPowerUpAndComboInteraction() {
        let powerUp = PowerUpSystem.shared
        let combo = ComboSystem.shared
        
        combo.recordDodge(currentTime: 0)
        powerUp.activate(.doublePoints)
        
        let baseMultiplier = combo.getMultiplier()
        let scoreMultiplier = powerUp.getScoreMultiplier()
        
        XCTAssertGreaterThan(baseMultiplier * scoreMultiplier, 1.0)
    }
    
    func testThemeAndAccessibilityInteraction() {
        ThemeManager.shared.setTheme("dark")
        let color = ThemeManager.shared.accessibleColor(for: .player)
        
        XCTAssertNotNil(color)
    }
}
