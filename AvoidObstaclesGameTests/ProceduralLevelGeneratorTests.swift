//
// ProceduralLevelGeneratorTests.swift
// AvoidObstaclesGameTests
//

import XCTest

@testable import AvoidObstaclesGame

@MainActor
final class ProceduralLevelGeneratorTests: XCTestCase {
    func testGeneratorInit() {
        let generator = ProceduralLevelGenerator.shared
        XCTAssertNotNil(generator)
    }

    func testSeedConsistency() {
        let generator = ProceduralLevelGenerator.shared
        let seed = 12345

        let level1 = generator.generateLevel(difficulty: 2, seed: seed)
        let level2 = generator.generateLevel(difficulty: 2, seed: seed)

        XCTAssertEqual(
            level1, level2,
            "Generating with the same seed should result in the exact same level data")
    }

    func testDifficultyScaling() {
        let generator = ProceduralLevelGenerator.shared
        let levelEasy = generator.generateLevel(difficulty: 0, seed: 1)
        let levelHard = generator.generateLevel(difficulty: 10, seed: 1)

        XCTAssertGreaterThan(
            levelHard.duration, levelEasy.duration, "Hard levels should have longer duration")
        XCTAssertGreaterThan(
            levelHard.difficulty, levelEasy.difficulty,
            "Hard levels should have higher difficulty multiplier")
    }
}
