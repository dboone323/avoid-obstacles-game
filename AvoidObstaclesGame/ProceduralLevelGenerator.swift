//
// ProceduralLevelGenerator.swift
// AvoidObstaclesGame
//

import Foundation
import SpriteKit

class ProceduralLevelGenerator {
    @MainActor static let shared = ProceduralLevelGenerator()

    struct Level {
        let duration: TimeInterval
        let obstaclePatterns: [ObstaclePattern]
        let powerUpFrequency: TimeInterval
        let difficulty: Double
    }

    struct ObstaclePattern {
        let type: EnhancedObstacleType
        let count: Int
        let spacing: TimeInterval
    }

    func generateLevel(difficulty: Int, seed: Int? = nil) -> Level {
        let rng = seed ?? Int.random(in: 0 ... 10000)
        srand48(rng)

        let duration: TimeInterval = 60.0 + Double(difficulty) * 30.0
        let difficultyMultiplier = 1.0 + Double(difficulty) * 0.2

        var patterns: [ObstaclePattern] = []
        let patternCount = 3 + difficulty

        for _ in 0 ..< patternCount {
            let type = EnhancedObstacleType.allCases.randomElement()!
            let count = Int.random(in: 1 ... 5)
            let spacing = TimeInterval.random(in: 0.5 ... 2.0) / difficultyMultiplier

            patterns.append(ObstaclePattern(type: type, count: count, spacing: spacing))
        }

        let powerUpFreq = TimeInterval.random(in: 5.0 ... 15.0)

        return Level(
            duration: duration,
            obstaclePatterns: patterns,
            powerUpFrequency: powerUpFreq,
            difficulty: difficultyMultiplier
        )
    }
}
