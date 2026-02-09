//
//  GameStateManagerTests.swift
//  AvoidObstaclesGameTests
//
//  Comprehensive test suite for GameStateManager
//

import XCTest
@testable import AvoidObstaclesGame

final class GameStateManagerTests: XCTestCase {
    var manager: GameStateManager!

    override func setUp() {
        super.setUp()
        manager = GameStateManager()
    }

    override func tearDown() {
        manager.resetStatistics()
        manager = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        XCTAssertNotNil(manager)
        XCTAssertEqual(manager.currentState, .waitingToStart)
        XCTAssertEqual(manager.getCurrentScore(), 0)
    }

    // MARK: - Game Lifecycle Tests

    func testStartGame() {
        manager.startGame()

        XCTAssertEqual(manager.currentState, .playing)
        XCTAssertEqual(manager.getCurrentScore(), 0)
        XCTAssertEqual(manager.getCurrentDifficultyLevel(), 1)
        XCTAssertTrue(manager.isGameActive())
    }

    func testEndGame() {
        manager.startGame()
        manager.addScore(100)
        manager.endGame()

        XCTAssertEqual(manager.currentState, .gameOver)
        XCTAssertTrue(manager.isGameOver())
        XCTAssertGreaterThan(manager.survivalTime, 0)
    }

    func testPauseGame() {
        manager.startGame()
        manager.pauseGame()

        XCTAssertEqual(manager.currentState, .paused)
        XCTAssertTrue(manager.isGamePaused())
    }

    func testResumeGame() {
        manager.startGame()
        manager.pauseGame()
        manager.resumeGame()

        XCTAssertEqual(manager.currentState, .playing)
        XCTAssertTrue(manager.isGameActive())
    }

    // MARK: - Score Management Tests

    func testAddScore() {
        manager.startGame()

        let initialScore = manager.getCurrentScore()
        manager.addScore(50)

        XCTAssertEqual(manager.getCurrentScore(), initialScore + 50)
    }

    func testAddScoreOnlyWhenPlaying() {
        manager.startGame()
        manager.endGame()

        let finalScore = manager.getCurrentScore()
        manager.addScore(100)

        // Score should not change when game is over
        XCTAssertEqual(manager.getCurrentScore(), finalScore)
    }

    // MARK: - Difficulty Management Tests

    func testDifficultyProgression() {
        manager.startGame()

        // Add score to trigger difficulty increase
        manager.addScore(500) // Should increase difficulty

        let difficulty = manager.getCurrentDifficulty()
        XCTAssertGreaterThan(difficulty.scoreMultiplier, 1.0)
    }

    func testGetCurrentDifficulty() {
        manager.startGame()

        let difficulty = manager.getCurrentDifficulty()
        XCTAssertNotNil(difficulty)
        XCTAssertGreaterThan(difficulty.spawnInterval, 0)
    }

    // MARK: - Statistics Tests

    func testGetStatistics() {
        manager.startGame()
        manager.addScore(100)
        manager.endGame()

        let stats = manager.getStatistics()

        XCTAssertNotNil(stats["gamesPlayed"])
        XCTAssertNotNil(stats["totalScore"])
        XCTAssertNotNil(stats["averageScore"])
    }

    func testResetStatistics() {
        manager.startGame()
        manager.addScore(100)
        manager.endGame()

        manager.resetStatistics()

        let stats = manager.getStatistics()
        XCTAssertEqual(stats["gamesPlayed"] as? Int, 0)
        XCTAssertEqual(stats["totalScore"] as? Int, 0)
    }

    // MARK: - State Query Tests

    func testIsGameActive() {
        XCTAssertFalse(manager.isGameActive())

        manager.startGame()
        XCTAssertTrue(manager.isGameActive())

        manager.endGame()
        XCTAssertFalse(manager.isGameActive())
    }

    func testIsGameOver() {
        XCTAssertFalse(manager.isGameOver())

        manager.startGame()
        XCTAssertFalse(manager.isGameOver())

        manager.endGame()
        XCTAssertTrue(manager.isGameOver())
    }
}
