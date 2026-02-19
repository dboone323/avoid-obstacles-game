import Foundation
import OSLog
import SharedKit
import os

/// Configuration for game balancing adjustments.
public struct BalanceConfiguration: Sendable {
    public static let difficultyIncreaseMultiplier = 1.1
    public static let difficultyDecreaseMultiplier = 0.9
    public static let maxDifficultyMultiplier = 1.5
    public static let minDifficultyMultiplier = 0.7

    public static let obstacleSpeedIncrease = 1.2
    public static let spawnRateDecrease = 0.8
    public static let obstacleSpeedDecrease = 0.9
    public static let spawnRateIncrease = 1.5
}

/// Agent specializing in real-time game balancing based on player performace.
public final class GameBalanceAgent: BaseAgent {
    public let id = "game_balance_agent_001"
    public let name = "Dynamic Game Balancer"
    private static let logger = Logger(
        subsystem: "com.avoid-obstacles.game", category: "GameBalance")

    public init() {}

    @MainActor
    public func execute(context: [String: Sendable]) async throws -> AgentResult {
        // 1. Extract performance metrics
        let score = context["score"] as? Int ?? 0
        let lives = context["lives"] as? Int ?? 3
        let survivalTime = context["survivalTime"] as? TimeInterval ?? 0.0

        Self.logger.info(
            "[\(self.name)] Analyzing player performance (Score: \(score), Survival: \(survivalTime)s)..."
        )

        // 2. Determine balance adjustments
        var adjustments: [String: String] = [:]

        if survivalTime > 60 && lives == 3 {
            adjustments["difficulty"] = "increase"
            adjustments["obstacleSpeed"] = "\(BalanceConfiguration.obstacleSpeedIncrease)x"
            adjustments["spawnRate"] = "\(BalanceConfiguration.spawnRateDecrease)x"
        } else if survivalTime < 20 && lives < 2 {
            adjustments["difficulty"] = "decrease"
            adjustments["obstacleSpeed"] = "\(BalanceConfiguration.obstacleSpeedDecrease)x"
            adjustments["spawnRate"] = "\(BalanceConfiguration.spawnRateIncrease)x"
        } else {
            adjustments["difficulty"] = "stable"
        }

        let summary =
            "Difficulty set to \(adjustments["difficulty"] ?? "stable") based on performance metrics."

        return AgentResult(
            agentId: id,
            success: true,
            summary: summary,
            detail: adjustments,
            requiresApproval: false
        )
    }
}
