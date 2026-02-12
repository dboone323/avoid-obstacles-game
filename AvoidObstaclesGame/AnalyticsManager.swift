//
// AnalyticsManager.swift
// AvoidObstaclesGame
//

import Foundation

class AnalyticsManager {
    @MainActor static let shared = AnalyticsManager()

    private init() {}

    @MainActor
    func trackEvent(_ name: String, parameters: [String: Any]? = nil) {
        #if DEBUG
            GameLogger.shared.debug("📊 Analytics: \(name) - \(parameters ?? [:])")
        #endif

        // In production, integrate with Firebase or similar
        // Analytics.logEvent(name, parameters: parameters)
    }

    @MainActor
    func trackGameStart() {
        trackEvent("game_start")
    }

    @MainActor
    func trackGameOver(score: Int, survivalTime: TimeInterval) {
        trackEvent("game_over", parameters: [
            "score": score,
            "survival_time": survivalTime,
        ])
    }

    @MainActor
    func trackAchievement(_ id: String) {
        trackEvent("achievement_unlocked", parameters: ["achievement_id": id])
    }

    @MainActor
    func trackPowerUpCollected(_ type: PowerUpType) {
        trackEvent("powerup_collected", parameters: ["type": "\(type)"])
    }

    @MainActor
    func trackThemeChanged(_ theme: String) {
        trackEvent("theme_changed", parameters: ["theme": theme])
    }

    @MainActor
    func trackTutorialCompleted() {
        trackEvent("tutorial_completed")
    }

    @MainActor
    func trackTutorialSkipped() {
        trackEvent("tutorial_skipped")
    }
}
