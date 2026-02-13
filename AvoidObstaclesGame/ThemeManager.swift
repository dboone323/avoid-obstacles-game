//
// ThemeManager.swift
// AvoidObstaclesGame
//
// Manages visual themes including dark mode
//

import Foundation
import SpriteKit

#if canImport(UIKit)
    import UIKit

    /// Manages visual themes and color schemes
    class ThemeManager {
        // MARK: - Singleton

        @MainActor static let shared = ThemeManager()

        // MARK: - Theme Definition

        struct Theme {
            let name: String
            let backgroundColor: UIColor
            let playerColor: UIColor
            let obstacleColor: UIColor
            let powerUpColor: UIColor
            let uiTextColor: UIColor
            let uiBackgroundColor: UIColor
            let accentColor: UIColor

            // Particle colors
            let particleColor: UIColor
            let trailColor: UIColor

            // UI elements
            let buttonBackground: UIColor
            let buttonText: UIColor
        }

        // MARK: - Built-in Themes

        static let lightTheme = Theme(
            name: "light",
            backgroundColor: UIColor(white: 0.95, alpha: 1.0),
            playerColor: .systemBlue,
            obstacleColor: .systemRed,
            powerUpColor: .systemGreen,
            uiTextColor: .black,
            uiBackgroundColor: .white,
            accentColor: .systemBlue,
            particleColor: .cyan,
            trailColor: UIColor.cyan.withAlphaComponent(0.5),
            buttonBackground: .systemBlue,
            buttonText: .white
        )

        static let darkTheme = Theme(
            name: "dark",
            backgroundColor: UIColor(white: 0.1, alpha: 1.0),
            playerColor: UIColor(red: 0.0, green: 0.7, blue: 1.0, alpha: 1.0),
            obstacleColor: UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0),
            powerUpColor: UIColor(red: 0.3, green: 1.0, blue: 0.5, alpha: 1.0),
            uiTextColor: .white,
            uiBackgroundColor: UIColor(white: 0.15, alpha: 0.9),
            accentColor: UIColor(red: 0.0, green: 0.7, blue: 1.0, alpha: 1.0),
            particleColor: UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0),
            trailColor: UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.3),
            buttonBackground: UIColor(red: 0.0, green: 0.7, blue: 1.0, alpha: 1.0),
            buttonText: .white
        )

        static let neonTheme = Theme(
            name: "neon",
            backgroundColor: .black,
            playerColor: UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0), // Magenta
            obstacleColor: UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0), // Cyan
            powerUpColor: UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0), // Yellow
            uiTextColor: UIColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 1.0), // Bright green
            uiBackgroundColor: UIColor(white: 0.05, alpha: 0.95),
            accentColor: UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0),
            particleColor: UIColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 1.0),
            trailColor: UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 0.5),
            buttonBackground: UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0),
            buttonText: .black
        )

        static let retroTheme = Theme(
            name: "retro",
            backgroundColor: UIColor(red: 0.2, green: 0.1, blue: 0.05, alpha: 1.0),
            playerColor: UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0), // Gold
            obstacleColor: UIColor(red: 0.6, green: 0.2, blue: 0.1, alpha: 1.0), // Brown
            powerUpColor: UIColor(red: 0.9, green: 0.9, blue: 0.7, alpha: 1.0), // Cream
            uiTextColor: UIColor(red: 0.9, green: 0.8, blue: 0.5, alpha: 1.0),
            uiBackgroundColor: UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 0.9),
            accentColor: UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0),
            particleColor: UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0),
            trailColor: UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 0.3),
            buttonBackground: UIColor(red: 0.8, green: 0.6, blue: 0.2, alpha: 1.0),
            buttonText: UIColor(red: 0.1, green: 0.05, blue: 0.0, alpha: 1.0)
        )

        // MARK: - Properties

        private var config: GameConfiguration {
            GameConfiguration.load()
        }

        var currentTheme: Theme {
            switch config.visual.theme {
            case "light":
                return ThemeManager.lightTheme
            case "dark":
                return ThemeManager.darkTheme
            case "neon":
                return ThemeManager.neonTheme
            case "retro":
                return ThemeManager.retroTheme
            case "auto":
                // Follow system appearance
                if #available(iOS 13.0, *) {
                    let isDark = UITraitCollection.current.userInterfaceStyle == .dark
                    return isDark ? ThemeManager.darkTheme : ThemeManager.lightTheme
                } else {
                    return ThemeManager.lightTheme
                }
            default:
                return ThemeManager.lightTheme
            }
        }

        var allThemes: [Theme] {
            [
                ThemeManager.lightTheme, ThemeManager.darkTheme,
                ThemeManager.neonTheme, ThemeManager.retroTheme,
            ]
        }

        // MARK: - Initialization

        private init() {
            setupNotifications()
        }

        private func setupNotifications() {
            if #available(iOS 13.0, *) {
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(systemAppearanceChanged),
                    name: UIApplication.didBecomeActiveNotification,
                    object: nil
                )
            }
        }

        @objc
        private func systemAppearanceChanged() {
            if config.visual.theme == "auto" {
                NotificationCenter.default.post(name: .themeDidChange, object: nil)
            }
        }

        // MARK: - Theme Application

        /// Applies theme to a specific node based on its role
        @MainActor
        func applyTheme(to node: SKNode, role: NodeRole) {
            let theme = currentTheme

            guard let sprite = node as? SKSpriteNode else { return }

            switch role {
            case .player:
                sprite.color = theme.playerColor
            case .obstacle:
                sprite.color = theme.obstacleColor
            case .powerUp:
                sprite.color = theme.powerUpColor
            case .ui:
                sprite.color = theme.uiBackgroundColor
            }
        }

        /// Gets color for a specific role
        func color(for role: NodeRole) -> UIColor {
            let theme = currentTheme

            switch role {
            case .player:
                return theme.playerColor
            case .obstacle:
                return theme.obstacleColor
            case .powerUp:
                return theme.powerUpColor
            case .ui:
                return theme.uiTextColor
            }
        }

        /// Adjusts color for accessibility if needed
        @MainActor
        func accessibleColor(for role: NodeRole) -> UIColor {
            var color = self.color(for: role)

            // Apply colorblind adjustment
            let colorBlindMode = config.accessibility.colorBlindMode
            if colorBlindMode != "none" {
                color = AccessibilityManager.shared.adjustColor(color, for: colorBlindMode)
            }

            // Increase contrast if needed
            if config.shouldIncreaseContrast {
                color = increaseContrast(of: color)
            }

            return color
        }

        private func increaseContrast(of color: UIColor) -> UIColor {
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0

            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

            // Increase saturation and adjust brightness for better contrast
            saturation = min(saturation * 1.3, 1.0)
            brightness = brightness < 0.5 ? max(brightness - 0.1, 0.0) : min(brightness + 0.1, 1.0)

            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        }

        // MARK: - Theme Selection

        func setTheme(_ themeName: String) {
            let modifiedConfig = config
            var visual = modifiedConfig.visual
            visual = GameConfiguration.Visual(
                theme: themeName,
                particleQuality: visual.particleQuality,
                frameRateCap: visual.frameRateCap,
                showFPS: visual.showFPS
            )

            let newConfig = GameConfiguration(
                player: modifiedConfig.player,
                obstacle: modifiedConfig.obstacle,
                difficulty: modifiedConfig.difficulty,
                audio: modifiedConfig.audio,
                accessibility: modifiedConfig.accessibility,
                visual: visual
            )

            newConfig.save()

            NotificationCenter.default.post(name: .themeDidChange, object: currentTheme)
        }
    }

    // MARK: - Node Role

    enum NodeRole {
        case player
        case obstacle
        case powerUp
        case ui
    }

    // MARK: - Notification Names

    extension Notification.Name {
        static let themeDidChange = Notification.Name("ThemeDidChange")
    }

#else

    // MARK: - macOS Implementation

    import AppKit

    /// Manages visual themes and color schemes for macOS
    class ThemeManager {
        // MARK: - Singleton

        @MainActor static let shared = ThemeManager()

        // MARK: - Theme Definition

        struct Theme {
            let name: String
            let backgroundColor: NSColor
            let playerColor: NSColor
            let obstacleColor: NSColor
            let powerUpColor: NSColor
            let uiTextColor: NSColor
            let uiBackgroundColor: NSColor
            let accentColor: NSColor

            // Particle colors
            let particleColor: NSColor
            let trailColor: NSColor

            // UI elements
            let buttonBackground: NSColor
            let buttonText: NSColor
        }

        // MARK: - Built-in Themes

        static let lightTheme = Theme(
            name: "light",
            backgroundColor: NSColor(white: 0.95, alpha: 1.0),
            playerColor: .systemBlue,
            obstacleColor: .systemRed,
            powerUpColor: .systemGreen,
            uiTextColor: .black,
            uiBackgroundColor: .white,
            accentColor: .systemBlue,
            particleColor: .cyan,
            trailColor: NSColor.cyan.withAlphaComponent(0.5),
            buttonBackground: .systemBlue,
            buttonText: .white
        )

        static let darkTheme = Theme(
            name: "dark",
            backgroundColor: NSColor(white: 0.1, alpha: 1.0),
            playerColor: NSColor(red: 0.0, green: 0.7, blue: 1.0, alpha: 1.0),
            obstacleColor: NSColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0),
            powerUpColor: NSColor(red: 0.3, green: 1.0, blue: 0.5, alpha: 1.0),
            uiTextColor: .white,
            uiBackgroundColor: NSColor(white: 0.15, alpha: 0.9),
            accentColor: NSColor(red: 0.0, green: 0.7, blue: 1.0, alpha: 1.0),
            particleColor: NSColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0),
            trailColor: NSColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.3),
            buttonBackground: NSColor(red: 0.0, green: 0.7, blue: 1.0, alpha: 1.0),
            buttonText: .white
        )

        static let neonTheme = Theme(
            name: "neon",
            backgroundColor: .black,
            playerColor: NSColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0),
            obstacleColor: NSColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0),
            powerUpColor: NSColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0),
            uiTextColor: NSColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 1.0),
            uiBackgroundColor: NSColor(white: 0.05, alpha: 0.95),
            accentColor: NSColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0),
            particleColor: NSColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 1.0),
            trailColor: NSColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 0.5),
            buttonBackground: NSColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0),
            buttonText: .black
        )

        static let retroTheme = Theme(
            name: "retro",
            backgroundColor: NSColor(red: 0.2, green: 0.1, blue: 0.05, alpha: 1.0),
            playerColor: NSColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0),
            obstacleColor: NSColor(red: 0.6, green: 0.2, blue: 0.1, alpha: 1.0),
            powerUpColor: NSColor(red: 0.9, green: 0.9, blue: 0.7, alpha: 1.0),
            uiTextColor: NSColor(red: 0.9, green: 0.8, blue: 0.5, alpha: 1.0),
            uiBackgroundColor: NSColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 0.9),
            accentColor: NSColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0),
            particleColor: NSColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0),
            trailColor: NSColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 0.3),
            buttonBackground: NSColor(red: 0.8, green: 0.6, blue: 0.2, alpha: 1.0),
            buttonText: NSColor(red: 0.1, green: 0.05, blue: 0.0, alpha: 1.0)
        )

        // MARK: - Properties

        private var config: GameConfiguration {
            GameConfiguration.load()
        }

        var currentTheme: Theme {
            switch config.visual.theme {
            case "light":
                return ThemeManager.lightTheme
            case "dark":
                return ThemeManager.darkTheme
            case "neon":
                return ThemeManager.neonTheme
            case "retro":
                return ThemeManager.retroTheme
            case "auto":
                // Follow system appearance
                if #available(macOS 10.14, *) {
                    let isDark =
                        NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                    return isDark ? ThemeManager.darkTheme : ThemeManager.lightTheme
                } else {
                    return ThemeManager.lightTheme
                }
            default:
                return ThemeManager.lightTheme
            }
        }

        var allThemes: [Theme] {
            [
                ThemeManager.lightTheme, ThemeManager.darkTheme,
                ThemeManager.neonTheme, ThemeManager.retroTheme,
            ]
        }

        // MARK: - Initialization

        private init() {
            setupNotifications()
        }

        private func setupNotifications() {
            if #available(macOS 10.14, *) {
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(systemAppearanceChanged),
                    name: NSApplication.didBecomeActiveNotification,
                    object: nil
                )
            }
        }

        @objc
        private func systemAppearanceChanged() {
            if config.visual.theme == "auto" {
                NotificationCenter.default.post(name: .themeDidChange, object: nil)
            }
        }

        // MARK: - Theme Application

        /// Applies theme to a specific node based on its role
        @MainActor
        func applyTheme(to node: SKNode, role: NodeRole) {
            let theme = currentTheme

            guard let sprite = node as? SKSpriteNode else { return }

            switch role {
            case .player:
                sprite.color = theme.playerColor
            case .obstacle:
                sprite.color = theme.obstacleColor
            case .powerUp:
                sprite.color = theme.powerUpColor
            case .ui:
                sprite.color = theme.uiBackgroundColor
            }
        }

        /// Gets color for a specific role
        func color(for role: NodeRole) -> NSColor {
            let theme = currentTheme

            switch role {
            case .player:
                return theme.playerColor
            case .obstacle:
                return theme.obstacleColor
            case .powerUp:
                return theme.powerUpColor
            case .ui:
                return theme.uiTextColor
            }
        }

        /// Adjusts color for accessibility if needed
        func accessibleColor(for role: NodeRole) -> NSColor {
            var color = self.color(for: role)

            // Increase contrast if needed
            if config.shouldIncreaseContrast {
                color = increaseContrast(of: color)
            }

            return color
        }

        private func increaseContrast(of color: NSColor) -> NSColor {
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0

            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

            // Increase saturation and adjust brightness for better contrast
            saturation = min(saturation * 1.3, 1.0)
            brightness = brightness < 0.5 ? max(brightness - 0.1, 0.0) : min(brightness + 0.1, 1.0)

            return NSColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        }

        // MARK: - Theme Selection

        func setTheme(_ themeName: String) {
            var modifiedConfig = config
            var visual = modifiedConfig.visual
            visual = GameConfiguration.Visual(
                theme: themeName,
                particleQuality: visual.particleQuality,
                frameRateCap: visual.frameRateCap,
                showFPS: visual.showFPS
            )

            let newConfig = GameConfiguration(
                player: modifiedConfig.player,
                obstacle: modifiedConfig.obstacle,
                difficulty: modifiedConfig.difficulty,
                audio: modifiedConfig.audio,
                accessibility: modifiedConfig.accessibility,
                visual: visual
            )

            newConfig.save()

            NotificationCenter.default.post(name: .themeDidChange, object: currentTheme)
        }
    }

    // MARK: - Node Role

    enum NodeRole {
        case player
        case obstacle
        case powerUp
        case ui
    }

    // MARK: - Notification Names

    extension Notification.Name {
        static let themeDidChange = Notification.Name("ThemeDidChange")
    }

#endif

// MARK: - Common Theme Application Extension

// Extracted to avoid 9.3% code duplication between iOS and macOS implementations

extension ThemeManager {
    /// Applies the current theme to a scene
    /// - Parameter scene: The scene to apply the theme to
    /// Works on both iOS and macOS since SKScene is platform-agnostic
    @MainActor
    func applyTheme(to scene: SKScene) {
        let theme = currentTheme

        // Background
        scene.backgroundColor = theme.backgroundColor

        // Find and update player
        if let player = scene.childNode(withName: "//player") as? SKSpriteNode {
            player.color = theme.playerColor
        }

        // Find and update obstacles
        scene.enumerateChildNodes(withName: "//obstacle") { node, _ in
            if let obstacle = node as? SKSpriteNode {
                obstacle.color = theme.obstacleColor
            }
        }

        // Find and update UI labels
        scene.enumerateChildNodes(withName: "//label") { node, _ in
            if let label = node as? SKLabelNode {
                label.fontColor = theme.uiTextColor
            }
        }

        // Notify observers
        NotificationCenter.default.post(name: .themeDidChange, object: theme)
    }
}
