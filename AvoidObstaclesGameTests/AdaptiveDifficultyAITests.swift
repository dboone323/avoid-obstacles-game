//
// AdaptiveDifficultyAITests.swift
// AvoidObstaclesGameTests
//

@testable import AvoidObstaclesGame
import XCTest

final class AdaptiveDifficultyAITests: XCTestCase {
    var ai: AdaptiveDifficultyAI!

    override func setUp() {
        super.setUp()
        ai = AdaptiveDifficultyAI() // Use new instance if possible, but it's a singleton 'shared'.
        // If shared, state might persist.
        // The class definition: `static let shared = AdaptiveDifficultyAI()`.
        // And `private var playerPerformance`.
        // We cannot easily reset the singleton without a reset method or creating a new instance if init is accessible.
        // The class has implicit internal init? `class AdaptiveDifficultyAI { ... }` (no private init).
        // Yes, internal init.
        ai = AdaptiveDifficultyAI()
    }

    override func tearDown() {
        ai = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertEqual(ai.getDifficultyMultiplier(), 1.0)
    }

    func testRecordPerformance_StoresData() {
        // We can't inspect private property 'playerPerformance' directly.
        // But we can check if multiplier updates after 3 games.

        ai.recordPerformance(score: 10, survivalTime: 10, collisions: 1)
        // Multiplier shouldn't change yet (< 3 games)
        XCTAssertEqual(ai.getDifficultyMultiplier(), 1.0)
    }

    func testDifficultyIncrease_HighPerformance() {
        // Record 3 high performance games
        // Avg Survival > 60, Avg Score > 100

        for _ in 0 ..< 3 {
            ai.recordPerformance(score: 150, survivalTime: 70, collisions: 0)
        }

        // Multiplier should increase: min(1.0 * 1.1, 1.5) = 1.1
        XCTAssertGreaterThan(ai.getDifficultyMultiplier(), 1.0)
        XCTAssertEqual(ai.getDifficultyMultiplier(), 1.1, accuracy: 0.001)
    }

    func testDifficultyDecrease_LowPerformance() {
        // Record 3 low performance games
        // Avg Survival < 20

        for _ in 0 ..< 3 {
            ai.recordPerformance(score: 10, survivalTime: 10, collisions: 5)
        }

        // Multiplier should decrease: max(1.0 * 0.9, 0.7) = 0.9
        XCTAssertLessThan(ai.getDifficultyMultiplier(), 1.0)
        XCTAssertEqual(ai.getDifficultyMultiplier(), 0.9, accuracy: 0.001)
    }

    func testDifficultyLimits() {
        // Increase loop
        for _ in 0 ..< 10 {
            ai.recordPerformance(score: 200, survivalTime: 100, collisions: 0)
        }
        // Should cap at 1.5
        XCTAssertLessThanOrEqual(ai.getDifficultyMultiplier(), 1.5)

        // Reset
        ai = AdaptiveDifficultyAI()

        // Decrease loop
        for _ in 0 ..< 10 {
            ai.recordPerformance(score: 0, survivalTime: 5, collisions: 5)
        }
        // Should cap at 0.7
        XCTAssertGreaterThanOrEqual(ai.getDifficultyMultiplier(), 0.7)
    }

    func testGetAdjustedDifficulty() {
        // Set up high difficulty
        for _ in 0 ..< 3 {
            ai.recordPerformance(score: 150, survivalTime: 70, collisions: 0)
        }
        let multiplier = 1.1

        let base = GameConfiguration.Difficulty.DifficultyLevel(
            scoreThreshold: 100,
            spawnInterval: 2.0,
            obstacleSpeed: 100.0,
            scoreMultiplier: 1.0,
            obstacleCount: 1
        )

        let adjusted = ai.getAdjustedDifficulty(base: base)

        // Check logic:
        // spawnInterval = base / multiplier (2.0 / 1.1 = 1.81)
        // obstacleSpeed = base * multiplier (100 * 1.1 = 110)

        XCTAssertEqual(adjusted.spawnInterval, base.spawnInterval / multiplier, accuracy: 0.01)
        XCTAssertEqual(adjusted.obstacleSpeed, base.obstacleSpeed * multiplier, accuracy: 0.01)
    }
}
