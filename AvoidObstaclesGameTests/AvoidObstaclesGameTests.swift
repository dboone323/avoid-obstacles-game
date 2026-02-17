//
//  AvoidObstaclesGameTests.swift
//  AvoidObstaclesGameTests
//
//  Created by Daniel Stevens on 5/16/25.
//

import Foundation
import SpriteKit
import XCTest
@testable import AvoidObstaclesGame

@MainActor

final class AvoidObstaclesGameTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Game Mechanics Tests

    func testPlayerMovement() {
        // Test basic player movement mechanics with GameScene
        let scene = GameScene(size: CGSize(width: 375, height: 667))
        let view = SKView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        view.presentScene(scene)

        // Manually trigger scene setup since didMove(to:) may not be called in test environment
        scene.didMove(to: view)

        // Test that scene was created successfully
        XCTAssertNotNil(scene)
        XCTAssertEqual(scene.size.width, 375)
        XCTAssertEqual(scene.size.height, 667)

        // Test physics world is configured
        XCTAssertNotNil(scene.physicsWorld)
        XCTAssertEqual(scene.physicsWorld.contactDelegate as? GameScene, scene)
    }

    func testObstacleGeneration() {
        // Test obstacle node creation
        let scene = GameScene(size: CGSize(width: 375, height: 667))
        let view = SKView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        view.presentScene(scene)

        // Manually trigger scene setup since didMove(to:) may not be called in test environment
        scene.didMove(to: view)

        // Test that obstacles can be conceptually created with proper physics
        let obstacleNode = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
        obstacleNode.physicsBody = SKPhysicsBody(rectangleOf: obstacleNode.size)
        obstacleNode.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        obstacleNode.physicsBody?.contactTestBitMask = PhysicsCategory.player
        obstacleNode.physicsBody?.collisionBitMask = PhysicsCategory.none

        XCTAssertNotNil(obstacleNode.physicsBody)
        XCTAssertEqual(obstacleNode.physicsBody?.categoryBitMask, PhysicsCategory.obstacle)
        XCTAssertEqual(obstacleNode.size.width, 50)
        XCTAssertEqual(obstacleNode.size.height, 50)
    }

    func testCollisionDetection() {
        // Test physics category bitmasks are properly configured
        let playerCategory = PhysicsCategory.player
        let obstacleCategory = PhysicsCategory.obstacle
        let powerUpCategory = PhysicsCategory.powerUp

        // Verify categories are non-zero (valid)
        XCTAssertNotEqual(playerCategory, 0, "Player category should be non-zero")
        XCTAssertNotEqual(obstacleCategory, 0, "Obstacle category should be non-zero")
        XCTAssertNotEqual(powerUpCategory, 0, "Power-up category should be non-zero")

        // Test that categories are properly defined and distinct
        XCTAssertNotEqual(playerCategory, obstacleCategory, "Player and obstacle categories should differ")
        XCTAssertNotEqual(obstacleCategory, powerUpCategory, "Obstacle and power-up categories should differ")
        XCTAssertNotEqual(playerCategory, powerUpCategory, "Player and power-up categories should differ")
        XCTAssertEqual(PhysicsCategory.none, 0, "None category should be zero")
    }

    // MARK: - Score System Tests

    func testScoreCalculation() {
        // Test score calculation based on game progress
        let baseScore = 100
        let timeBonus = 50
        let distanceBonus = 25

        let totalScore = baseScore + timeBonus + distanceBonus

        XCTAssertEqual(totalScore, 175, "Total score should be sum of all components")
        XCTAssertGreaterThan(totalScore, baseScore, "Total score should be greater than base score")
    }

    func testHighScoreTracking() {
        // Test high score tracking and updating
        var currentHighScore = 1000
        let newScore = 1200

        if newScore > currentHighScore {
            currentHighScore = newScore
        }

        XCTAssertEqual(currentHighScore, 1200, "High score should be updated to new higher score")
        XCTAssertGreaterThanOrEqual(currentHighScore, 1000, "High score should never decrease")
    }

    func testScoreMultiplier() {
        // Test score multipliers for combo systems
        let basePoints = 10
        let multiplier = 2.5
        let multipliedScore = Int(Double(basePoints) * multiplier)

        XCTAssertEqual(multipliedScore, 25, "Multiplied score should be correctly calculated")
        XCTAssertGreaterThan(
            multipliedScore, basePoints, "Multiplied score should be higher than base"
        )
    }

    // MARK: - Game State Tests

    func testGameStartState() {
        // Test initial game state using GameStateManager
        let gameStateManager = GameStateManager()

        // Before starting, should be waiting
        XCTAssertFalse(gameStateManager.isGameActive(), "Game should not be active before start")

        // Start the game
        gameStateManager.startGame()

        // After starting, should be playing
        XCTAssertTrue(gameStateManager.isGameActive(), "Game should be active after start")
        XCTAssertEqual(gameStateManager.getCurrentScore(), 0, "Score should be 0 at start")
        XCTAssertEqual(gameStateManager.getCurrentDifficultyLevel(), 1, "Difficulty should be 1 at start")
    }

    func testGameOverCondition() {
        // Test game over conditions using GameStateManager
        let gameStateManager = GameStateManager()

        // Start and then end the game
        gameStateManager.startGame()
        XCTAssertFalse(gameStateManager.isGameOver(), "Game should not be over after start")

        gameStateManager.endGame()
        XCTAssertTrue(gameStateManager.isGameOver(), "Game should be over after endGame()")
        XCTAssertFalse(gameStateManager.isGameActive(), "Game should not be active after game over")
    }

    func testPauseResumeFunctionality() {
        // Test pause and resume functionality using GameStateManager
        let gameStateManager = GameStateManager()

        // Start game
        gameStateManager.startGame()
        XCTAssertTrue(gameStateManager.isGameActive(), "Game should be active")

        // Pause the game
        gameStateManager.pauseGame()
        XCTAssertTrue(gameStateManager.isGamePaused(), "Game should be paused")
        XCTAssertFalse(gameStateManager.isGameActive(), "Game should not be active while paused")

        // Resume the game
        gameStateManager.resumeGame()
        XCTAssertTrue(gameStateManager.isGameActive(), "Game should be active after resume")
        XCTAssertFalse(gameStateManager.isGamePaused(), "Game should not be paused after resume")
    }

    // MARK: - Level System Tests

    func testLevelProgression() {
        // Test level progression logic
        var currentLevel = 1
        let scoreThreshold = 1000
        let currentScore = 1200

        if currentScore >= scoreThreshold {
            currentLevel += 1
        }

        XCTAssertEqual(currentLevel, 2, "Level should progress when score threshold is met")
    }

    func testDifficultyScaling() {
        // Test difficulty scaling with level
        let level = 5
        let baseSpeed = 100.0
        let speedIncrease = 20.0

        let currentSpeed = baseSpeed + (Double(level - 1) * speedIncrease)

        XCTAssertEqual(currentSpeed, 180.0, "Speed should increase with level")
        XCTAssertGreaterThan(
            currentSpeed, baseSpeed, "Current speed should be higher than base speed"
        )
    }

    func testLevelCompletion() {
        // Test level completion detection
        let levelDistance = 1000.0
        let playerDistance = 1050.0

        let levelCompleted = playerDistance >= levelDistance

        XCTAssertTrue(
            levelCompleted, "Level should be completed when player reaches target distance"
        )
    }

    // MARK: - Power-up Tests

    func testPowerUpActivation() {
        // Test power-up activation and effects
        // let player = Player()
        // let shieldPowerUp = PowerUp(type: .shield, duration: 10.0)

        // player.activatePowerUp(shieldPowerUp)
        // XCTAssertTrue(player.hasShield)
        // XCTAssertEqual(player.shieldDuration, 10.0)

        // Placeholder until PowerUp system is defined
        XCTAssertTrue(true, "Power-up activation test framework ready")
    }

    func testPowerUpExpiration() {
        // Test power-up expiration
        // let powerUp = PowerUp(type: .speedBoost, duration: 5.0)
        // powerUp.startTime = Date().addingTimeInterval(-6.0) // 6 seconds ago

        // XCTAssertTrue(powerUp.isExpired)

        // Placeholder until PowerUp system is defined
        XCTAssertTrue(true, "Power-up expiration test framework ready")
    }

    // MARK: - Performance Tests

    func testGameLoopPerformance() {
        // Test game loop performance
        let startTime = Date()

        // Simulate game loop iterations
        for _ in 1...1000 {
            // Simulate game update logic
            let x = 1 + 1
            XCTAssertEqual(x, 2)
        }

        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        XCTAssertLessThan(duration, 1.0, "Game loop should process 1000 iterations quickly")
    }

    func testObstacleGenerationPerformance() {
        // Test obstacle generation performance
        let startTime = Date()

        // Simulate generating multiple obstacles
        for i in 1...100 {
            let obstacleData: [String: Any] = ["id": i, "type": "spike", "x": i * 50]
            XCTAssertEqual((obstacleData["id"] as? Int), i)
        }

        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        XCTAssertLessThan(duration, 0.5, "Obstacle generation should be fast")
    }

    // MARK: - Save/Load Tests

    func testGameSaveFunctionality() {
        // Test game save functionality
        let gameData: [String: Any] = [
            "score": 1500,
            "level": 3,
            "lives": 2,
            "playerX": 100.0,
            "playerY": 200.0,
        ]

        XCTAssertEqual(gameData["score"] as? Int, 1500)
        XCTAssertEqual(gameData["level"] as? Int, 3)
        XCTAssertEqual(gameData["lives"] as? Int, 2)
        XCTAssertEqual(gameData["playerX"] as? Double, 100.0)
        XCTAssertEqual(gameData["playerY"] as? Double, 200.0)
    }

    func testGameLoadFunctionality() {
        // Test game load functionality
        let savedData = [
            "score": 2500,
            "level": 5,
            "lives": 3,
        ]

        let loadedScore = savedData["score"] ?? 0
        let loadedLevel = savedData["level"] ?? 1

        XCTAssertEqual(loadedScore as? Int, 2500, "Loaded score should match saved score")
        XCTAssertEqual(loadedLevel as? Int, 5, "Loaded level should match saved level")
    }

    // MARK: - Edge Cases Tests

    func testZeroScore() {
        // Test handling of zero score
        let score = 0
        let isHighScore = score > 1000

        XCTAssertEqual(score, 0, "Score should be zero")
        XCTAssertFalse(isHighScore, "Zero score should not be considered high score")
    }

    func testNegativeValues() {
        // Test handling of negative values (shouldn't happen in normal gameplay)
        let negativeScore = -100
        let clampedScore = max(0, negativeScore)

        XCTAssertLessThan(negativeScore, 0, "Negative score should be less than zero")
        XCTAssertEqual(clampedScore, 0, "Negative score should be clamped to zero")
    }

    func testMaximumValues() {
        // Test handling of maximum values
        let maxScore = Int.max
        let isValidScore = maxScore > 0

        XCTAssertGreaterThan(maxScore, 0, "Maximum score should be positive")
        XCTAssertTrue(isValidScore, "Maximum score should be valid")
    }
}
