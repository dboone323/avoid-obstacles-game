//
// HapticFeedbackManager.swift
// AvoidObstaclesGame
//
// Manages haptic feedback for enhanced tactile experience.
//

import CoreHaptics
import Foundation

#if canImport(UIKit)
    import UIKit

    /// Manages haptic feedback throughout the game
    @available(iOS 10.0, *)
    class HapticFeedbackManager {
        // MARK: - Singleton

        @MainActor static let shared = HapticFeedbackManager()

        // MARK: - Properties

        private let impactLight = UIImpactFeedbackGenerator(style: .light)
        private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
        private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        private let selectionGenerator = UISelectionFeedbackGenerator()
        private let notification = UINotificationFeedbackGenerator()

        /// CHHapticEngine for advanced haptics
        private var hapticEngine: CHHapticEngine?

        private var isEnabled: Bool {
            GameConfiguration.load().audio.hapticsEnabled
        }

        // MARK: - Initialization

        private init() {
            prepare()
            prepareAdvancedHaptics()
        }

        // MARK: - Preparation

        /// Prepares all feedback generators for reduced latency
        func prepare() {
            guard isEnabled else { return }

            impactLight.prepare()
            impactMedium.prepare()
            impactHeavy.prepare()
            selectionGenerator.prepare()
            notification.prepare()
        }

        /// Prepares CHHapticEngine for advanced haptic patterns
        private func prepareAdvancedHaptics() {
            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

            do {
                hapticEngine = try CHHapticEngine()
                try hapticEngine?.start()
            } catch {
                GameLogger.shared.debug("Failed to initialize CHHapticEngine: \(error)")
            }
        }

        // MARK: - Impact Feedback

        /// Light impact (button tap, small collision)
        func light() {
            guard isEnabled else { return }
            impactLight.impactOccurred()
            impactLight.prepare()
        }

        /// Medium impact (obstacle dodge, score increase)
        func medium() {
            guard isEnabled else { return }
            impactMedium.impactOccurred()
            impactMedium.prepare()
        }

        /// Heavy impact (collision, game over)
        func heavy() {
            guard isEnabled else { return }
            impactHeavy.impactOccurred()
            impactHeavy.prepare()
        }

        /// Custom intensity impact (0.0 - 1.0)
        @available(iOS 13.0, *)
        func impact(intensity: CGFloat) {
            guard isEnabled else { return }
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred(intensity: intensity)
        }

        // MARK: - Selection Feedback

        /// Selection change (menu navigation)
        func selection() {
            guard isEnabled else { return }
            self.selectionGenerator.selectionChanged()
            self.selectionGenerator.prepare()
        }

        // MARK: - Notification Feedback

        /// Success notification (new high score, achievement)
        func success() {
            guard isEnabled else { return }
            notification.notificationOccurred(.success)
            notification.prepare()
        }

        /// Warning notification (close call, low health)
        func warning() {
            guard isEnabled else { return }
            notification.notificationOccurred(.warning)
            notification.prepare()
        }

        /// Error notification (collision, game over)
        func error() {
            guard isEnabled else { return }
            notification.notificationOccurred(.error)
            notification.prepare()
        }

        // MARK: - Game-Specific Feedback

        /// Player dodged obstacle successfully
        func obstacleDodged() {
            medium()
        }

        /// Player collected power-up
        func powerUpCollected() {
            success()
        }

        /// Player collided with obstacle (uses advanced CHHapticEngine if available)
        func collision() {
            guard isEnabled else { return }

            // Try advanced haptics first
            if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
                playAdvancedCollisionHaptic()
            } else {
                // Fallback to UIFeedbackGenerator
                heavy()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.medium()
                }
            }
        }

        /// Advanced collision haptic using CHHapticEngine
        private func playAdvancedCollisionHaptic() {
            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

            var events = [CHHapticEvent]()
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            let event = CHHapticEvent(
                eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0
            )
            events.append(event)

            do {
                let pattern = try CHHapticPattern(events: events, parameters: [])
                let player = try hapticEngine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)
            } catch {
                GameLogger.shared.debug("Failed to play advanced collision haptic: \(error)")
                // Fallback to standard heavy impact
                heavy()
            }
        }

        /// Score milestone reached
        func scoreMilestone() {
            success()
        }

        /// Difficulty increased
        func difficultyIncrease() {
            warning()
        }

        /// Game started
        func gameStart() {
            light()
        }

        /// Game paused
        func gamePause() {
            selection()
        }

        /// Game resumed
        func gameResume() {
            selection()
        }

        // MARK: - Pattern Feedback

        /// Play a pattern of haptic feedback
        func playPattern(_ pattern: HapticPattern) {
            guard isEnabled else { return }

            for (index, event) in pattern.events.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + event.delay) { [weak self] in
                    switch event.type {
                    case .light:
                        self?.light()
                    case .medium:
                        self?.medium()
                    case .heavy:
                        self?.heavy()
                    case .selection:
                        self?.selection()
                    case .success:
                        self?.success()
                    case .warning:
                        self?.warning()
                    case .error:
                        self?.error()
                    }

                    // Prepare next event
                    if index < pattern.events.count - 1 {
                        self?.prepare()
                    }
                }
            }
        }
    }

    // MARK: - Haptic Pattern

    /// Represents a pattern of haptic events
    struct HapticPattern {
        struct Event {
            // swiftlint:disable:next nesting
            enum EventType {
                case light, medium, heavy
                case selection
                case success, warning, error
            }

            let type: EventType
            let delay: TimeInterval
        }

        let events: [Event]

        // MARK: - Predefined Patterns

        /// Countdown pattern (3-2-1-GO)
        static let countdown = HapticPattern(events: [
            Event(type: .light, delay: 0.0),
            Event(type: .light, delay: 1.0),
            Event(type: .light, delay: 2.0),
            Event(type: .heavy, delay: 3.0),
        ])

        /// Combo pattern (increasing intensity)
        static let combo = HapticPattern(events: [
            Event(type: .light, delay: 0.0),
            Event(type: .medium, delay: 0.1),
            Event(type: .heavy, delay: 0.2),
        ])

        /// Achievement unlocked
        static let achievement = HapticPattern(events: [
            Event(type: .success, delay: 0.0),
            Event(type: .medium, delay: 0.1),
            Event(type: .medium, delay: 0.2),
        ])
    }

#else

    /// macOS stub - haptics not available
    class HapticFeedbackManager {
        @MainActor static let shared = HapticFeedbackManager()
        private init() {}

        func prepare() {}
        func light() {}
        func medium() {}
        func heavy() {}
        func selection() {}
        func success() {}
        func warning() {}
        func error() {}
        func obstacleDodged() {}
        func powerUpCollected() {}
        func collision() {}
        func scoreMilestone() {}
        func difficultyIncrease() {}
        func gameStart() {}
        func gamePause() {}
        func gameResume() {}
        func playPattern(_ pattern: HapticPattern) {}
    }

    struct HapticPattern {
        struct Event {
            // swiftlint:disable:next nesting
            enum EventType {
                case light, medium, heavy
                case selection
                case success, warning, error
            }

            let type: EventType
            let delay: TimeInterval
        }

        let events: [Event]

        static let countdown = HapticPattern(events: [])
        static let combo = HapticPattern(events: [])
        static let achievement = HapticPattern(events: [])
    }

#endif
