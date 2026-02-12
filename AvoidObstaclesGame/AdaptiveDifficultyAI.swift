//
// AdaptiveDifficultyAI.swift
// AvoidObstaclesGame
//

import Foundation

class AdaptiveDifficultyAI {
    @MainActor static let shared = AdaptiveDifficultyAI()

    private var playerPerformance: [PerformanceData] = []
    private var currentMultiplier: Double = 1.0

    struct PerformanceData {
        let score: Int
        let survivalTime: TimeInterval
        let collisions: Int
        let timestamp: Date
    }

    func recordPerformance(score: Int, survivalTime: TimeInterval, collisions: Int) {
        let data = PerformanceData(
            score: score,
            survivalTime: survivalTime,
            collisions: collisions,
            timestamp: Date()
        )
        playerPerformance.append(data)

        if playerPerformance.count > 10 {
            playerPerformance.removeFirst()
        }

        updateDifficultyMultiplier()
    }

    func getDifficultyMultiplier() -> Double {
        currentMultiplier
    }

    private func updateDifficultyMultiplier() {
        guard playerPerformance.count >= 3 else { return }

        let recentGames = playerPerformance.suffix(3)
        let avgSurvival = recentGames.map(\.survivalTime).reduce(0, +) / 3.0
        let avgScore = recentGames.map(\.score).reduce(0, +) / 3

        // Adjust based on performance
        if avgSurvival > 60 && avgScore > 100 {
            currentMultiplier = min(currentMultiplier * 1.1, 1.5) // Increase difficulty
        } else if avgSurvival < 20 {
            currentMultiplier = max(currentMultiplier * 0.9, 0.7) // Decrease difficulty
        }
    }

    func getAdjustedDifficulty(base: GameConfiguration.Difficulty.DifficultyLevel) -> GameConfiguration.Difficulty
        .DifficultyLevel
    {
        GameConfiguration.Difficulty.DifficultyLevel(
            scoreThreshold: base.scoreThreshold,
            spawnInterval: base.spawnInterval / currentMultiplier,
            obstacleSpeed: base.obstacleSpeed * currentMultiplier,
            scoreMultiplier: base.scoreMultiplier * currentMultiplier,
            obstacleCount: base.obstacleCount
        )
    }
}
