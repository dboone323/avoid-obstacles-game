//
// ThemeManagerTests.swift
// AvoidObstaclesGameTests
//

@testable import AvoidObstaclesGame
import XCTest

class ThemeManagerTests: XCTestCase {
    var manager: ThemeManager!

    override func setUp() {
        super.setUp()
        manager = ThemeManager.shared
    }

    func testAllThemesAvailable() {
        let themes = manager.allThemes
        XCTAssertEqual(themes.count, 4)
    }

    func testThemeNames() {
        let themes = manager.allThemes
        let names = themes.map(\.name)

        XCTAssertTrue(names.contains("light"))
        XCTAssertTrue(names.contains("dark"))
        XCTAssertTrue(names.contains("neon"))
        XCTAssertTrue(names.contains("retro"))
    }

    func testCurrentTheme() {
        let theme = manager.currentTheme
        XCTAssertNotNil(theme)
    }

    func testColorForRole() {
        let playerColor = manager.color(for: .player)
        let obstacleColor = manager.color(for: .obstacle)

        XCTAssertNotEqual(playerColor, obstacleColor)
    }

    func testAccessibleColor() {
        let color = manager.accessibleColor(for: .player)
        XCTAssertNotNil(color)
    }
}
