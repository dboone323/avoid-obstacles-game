@testable import AvoidObstaclesGameCore
import SharedKit
import XCTest

class GameBalanceAgentTests: XCTestCase {
    func testExecute_HighScoreAndFullLives() async throws {
        let agent = GameBalanceAgent()
        let context: [String: any Sendable] = [
            "score": 1000,
            "lives": 3,
            "survivalTime": 65.0,
        ]

        let result = try await agent.execute(context: context)

        XCTAssertEqual(result.success, true)
        XCTAssertEqual(result.detail["difficulty"], "increase")
        XCTAssertEqual(result.detail["obstacleSpeed"], "\(BalanceConfiguration.obstacleSpeedIncrease)x")
        XCTAssertEqual(result.detail["spawnRate"], "\(BalanceConfiguration.spawnRateDecrease)x")

        // Performance monitoring
        logPerformanceMetric("HighScoreAndFullLives", result: result)
    }

    func testExecute_LowScoreAndFewLives() async throws {
        let agent = GameBalanceAgent()
        let context: [String: any Sendable] = [
            "score": 50,
            "lives": 1,
            "survivalTime": 15.0,
        ]

        let result = try await agent.execute(context: context)

        XCTAssertEqual(result.success, true)
        XCTAssertEqual(result.detail["difficulty"], "decrease")
        XCTAssertEqual(result.detail["obstacleSpeed"], "\(BalanceConfiguration.obstacleSpeedDecrease)x")
        XCTAssertEqual(result.detail["spawnRate"], "\(BalanceConfiguration.spawnRateIncrease)x")

        // Performance monitoring
        logPerformanceMetric("LowScoreAndFewLives", result: result)
    }

    func testExecute_StableConditions() async throws {
        let agent = GameBalanceAgent()
        let context: [String: any Sendable] = [
            "score": 700,
            "lives": 2,
            "survivalTime": 35.0,
        ]

        let result = try await agent.execute(context: context)

        XCTAssertEqual(result.success, true)
        XCTAssertEqual(result.detail["difficulty"], "stable")

        // Performance monitoring
        logPerformanceMetric("StableConditions", result: result)
    }

    func testExecute_ExtremelyHighScoreAndFullLives() async throws {
        let agent = GameBalanceAgent()
        let context: [String: any Sendable] = [
            "score": Int.max,
            "lives": 3,
            "survivalTime": 65.0,
        ]

        let result = try await agent.execute(context: context)

        XCTAssertEqual(result.success, true)
        XCTAssertEqual(result.detail["difficulty"], "increase")

        // Performance monitoring
        logPerformanceMetric("ExtremelyHighScoreAndFullLives", result: result)
    }

    private func logPerformanceMetric(_ scenario: String, result: AgentResult) {
        print(
            "Scenario: \(scenario), Difficulty: \(result.detail["difficulty"] ?? "unknown"), Obstacle Speed: \(result.detail["obstacleSpeed"] ?? "unknown"), Spawn Rate: \(result.detail["spawnRate"] ?? "unknown")"
        )
    }
}
