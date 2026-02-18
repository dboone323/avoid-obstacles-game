//
// ProceduralLevelGenerator.swift
// AvoidObstaclesGame
//

import Foundation
import GameplayKit
import SpriteKit

class ProceduralLevelGenerator {
    @MainActor static let shared = ProceduralLevelGenerator()

    struct Level: Equatable {
        let duration: TimeInterval
        let obstaclePatterns: [ObstaclePattern]
        let powerUpFrequency: TimeInterval
        let difficulty: Double
    }

    struct ObstaclePattern: Equatable {
        let type: EnhancedObstacleType
        let count: Int
        let spacing: TimeInterval
    }

    func generateLevel(difficulty: Int, seed: Int? = nil) -> Level {
        let actualSeed = UInt64(seed ?? Int.random(in: 0...1_000_000))
        let randomSource = GKLinearCongruentialRandomSource(seed: actualSeed)

        // Use the seed strictly for all generation parameters
        let duration: TimeInterval = 60.0 + Double(difficulty) * 30.0
        let difficultyMultiplier = 1.0 + Double(difficulty) * 0.2

        var patterns: [ObstaclePattern] = []
        let patternCount = 3 + difficulty

        for _ in 0..<patternCount {
            // Use randomSource for deterministic selections
            let typeIndex = abs(randomSource.nextInt()) % EnhancedObstacleType.allCases.count
            let type = EnhancedObstacleType.allCases[typeIndex]

            let count = (abs(randomSource.nextInt()) % 5) + 1
            let spacingFactor = Double(abs(randomSource.nextInt()) % 150) / 100.0 + 0.5
            let spacing = spacingFactor / difficultyMultiplier

            patterns.append(ObstaclePattern(type: type, count: count, spacing: spacing))
        }

        let powerUpFactor = Double(abs(randomSource.nextInt()) % 1000) / 100.0 + 5.0
        let powerUpFreq = powerUpFactor

        return Level(
            duration: duration,
            obstaclePatterns: patterns,
            powerUpFrequency: powerUpFreq,
            difficulty: difficultyMultiplier
        )
    }
}
