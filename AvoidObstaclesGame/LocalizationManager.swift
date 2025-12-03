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

    static let shared = LocalizationManager()

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
            case .english: return "English"
            case .spanish: return "Español"
            case .french: return "Français"
            case .german: return "Deutsch"
            case .japanese: return "日本語"
            case .chinese: return "简体中文"
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
        case .menuPlay: return "Play"
        case .menuSettings: return "Settings"
        case .menuLeaderboard: return "Leaderboard"
        case .menuQuit: return "Quit"
        // Game
        case .gameScore: return "Score"
        case .gameHighScore: return "High Score"
        case .gamePaused: return "Paused"
        case .gameOver: return "Game Over"
        case .gameNewHighScore: return "New High Score!"
        // Settings
        case .settingsTitle: return "Settings"
        case .settingsAudio: return "Audio"
        case .settingsGraphics: return "Graphics"
        case .settingsControls: return "Controls"
        case .settingsAccessibility: return "Accessibility"
        case .settingsLanguage: return "Language"
        // Tutorial
        case .tutorialWelcome: return "Welcome to Avoid Obstacles!"
        case .tutorialControls: return "Tap or tilt to move your ship"
        case .tutorialObjective: return "Dodge falling obstacles to score points"
        case .tutorialStart: return "Tap to Start"
        // Achievements
        case .achievementUnlocked: return "Achievement Unlocked!"
        case .achievementFirstGame: return "First Steps"
        case .achievementScore100: return "Century"
        case .achievementScore500: return "High Flyer"
        case .achievementScore1000: return "Legend"
        // Accessibility
        case .accessibilityPlayerLabel: return "Player ship"
        case .accessibilityObstacleLabel: return "Obstacle"
        case .accessibilityPowerUpLabel: return "Power-up"
        case .accessibilityScoreLabel: return "Score: %d points"
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let languageDidChange = Notification.Name("LanguageDidChange")
}
