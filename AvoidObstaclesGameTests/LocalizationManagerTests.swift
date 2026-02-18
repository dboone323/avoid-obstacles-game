//
// LocalizationManagerTests.swift
// AvoidObstaclesGameTests
//
// Unit tests for LocalizationManager
//

import XCTest
@testable import AvoidObstaclesGameCore

@MainActor

class LocalizationManagerTests: XCTestCase {
    var manager: LocalizationManager!

    override func setUp() {
        super.setUp()
        manager = LocalizationManager.shared
    }

    // MARK: - Language Support Tests

    func testSupportedLanguages() {
        let languages = manager.getSupportedLanguages()

        // Verify we support 6 languages
        XCTAssertEqual(languages.count, 6)

        // Verify specific languages
        XCTAssertTrue(languages.contains(.english))
        XCTAssertTrue(languages.contains(.spanish))
        XCTAssertTrue(languages.contains(.french))
        XCTAssertTrue(languages.contains(.german))
        XCTAssertTrue(languages.contains(.japanese))
        XCTAssertTrue(languages.contains(.chinese))
    }

    func testDefaultLanguage() {
        // Default should be English
        let currentLanguage = manager.getCurrentLanguage()
        XCTAssertEqual(currentLanguage, .english)
    }

    func testLanguageSwitching() {
        // Switch to Spanish
        manager.setLanguage(.spanish)
        XCTAssertEqual(manager.getCurrentLanguage(), .spanish)

        // Switch to Japanese
        manager.setLanguage(.japanese)
        XCTAssertEqual(manager.getCurrentLanguage(), .japanese)

        // Switch back to English
        manager.setLanguage(.english)
        XCTAssertEqual(manager.getCurrentLanguage(), .english)
    }

    // MARK: - Localization Key Tests

    func testMenuStrings() {
        // Menu keys should have default values
        XCTAssertEqual(manager.string(for: .menuPlay), "Play")
        XCTAssertEqual(manager.string(for: .menuSettings), "Settings")
        XCTAssertEqual(manager.string(for: .menuLeaderboard), "Leaderboard")
        XCTAssertEqual(manager.string(for: .menuQuit), "Quit")
    }

    func testGameStrings() {
        XCTAssertEqual(manager.string(for: .gameScore), "Score")
        XCTAssertEqual(manager.string(for: .gameHighScore), "High Score")
        XCTAssertEqual(manager.string(for: .gamePaused), "Paused")
        XCTAssertEqual(manager.string(for: .gameOver), "Game Over")
    }

    func testTutorialStrings() {
        XCTAssertFalse(manager.string(for: .tutorialWelcome).isEmpty)
        XCTAssertFalse(manager.string(for: .tutorialControls).isEmpty)
        XCTAssertFalse(manager.string(for: .tutorialObjective).isEmpty)
    }

    func testAchievementStrings() {
        XCTAssertEqual(manager.string(for: .achievementUnlocked), "Achievement Unlocked!")
        XCTAssertFalse(manager.string(for: .achievementFirstGame).isEmpty)
        XCTAssertFalse(manager.string(for: .achievementScore100).isEmpty)
    }

    func testAccessibilityStrings() {
        XCTAssertFalse(manager.string(for: .accessibilityPlayerLabel).isEmpty)
        XCTAssertFalse(manager.string(for: .accessibilityObstacleLabel).isEmpty)
        XCTAssertFalse(manager.string(for: .accessibilityPowerUpLabel).isEmpty)
    }

    // MARK: - Language Display Names

    func testLanguageDisplayNames() {
        XCTAssertEqual(LocalizationManager.Language.english.displayName, "English")
        XCTAssertEqual(LocalizationManager.Language.spanish.displayName, "Español")
        XCTAssertEqual(LocalizationManager.Language.french.displayName, "Français")
        XCTAssertEqual(LocalizationManager.Language.german.displayName, "Deutsch")
        XCTAssertEqual(LocalizationManager.Language.japanese.displayName, "日本語")
        XCTAssertEqual(LocalizationManager.Language.chinese.displayName, "简体中文")
    }

    // MARK: - Notification Tests

    func testLanguageChangeNotification() {
        let expectation = XCTestExpectation(description: "Language change notification")

        let observer = NotificationCenter.default.addObserver(
            forName: .languageDidChange,
            object: nil,
            queue: .main
        ) { _ in
            expectation.fulfill()
        }

        // Change language
        manager.setLanguage(.spanish)

        wait(for: [expectation], timeout: 1.0)

        NotificationCenter.default.removeObserver(observer)
    }

    // MARK: - Edge Cases

    func testAllLocalizationKeysHaveValues() {
        // Verify no localization key returns empty string
        let keys: [LocalizationKey] = [
            .menuPlay, .menuSettings, .menuLeaderboard, .menuQuit,
            .gameScore, .gameHighScore, .gamePaused, .gameOver,
            .tutorialWelcome, .tutorialControls,
            .achievementUnlocked, .achievementFirstGame,
            .accessibilityPlayerLabel, .accessibilityObstacleLabel,
        ]

        for key in keys {
            let value = manager.string(for: key)
            XCTAssertFalse(value.isEmpty, "Key \(key) should have a value")
        }
    }
}
