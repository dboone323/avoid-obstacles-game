//
// AccessibilityManager.swift
// AvoidObstaclesGame
//
// Manages accessibility features for inclusive gameplay.
//

import Foundation
import SpriteKit

#if canImport(UIKit)
    import UIKit

    /// Manages accessibility features
    class AccessibilityManager {
        // MARK: - Singleton

        @MainActor static let shared = AccessibilityManager()

        // MARK: - Properties

        private var config: GameConfiguration {
            GameConfiguration.load()
        }

        var isVoiceOverEnabled: Bool {
            UIAccessibility.isVoiceOverRunning
        }

        var shouldReduceMotion: Bool {
            config.shouldReduceMotion
        }

        var shouldIncreaseContrast: Bool {
            config.shouldIncreaseContrast
        }

        var shouldUseLargerTouchTargets: Bool {
            config.accessibility.largerTouchTargets
        }

        // MARK: - Initialization

        private init() {
            setupAccessibilityNotifications()
        }

        // MARK: - Setup

        private func setupAccessibilityNotifications() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(voiceOverStatusChanged),
                name: UIAccessibility.voiceOverStatusDidChangeNotification,
                object: nil
            )

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(reduceMotionChanged),
                name: UIAccessibility.reduceMotionStatusDidChangeNotification,
                object: nil
            )
        }

        @objc
        private func voiceOverStatusChanged() {
            NotificationCenter.default.post(name: .accessibilityStatusChanged, object: nil)
        }

        @objc
        private func reduceMotionChanged() {
            NotificationCenter.default.post(name: .accessibilityStatusChanged, object: nil)
        }

        // MARK: - Node Configuration

        /// Configures accessibility for a player node
        func configurePlayer(_ node: SKNode) {
            node.isAccessibilityElement = true
            node.accessibilityLabel = LocalizationManager.shared.string(
                for: .accessibilityPlayerLabel)
            node.accessibilityTraits = .startsMediaSession
            node.accessibilityHint = "Your ship. Move to avoid obstacles."
        }

        /// Configures accessibility for an obstacle node
        func configureObstacle(_ node: SKNode, index: Int) {
            node.isAccessibilityElement = true
            node.accessibilityLabel =
                "\(LocalizationManager.shared.string(for: .accessibilityObstacleLabel)) \(index)"
            node.accessibilityTraits = .none
            node.accessibilityHint = "Obstacle to avoid"
        }

        /// Configures accessibility for a power-up node
        func configurePowerUp(_ node: SKNode, type: PowerUpType) {
            node.isAccessibilityElement = true
            node.accessibilityLabel =
                "\(type.name) \(LocalizationManager.shared.string(for: .accessibilityPowerUpLabel))"
            node.accessibilityTraits = .button
            node.accessibilityHint = "Tap to collect \(type.name)"
        }

        /// Configures accessibility for score label
        func configureScoreLabel(_ node: SKLabelNode, score: Int) {
            node.isAccessibilityElement = true
            node.accessibilityLabel = String(
                format: LocalizationManager.shared.string(for: .accessibilityScoreLabel),
                score
            )
            node.accessibilityTraits = .updatesFrequently
        }

        // MARK: - Touch Target Enhancement

        /// Gets the enhanced touch target size if enabled
        func getTouchTargetSize(for baseSize: CGSize) -> CGSize {
            guard shouldUseLargerTouchTargets else { return baseSize }

            // Apple HIG recommends minimum 44x44 points
            let minSize: CGFloat = 44.0
            return CGSize(
                width: max(baseSize.width * 1.5, minSize),
                height: max(baseSize.height * 1.5, minSize)
            )
        }

        // MARK: - Color Adjustments

        /// Adjusts color for colorblind mode
        func adjustColor(_ color: UIColor, for mode: String) -> UIColor {
            guard mode != "none" else { return color }

            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0

            color.getHue(
                &hue, saturation: &saturation,
                brightness: &brightness, alpha: &alpha
            )

            switch mode {
            case "protanopia": // Red-blind
                // Shift reds toward blues
                if hue < 0.1 || hue > 0.9 {
                    hue = 0.6 // Blue
                }

            case "deuteranopia": // Green-blind
                // Enhance blues and yellows
                if hue > 0.2 && hue < 0.4 {
                    hue = 0.55 // Cyan
                }

            case "tritanopia": // Blue-blind
                // Shift blues toward greens
                if hue > 0.5 && hue < 0.7 {
                    hue = 0.3 // Green
                }

            default:
                break
            }

            return UIColor(
                hue: hue, saturation: saturation,
                brightness: brightness, alpha: alpha
            )
        }

        // MARK: - Announcements

        /// Announces message to VoiceOver
        func announce(_ message: String, priority: UIAccessibility.Notification = .announcement) {
            guard isVoiceOverEnabled else { return }
            UIAccessibility.post(notification: priority, argument: message)
        }

        /// Announces score change
        func announceScore(_ score: Int) {
            let message = String(
                format: LocalizationManager.shared.string(for: .accessibilityScoreLabel), score
            )
            announce(message)
        }

        /// Announces game over
        func announceGameOver(finalScore: Int) {
            let message =
                "\(LocalizationManager.shared.string(for: .gameOver)). Final score: \(finalScore)"
            announce(message, priority: .announcement)
        }

        /// Announces new high score
        func announceNewHighScore(_ score: Int) {
            let message =
                "\(LocalizationManager.shared.string(for: .gameNewHighScore)) \(score) points!"
            announce(message, priority: .announcement)
        }
    }

    // MARK: - PowerUpType Extension

    extension PowerUpType {
        var name: String {
            switch self {
            case .shield: "Shield"
            case .speedBoost: "Speed Boost"
            case .magnet: "Magnet"
            case .slowTime: "Slow Time"
            case .doublePoints: "Double Points"
            }
        }
    }

    // MARK: - Notification Names

    extension Notification.Name {
        static let accessibilityStatusChanged = Notification.Name("AccessibilityStatusChanged")
    }

#endif
