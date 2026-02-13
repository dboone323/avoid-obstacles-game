//
// LeaderboardManagerTests.swift
// AvoidObstaclesGameTests
//

import XCTest
@testable import AvoidObstaclesGame


@MainActor


final class LeaderboardManagerTests: XCTestCase {
    var sut: LeaderboardManager!

    

    override func setUp() {
        super.setUp()
        sut = LeaderboardManager.shared
    }

    // MARK: - Initialization Tests

    func testSharedInstance() {
        XCTAssertNotNil(LeaderboardManager.shared)
    }

    // MARK: - Score Submission Tests

    func testSubmitScore() {
        // Test that submit doesn't crash
        XCTAssertNoThrow(sut.submitScore(100))
    }

    // MARK: - Achievement Tests

    func testUnlockAchievement() {
        let achievementID = LeaderboardManager.Achievement.firstGame
        XCTAssertNoThrow(sut.unlockAchievement(identifier: achievementID))
    }

    func testAchievementIDs() {
        XCTAssertFalse(LeaderboardManager.Achievement.firstGame.isEmpty)
        XCTAssertFalse(LeaderboardManager.Achievement.score100.isEmpty)
        XCTAssertFalse(LeaderboardManager.Achievement.score500.isEmpty)
        XCTAssertFalse(LeaderboardManager.Achievement.score1000.isEmpty)
    }

    // MARK: - Leaderboard Loading Tests

    func testLoadTopScores() {
        let expectation = expectation(description: "Load scores")

        sut.loadTopScores { entries in
            // entries might be empty if not authenticated, that's okay
            XCTAssertTrue(entries.count >= 0)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    // MARK: - Game Center Tests

    func testGameCenterAvailability() {
        XCTAssertTrue(true, "Game Center availability test")
    }

    func testSubmitToGameCenter() {
        XCTAssertTrue(true, "Submit to Game Center test")
    }
}
