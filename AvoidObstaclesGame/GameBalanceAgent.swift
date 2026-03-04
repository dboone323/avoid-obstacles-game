import XCTest

@testable import AvoidObstaclesGame

class GameBalanceAgentTests: XCTestCase {
    
    func testExecute_HighScoreAndFullLives() async throws {
        let agent = GameBalanceAgent()
        let context: [String: Sendable] = [
            "score": 1000,
            "lives": 3,
            "survivalTime": 65.0
        ]
        
        let result = try await agent.execute(context: context)
        
        XCTAssertEqual(result.success, true)
        XCTAssertEqual(result.detail["difficulty"] as? String, "increase")
        XCTAssertEqual(result.detail["obstacleSpeed"] as? String, "\(BalanceConfiguration.obstacleSpeedIncrease)x")
        XCTAssertEqual(result.detail["spawnRate"] as? String, "\(BalanceConfiguration.spawnRateDecrease)x")
        
        // Performance monitoring
        logPerformanceMetric("HighScoreAndFullLives", result: result)
    }
    
    func testExecute_LowScoreAndFewLives() async throws {
        let agent = GameBalanceAgent()
        let context: [String: Sendable] = [
            "score": 50,
            "lives": 1,
            "survivalTime": 15.0
        ]
        
        let result = try await agent.execute(context: context)
        
        XCTAssertEqual(result.success, true)
        XCTAssertEqual(result.detail["difficulty"] as? String, "decrease")
        XCTAssertEqual(result.detail["obstacleSpeed"] as? String, "\(BalanceConfiguration.obstacleSpeedDecrease)x")
        XCTAssertEqual(result.detail["spawnRate"] as? String, "\(BalanceConfiguration.spawnRateIncrease)x")
        
        // Performance monitoring
        logPerformanceMetric("LowScoreAndFewLives", result: result)
    }
    
    func testExecute_StableConditions() async throws {
        let agent = GameBalanceAgent()
        let context: [String: Sendable] = [
            "score": 700,
            "lives": 2,
            "survivalTime": 35.0
        ]
        
        let result = try await agent.execute(context: context)
        
        XCTAssertEqual(result.success, true)
        XCTAssertEqual(result.detail["difficulty"] as? String, "stable")
        
        // Performance monitoring
        logPerformanceMetric("StableConditions", result: result)
    }
    
    func testExecute_ExtremelyHighScoreAndFullLives() async throws {
        let agent = GameBalanceAgent()
        let context: [String: Sendable] = [
            "score": Int.max,
            "lives": 3,
            "survivalTime": 65.0
        ]
        
        let result = try await agent.execute(context: context)
        
        XCTAssertEqual(result.success, true)
        XCTAssertEqual(result.detail["difficulty"] as? String, "increase")
        XCTAssertEqual(result.detail["obstacleSpeed"] as? String, "\(BalanceConfiguration.obstacleSpeedIncrease)x")
        XCTAssertEqual(result.detail["spawnRate"] as? String, "\(BalanceConfiguration.spawnRateDecrease)x")
        
        // Performance monitoring
        logPerformanceMetric("ExtremelyHighScoreAndFullLives", result: result)
    }
    
    func testExecute_ExtremelyLowScoreAndFewLives() async throws {
        let agent = GameBalanceAgent()
        let context: [String: Sendable] = [
            "score": 0,
            "lives": 1,
            "survivalTime": 15.0
        ]
        
        let result = try await agent.execute(context: context)
        
        XCTAssertEqual(result.success, true)
        XCTAssertEqual(result.detail["difficulty"] as? String, "decrease")
        XCTAssertEqual(result.detail["obstacleSpeed"] as? String, "\(BalanceConfiguration.obstacleSpeedDecrease)x")
        XCTAssertEqual(result.detail["spawnRate"] as? String, "\(BalanceConfiguration.spawnRateIncrease)x")
        
        // Performance monitoring
        logPerformanceMetric("ExtremelyLowScoreAndFewLives", result: result)
    }
    
    func testExecute_ExtremelyHighSurvivalTime() async throws {
        let agent = GameBalanceAgent()
        let context: [String: Sendable] = [
            "score": 700,
            "lives": 2,
            "survivalTime": Double.greatestFiniteMagnitude
        ]
        
        let result = try await agent.execute(context: context)
        
        XCTAssertEqual(result.success, true)
        XCTAssertEqual(result.detail["difficulty"] as? String, "increase")
        XCTAssertEqual(result.detail["obstacleSpeed"] as? String, "\(BalanceConfiguration.obstacleSpeedIncrease)x")
        XCTAssertEqual(result.detail["spawnRate"] as? String, "\(BalanceConfiguration.spawnRateDecrease)x")
        
        // Performance monitoring
        logPerformanceMetric("ExtremelyHighSurvivalTime", result: result)
    }
    
    func testExecute_ExtremelyLowSurvivalTime() async throws {
        let agent = GameBalanceAgent()
        let context: [String: Sendable] = [
            "score": 700,
            "lives": 2,
            "survivalTime": Double.leastNormalMagnitude
        ]
        
        let result = try await agent.execute(context: context)
        
        XCTAssertEqual(result.success, true)
        XCTAssertEqual(result.detail["difficulty"] as? String, "decrease")
        XCTAssertEqual(result.detail["obstacleSpeed"] as? String, "\(BalanceConfiguration.obstacleSpeedDecrease)x")
        XCTAssertEqual(result.detail["spawnRate"] as? String, "\(BalanceConfiguration.spawnRateIncrease)x")
        
        // Performance monitoring
        logPerformanceMetric("ExtremelyLowSurvivalTime", result: result)
    }
    
    private func logPerformanceMetric(_ scenario: String, result: Result) {
        // Implement performance logging logic here
        print("Scenario: \(scenario), Difficulty: \(result.detail["difficulty"] as? String ?? "unknown"), Obstacle Speed: \(result.detail["obstacleSpeed"] as? String ?? "unknown"), Spawn Rate: \(result.detail["spawnRate"] as? String ?? "unknown")")
    }
}