//
// LocalizationManager.swift
// AvoidObstaclesGame
//
// Manages localized strings and language preferences.
//

import Foundation

/// Manages localization and language preferences
class LocalizationManager {
    // MARK: - Singleton

    @MainActor static let shared = LocalizationManager()

    // MARK: - Properties

    /// Supported languages
    enum Language: String, CaseIterable {
        case english = "en"
        case spanish = "es"
        case french = "fr"
        case german = "de"
        case japanese = "ja"
        case chinese = "zh-Hans"

        var displayName: String {
            switch self {
            case .english: "English"
            case .spanish: "Español"
            case .french: "Français"
            case .german: "Deutsch"
            case .japanese: "日本語"
            case .chinese: "简体中文"
            }
        }
    }

    private var currentLanguage: Language {
        get {
            guard let code = UserDefaults.standard.string(forKey: "AppLanguage"),
                  let language = Language(rawValue: code)
            else {
                return .english
            }
            return language
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "AppLanguage")
            UserDefaults.standard.synchronize()
        }
    }

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /// Get localized string  for key
    func string(for key: LocalizationKey) -> String {
        // In production, this would load from .strings files
        // For now, returning English defaults
        key.defaultValue
    }

    /// Set current language
    func setLanguage(_ language: Language) {
        currentLanguage = language
        NotificationCenter.default.post(name: .languageDidChange, object: nil)
    }

    /// Get current language
    func getCurrentLanguage() -> Language {
        currentLanguage
    }

    /// Get all supported languages
    func getSupportedLanguages() -> [Language] {
        Language.allCases
    }
}

// MARK: - Localization Keys

enum LocalizationKey {
    // Menu
    case menuPlay
    case menuSettings
    case menuLeaderboard
    case menuQuit

    // Game
    case gameScore
    case gameHighScore
    case gamePaused
    case gameOver
    case gameNewHighScore

    // Settings
    case settingsTitle
    case settingsAudio
    case settingsGraphics
    case settingsControls
    case settingsAccessibility
    case settingsLanguage

    // Tutorial
    case tutorialWelcome
    case tutorialControls
    case tutorialObjective
    case tutorialStart

    // Achievements
    case achievementUnlocked
    case achievementFirstGame
    case achievementScore100
    case achievementScore500
    case achievementScore1000

    // Accessibility
    case accessibilityPlayerLabel
    case accessibilityObstacleLabel
    case accessibilityPowerUpLabel
    case accessibilityScoreLabel

    var defaultValue: String {
        switch self {
        // Menu
        case .menuPlay: "Play"
        case .menuSettings: "Settings"
        case .menuLeaderboard: "Leaderboard"
        case .menuQuit: "Quit"
        // Game
        case .gameScore: "Score"
        case .gameHighScore: "High Score"
        case .gamePaused: "Paused"
        case .gameOver: "Game Over"
        case .gameNewHighScore: "New High Score!"
        // Settings
        case .settingsTitle: "Settings"
        case .settingsAudio: "Audio"
        case .settingsGraphics: "Graphics"
        case .settingsControls: "Controls"
        case .settingsAccessibility: "Accessibility"
        case .settingsLanguage: "Language"
        // Tutorial
        case .tutorialWelcome: "Welcome to Avoid Obstacles!"
        case .tutorialControls: "Tap or tilt to move your ship"
        case .tutorialObjective: "Dodge falling obstacles to score points"
        case .tutorialStart: "Tap to Start"
        // Achievements
        case .achievementUnlocked: "Achievement Unlocked!"
        case .achievementFirstGame: "First Steps"
        case .achievementScore100: "Century"
        case .achievementScore500: "High Flyer"
        case .achievementScore1000: "Legend"
        // Accessibility
        case .accessibilityPlayerLabel: "Player ship"
        case .accessibilityObstacleLabel: "Obstacle"
        case .accessibilityPowerUpLabel: "Power-up"
        case .accessibilityScoreLabel: "Score: %d points"
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let languageDidChange = Notification.Name("LanguageDidChange")
}
