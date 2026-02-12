//
// GameConfiguration.swift
// AvoidObstaclesGame
//
// Centralized configuration system for game constants and settings.
// Makes it easy to tune gameplay without recompiling.
//

import Foundation
import SpriteKit

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

/// Centralized game configuration
struct GameConfiguration: Codable {
    /// Player configuration
    struct Player: Codable {
        let size: CGSize
        let color: String // Hex color
        let maxSpeed: CGFloat
        let acceleration: CGFloat
        let tiltSensitivity: CGFloat

        static let `default` = Player(
            size: CGSize(width: 50, height: 50),
            color: "#007AFF",
            maxSpeed: 500,
            acceleration: 1200,
            tiltSensitivity: 0.5
        )
    }

    /// Obstacle configuration
    struct Obstacle: Codable {
        let minSize: CGSize
        let maxSize: CGSize
        let poolSize: Int
        let spawnIntervalRange: ClosedRange<TimeInterval>
        let fallSpeedRange: ClosedRange<CGFloat>

        static let `default` = Obstacle(
            minSize: CGSize(width: 30, height: 30),
            maxSize: CGSize(width: 60, height: 60),
            poolSize: 20,
            spawnIntervalRange: 0.4...1.2,
            fallSpeedRange: 150...400
        )

        // swiftlint:disable:next nesting
        enum CodingKeys: String, CodingKey {
            case minSize, maxSize, poolSize
            case spawnIntervalRange
            case fallSpeedRange
        }

        init(
            minSize: CGSize,
            maxSize: CGSize,
            poolSize: Int,
            spawnIntervalRange: ClosedRange<TimeInterval>,
            fallSpeedRange: ClosedRange<CGFloat>
        ) {
            self.minSize = minSize
            self.maxSize = maxSize
            self.poolSize = poolSize
            self.spawnIntervalRange = spawnIntervalRange
            self.fallSpeedRange = fallSpeedRange
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            // Decode CGSize
            let minWidth = try container.decode(CGFloat.self, forKey: .minSize)
            let minHeight = minWidth
            minSize = CGSize(width: minWidth, height: minHeight)

            let maxWidth = try container.decode(CGFloat.self, forKey: .maxSize)
            let maxHeight = maxWidth
            maxSize = CGSize(width: maxWidth, height: maxHeight)

            poolSize = try container.decode(Int.self, forKey: .poolSize)

            // Decode ranges
            let spawnMin = try container.decode(TimeInterval.self, forKey: .spawnIntervalRange)
            let spawnMax = spawnMin * 3
            spawnIntervalRange = spawnMin...spawnMax

            let speedMin = try container.decode(CGFloat.self, forKey: .fallSpeedRange)
            let speedMax = speedMin * 2.5
            fallSpeedRange = speedMin...speedMax
        }
    }

    /// Difficulty configuration
    struct Difficulty: Codable {
        let levels: [DifficultyLevel]

        // swiftlint:disable:next nesting
        struct DifficultyLevel: Codable {
            let scoreThreshold: Int
            let spawnInterval: TimeInterval
            let obstacleSpeed: CGFloat
            let scoreMultiplier: Double
            let obstacleCount: Int
        }

        static let `default` = Difficulty(levels: [
            DifficultyLevel(
                scoreThreshold: 0,
                spawnInterval: 1.2,
                obstacleSpeed: 200,
                scoreMultiplier: 1.0,
                obstacleCount: 1
            ),
            DifficultyLevel(
                scoreThreshold: 10,
                spawnInterval: 1.0,
                obstacleSpeed: 250,
                scoreMultiplier: 1.2,
                obstacleCount: 2
            ),
            DifficultyLevel(
                scoreThreshold: 25,
                spawnInterval: 0.8,
                obstacleSpeed: 300,
                scoreMultiplier: 1.5,
                obstacleCount: 3
            ),
            DifficultyLevel(
                scoreThreshold: 50,
                spawnInterval: 0.6,
                obstacleSpeed: 350,
                scoreMultiplier: 2.0,
                obstacleCount: 4
            ),
            DifficultyLevel(
                scoreThreshold: 100,
                spawnInterval: 0.5,
                obstacleSpeed: 400,
                scoreMultiplier: 2.5,
                obstacleCount: 5
            ),
            DifficultyLevel(
                scoreThreshold: 200,
                spawnInterval: 0.4,
                obstacleSpeed: 450,
                scoreMultiplier: 3.0,
                obstacleCount: 6
            ),
        ])
    }

    /// Audio configuration
    struct Audio: Codable {
        var backgroundMusicEnabled: Bool
        var soundEffectsEnabled: Bool
        var backgroundMusicVolume: Float
        var soundEffectsVolume: Float
        var hapticsEnabled: Bool

        static let `default` = Audio(
            backgroundMusicEnabled: true,
            soundEffectsEnabled: true,
            backgroundMusicVolume: 0.6,
            soundEffectsVolume: 0.8,
            hapticsEnabled: true
        )
    }

    /// Accessibility configuration
    struct Accessibility: Codable {
        var reduceMotion: Bool
        var increaseContrast: Bool
        var largerTouchTargets: Bool
        var voiceOverEnabled: Bool
        var colorBlindMode: String // "none", "protanopia", "deuteranopia", "tritanopia"

        static let `default` = Accessibility(
            reduceMotion: false,
            increaseContrast: false,
            largerTouchTargets: false,
            voiceOverEnabled: false,
            colorBlindMode: "none"
        )
    }

    /// Visual configuration
    struct Visual: Codable {
        var theme: String // "light", "dark", "auto"
        var particleQuality: String // "low", "medium", "high"
        var frameRateCap: Int
        var showFPS: Bool

        static let `default` = Visual(
            theme: "auto",
            particleQuality: "high",
            frameRateCap: 60,
            showFPS: false
        )
    }

    // MARK: - Properties

    // MARK: - Properties

    var player: Player
    var obstacle: Obstacle
    var difficulty: Difficulty
    var audio: Audio
    var accessibility: Accessibility
    var visual: Visual

    // MARK: - Default Configuration

    static let `default` = GameConfiguration(
        player: .default,
        obstacle: .default,
        difficulty: .default,
        audio: .default,
        accessibility: .default,
        visual: .default
    )

    // MARK: - Persistence

    private static let configKey = "GameConfiguration"

    /// Loads configuration from UserDefaults or returns default
    static func load() -> GameConfiguration {
        guard let data = UserDefaults.standard.data(forKey: configKey),
              let config = try? JSONDecoder().decode(GameConfiguration.self, from: data)
        else {
            return .default
        }
        return config
    }

    /// Saves configuration to UserDefaults
    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: Self.configKey)
        UserDefaults.standard.synchronize()
    }

    /// Resets to default configuration
    static func reset() {
        UserDefaults.standard.removeObject(forKey: configKey)
        UserDefaults.standard.synchronize()
    }

    // MARK: - Convenience Accessors

    var isDarkMode: Bool {
        if visual.theme == "dark" {
            return true
        } else if visual.theme == "light" {
            return false
        } else {
            // Auto: follow system
            #if os(iOS)
                if #available(iOS 13.0, *) {
                    return UITraitCollection.current.userInterfaceStyle == .dark
                }
            #elseif os(macOS)
                if #available(macOS 10.14, *) {
                    return NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                }
            #endif
            return false
        }
    }

    var shouldReduceMotion: Bool {
        #if os(iOS)
            return accessibility.reduceMotion || UIAccessibility.isReduceMotionEnabled
        #else
            return accessibility.reduceMotion
        #endif
    }

    var shouldIncreaseContrast: Bool {
        #if os(iOS)
            return accessibility.increaseContrast || UIAccessibility.isDarkerSystemColorsEnabled
        #else
            return accessibility.increaseContrast
        #endif
    }
}

// MARK: - Color Utilities

extension GameConfiguration {
    /// Converts hex string to platform color
    func color(from hex: String) -> PlatformColor {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        #if os(iOS)
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        #elseif os(macOS)
            return NSColor(red: red, green: green, blue: blue, alpha: 1.0)
        #endif
    }
}
