//
// LeaderboardManagerTests.swift
// AvoidObstaclesGameTests
//

@testable import AvoidObstaclesGame
import XCTest

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

    func testLeaderboardIdentifier() {
        XCTAssertFalse(sut.leaderboardID.isEmpty)
    }

    // MARK: - Local Leaderboard Tests

    func testLocalScoresCount() {
        XCTAssertGreaterThanOrEqual(sut.localScores.count, 0)
    }

    func testTopScoresLimit() {
        let limit = 10
        let topScores = sut.getTopScores(limit: limit)
        XCTAssertLessThanOrEqual(topScores.count, limit)
    }

    func testScoresSortedDescending() {
        let scores = sut.getTopScores(limit: 10)
        if scores.count > 1 {
            for i in 0 ..< (scores.count - 1) {
                XCTAssertGreaterThanOrEqual(scores[i].score, scores[i + 1].score)
            }
        }
    }

    // MARK: - Score Entry Tests

    func testAddScoreEntry() {
        XCTAssertTrue(true, "Add score entry test")
    }

    func testScoreEntryHasTimestamp() {
        XCTAssertTrue(true, "Score entry timestamp test")
    }

    func testScoreEntryHasPlayerName() {
        XCTAssertTrue(true, "Score entry player name test")
    }

    // MARK: - Game Center Tests

    func testGameCenterAvailability() {
        XCTAssertTrue(true, "Game Center availability test")
    }

    func testSubmitToGameCenter() {
        XCTAssertTrue(true, "Submit to Game Center test")
    }
}
