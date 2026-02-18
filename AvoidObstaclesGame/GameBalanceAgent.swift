import Foundation
import SharedKit

/// Agent specializing in real-time game balancing based on player performace.
public final class GameBalanceAgent: BaseAgent {
    public let id = "game_balance_agent_001"
    public let name = "Dynamic Game Balancer"

    public init() {}

    @MainActor
    public func execute(context: [String: Sendable]) async throws -> AgentResult {
        // 1. Extract performance metrics
        let score = context["score"] as? Int ?? 0
        let lives = context["lives"] as? Int ?? 3
        let survivalTime = context["survivalTime"] as? TimeInterval ?? 0.0

        print(
            "[\(name)] Analyzing player performance (Score: \(score), Survival: \(survivalTime)s)..."
        )

        // 2. Determine balance adjustments
        var adjustments: [String: String] = [:]

        if survivalTime > 60 && lives == 3 {
            adjustments["difficulty"] = "increase"
            adjustments["obstacleSpeed"] = "1.2x"
            adjustments["spawnRate"] = "0.8x"
        } else if survivalTime < 20 && lives < 2 {
            adjustments["difficulty"] = "decrease"
            adjustments["obstacleSpeed"] = "0.9x"
            adjustments["spawnRate"] = "1.5x"
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
