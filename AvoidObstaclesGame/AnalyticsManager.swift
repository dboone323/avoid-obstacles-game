//
// AnalyticsManager.swift
// AvoidObstaclesGame
//

import Foundation

class AnalyticsManager {
    static let shared = AnalyticsManager()

    private init() {}

    func trackEvent(_ name: String, parameters: [String: Any]? = nil) {
        #if DEBUG
            GameLogger.shared.debug("📊 Analytics: \(name) - \(parameters ?? [:])")
        #endif

        // In production, integrate with Firebase or similar
        // Analytics.logEvent(name, parameters: parameters)
    }

    func trackGameStart() {
        trackEvent("game_start")
    }

    func trackGameOver(score: Int, survivalTime: TimeInterval) {
        trackEvent("game_over", parameters: [
            "score": score,
            "survival_time": survivalTime
        ])
    }

    func trackAchievement(_ id: String) {
        trackEvent("achievement_unlocked", parameters: ["achievement_id": id])
    }

    func trackPowerUpCollected(_ type: PowerUpType) {
        trackEvent("powerup_collected", parameters: ["type": "\(type)"])
    }

    func trackThemeChanged(_ theme: String) {
        trackEvent("theme_changed", parameters: ["theme": theme])
    }

    func trackTutorialCompleted() {
        trackEvent("tutorial_completed")
    }

    func trackTutorialSkipped() {
        trackEvent("tutorial_skipped")
    }
}
