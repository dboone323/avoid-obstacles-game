//
//  AchievementManagerTests.swift
//  AvoidObstaclesGameTests
//
//  Comprehensive test suite for AchievementManager
//

import XCTest

@testable import AvoidObstaclesGame

final class AchievementManagerTests: XCTestCase {
    var sut: AchievementManager!

    override func setUp() {
        super.setUp()
        sut = AchievementManager.shared
        sut.resetAllAchievements() // Start with clean state
    }

    override func tearDown() {
        sut.resetAllAchievements()
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testSharedInstance() {
        XCTAssertNotNil(sut)
        XCTAssertTrue(sut === AchievementManager.shared, "Should return same shared instance")
    }

    func testInitialization() {
        XCTAssertNoThrow(AchievementManager.shared)
        XCTAssertGreaterThan(
            sut.getAllAchievements().count, 0, "Should have achievements configured"
        )
    }

    // MARK: - Achievement Query Tests

    func testGetAllAchievements() {
        let allAchievements = sut.getAllAchievements()
        XCTAssertFalse(allAchievements.isEmpty, "Should have at least one achievement")
        XCTAssertGreaterThanOrEqual(
            allAchievements.count, 10, "Should have multiple achievements configured"
        )
    }

    func testGetUnlockedAchievements() {
        let unlockedBefore = sut.getUnlockedAchievements()
        XCTAssertEqual(unlockedBefore.count, 0, "Should start with no unlocked achievements")

        // Unlock an achievement
        sut.updateProgress(for: .scoreReached(score: 100))

        let unlockedAfter = sut.getUnlockedAchievements()
        XCTAssertGreaterThan(unlockedAfter.count, 0, "Should have unlocked achievements")
    }

    func testGetInProgressAchievements() {
        let inProgress = sut.getInProgressAchievements()
        XCTAssertEqual(inProgress.count, 0, "Should start with no in-progress achievements")
    }

    func testGetLockedAchievements() {
        let locked = sut.getLockedAchievements()
        XCTAssertGreaterThan(locked.count, 0, "Should have locked achievements")
    }

    // MARK: - Achievement Unlocking Tests

    func testScoreBasedAchievement() {
        sut.updateProgress(for: .scoreReached(score: 100))
        XCTAssertTrue(
            sut.isAchievementUnlocked("score_100"),
            "Score 100 achievement should unlock at score 100"
        )
    }

    func testMultipleScoreAchievements() {
        sut.updateProgress(for: .scoreReached(score: 1000))
        XCTAssertTrue(sut.isAchievementUnlocked("score_100"))
        XCTAssertTrue(sut.isAchievementUnlocked("score_500"))
        XCTAssertTrue(sut.isAchievementUnlocked("score_1000"))
    }

    func testDifficultyBasedAchievement() {
        sut.updateProgress(for: .difficultyReached(level: 3))
        XCTAssertTrue(sut.isAchievementUnlocked("level_3"))
    }

    func testPowerUpCollectionAchievement() {
        for _ in 0 ..< 10 {
            sut.updateProgress(for: .powerUpCollected)
        }
        XCTAssertTrue(sut.isAchievementUnlocked("power_up_collector"))
    }

    func testShieldMasterAchievement() {
        for _ in 0 ..< 5 {
            sut.updateProgress(for: .shieldUsed)
        }
        XCTAssertTrue(sut.isAchievementUnlocked("shield_master"))
    }

    func testPerfectScoreAchievement() {
        sut.updateProgress(for: .perfectScore(score: 50))
        XCTAssertTrue(sut.isAchievementUnlocked("perfect_start"))
    }

    func testComebackAchievement() {
        sut.updateProgress(for: .comebackScore(score: 200))
        XCTAssertTrue(sut.isAchievementUnlocked("comeback_kid"))
    }

    func testFirstGameAchievement() {
        sut.updateProgress(for: .gameCompleted, value: 1)
        XCTAssertTrue(sut.isAchievementUnlocked("first_game"))
    }

    // MARK: - Achievement Statistics Tests

    func testGetAchievementStatistics() {
        let stats = sut.getAchievementStatistics()

        XCTAssertNotNil(stats["totalAchievements"])
        XCTAssertNotNil(stats["unlockedAchievements"])
        XCTAssertNotNil(stats["completionRate"])
        XCTAssertNotNil(stats["totalPoints"])
        XCTAssertNotNil(stats["recentUnlocks"])
    }

    func testCompletionRateCalculation() {
        sut.updateProgress(for: .scoreReached(score: 100))

        let stats = sut.getAchievementStatistics()
        let completionRate = stats["completionRate"] as? Double

        XCTAssertNotNil(completionRate)
        XCTAssertGreaterThan(completionRate ?? 0, 0.0)
        XCTAssertLessThanOrEqual(completionRate ?? 0, 1.0)
    }

    func testTotalPointsCalculation() {
        XCTAssertEqual(sut.totalPoints, 0, "Should start with 0 points")

        sut.updateProgress(for: .scoreReached(score: 100))
        XCTAssertGreaterThan(sut.totalPoints, 0, "Should have points after unlocking achievement")
    }

    func testGetRecentUnlocks() {
        sut.updateProgress(for: .scoreReached(score: 500))

        let recentUnlocks = sut.getRecentUnlocks(count: 5)
        XCTAssertGreaterThan(recentUnlocks.count, 0)
        XCTAssertLessThanOrEqual(recentUnlocks.count, 5)
    }

    // MARK: - Reset Tests

    func testResetAllAchievements() {
        sut.updateProgress(for: .scoreReached(score: 500))
        XCTAssertGreaterThan(sut.getUnlockedAchievements().count, 0)

        sut.resetAllAchievements()
        XCTAssertEqual(sut.getUnlockedAchievements().count, 0)
        XCTAssertEqual(sut.totalPoints, 0)
    }

    // MARK: - Async Tests

    func testGetAllAchievementsAsync() async {
        let allAchievements = await sut.getAllAchievementsAsync()
        XCTAssertFalse(allAchievements.isEmpty)
    }

    func testGetUnlockedAchievementsAsync() async {
        await sut.updateProgressAsync(for: .scoreReached(score: 100))
        let unlockedAchievements = await sut.getUnlockedAchievementsAsync()
        XCTAssertGreaterThan(unlockedAchievements.count, 0)
    }

    func testIsAchievementUnlockedAsync() async {
        await sut.updateProgressAsync(for: .scoreReached(score: 100))
        let isUnlocked = await sut.isAchievementUnlockedAsync("score_100")
        XCTAssertTrue(isUnlocked)
    }

    func testGetAchievementStatisticsAsync() async {
        let stats = await sut.getAchievementStatisticsAsync()
        XCTAssertNotNil(stats["totalAchievements"])
    }

    func testResetAllAchievementsAsync() async {
        await sut.updateProgressAsync(for: .scoreReached(score: 500))
        await sut.resetAllAchievementsAsync()

        let unlocked = await sut.getUnlockedAchievementsAsync()
        XCTAssertEqual(unlocked.count, 0)
    }

    // MARK: - Edge Case Tests

    func testDoubleUnlockAttempt() {
        sut.updateProgress(for: .scoreReached(score: 100))
        let pointsAfterFirst = sut.totalPoints

        sut.updateProgress(for: .scoreReached(score: 100))
        XCTAssertEqual(
            sut.totalPoints, pointsAfterFirst, "Points should not increase on duplicate unlock"
        )
    }

    func testNegativeScoreHandling() {
        XCTAssertNoThrow(sut.updateProgress(for: .scoreReached(score: -100)))
        XCTAssertEqual(sut.getUnlockedAchievements().count, 0)
    }

    func testZeroScoreHandling() {
        XCTAssertNoThrow(sut.updateProgress(for: .scoreReached(score: 0)))
    }

    func testLargeScoreValue() {
        XCTAssertNoThrow(sut.updateProgress(for: .scoreReached(score: Int.max)))
    }

    // MARK: - Achievement Types Tests

    func testAchievementTypes() {
        let achievements = sut.getAllAchievements()

        let hasScoreBased = achievements.contains { $0.type == .scoreBased }
        let hasTimeBased = achievements.contains { $0.type == .timeBased }
        let hasStreakBased = achievements.contains { $0.type == .streakBased }
        let hasCollectionBased = achievements.contains { $0.type == .collectionBased }
        let hasSpecial = achievements.contains { $0.type == .special }

        XCTAssertTrue(hasScoreBased, "Should have score-based achievements")
        XCTAssertTrue(hasTimeBased, "Should have time-based achievements")
        XCTAssertTrue(hasStreakBased, "Should have streak-based achievements")
        XCTAssertTrue(hasCollectionBased, "Should have collection-based achievements")
        XCTAssertTrue(hasSpecial, "Should have special achievements")
    }

    func testHiddenAchievements() {
        let achievements = sut.getAllAchievements()
        let hiddenAchievements = achievements.filter(\.isHidden)

        XCTAssertGreaterThan(
            hiddenAchievements.count, 0, "Should have at least one hidden achievement"
        )
    }

    // MARK: - Integration Tests

    func testFullGameFlow() {
        // Simulate a game session
        sut.updateProgress(for: .gameCompleted, value: 30) // 30 seconds survived
        sut.updateProgress(for: .scoreReached(score: 500))
        sut.updateProgress(for: .difficultyReached(level: 3))
        sut.updateProgress(for: .powerUpCollected)
        sut.updateProgress(for: .powerUpCollected)

        XCTAssertGreaterThan(sut.getUnlockedAchievements().count, 0)
        XCTAssertGreaterThan(sut.totalPoints, 0)
    }

    func testMultipleSessionProgress() {
        // Session 1
        for _ in 0 ..< 5 {
            sut.updateProgress(for: .powerUpCollected)
        }

        // Session 2
        for _ in 0 ..< 5 {
            sut.updateProgress(for: .powerUpCollected)
        }

        XCTAssertTrue(sut.isAchievementUnlocked("power_up_collector"))
    }
}
