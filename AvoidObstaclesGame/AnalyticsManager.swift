//
// AnalyticsManager.swift
// AvoidObstaclesGame
//

import Foundation

class AnalyticsManager {
    @MainActor static let shared = AnalyticsManager()

    private init() {}

    /// Detailed event structure for structured logging
    struct AnalyticsEvent: Codable {
        let name: String
        let parameters: [String: String]?
        let timestamp: Date
        let platform: String
    }

    @MainActor
    func trackEvent(_ name: String, parameters: [String: Any]? = nil) {
        let stringParameters = parameters?.reduce(into: [String: String]()) { result, kv in
            result[kv.key] = "\(kv.value)"
        }

        let event = AnalyticsEvent(
            name: name,
            parameters: stringParameters,
            timestamp: Date(),
            platform: "macOS" // Hardcoded for current build target logic
        )

        // In production, this would be encoded and sent to a backend or persisted locally.
        if let encoded = try? JSONEncoder().encode(event),
           let jsonString = String(data: encoded, encoding: .utf8)
        {
            NSLog("[AnalyticsManager] EVENT: \(jsonString)")
        } else {
            NSLog("[AnalyticsManager] ERROR: Failed to encode event \(name)")
        }
    }

    @MainActor
    func trackGameStart() {
        trackEvent("game_start")
    }

    @MainActor
    func trackGameOver(score: Int, survivalTime: TimeInterval) {
        trackEvent(
            "game_over",
            parameters: [
                "score": score,
                "survival_time": survivalTime,
            ]
        )
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
