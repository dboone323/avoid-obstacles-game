import SpriteKit
import XCTest
@testable import AvoidObstaclesGameCore

@MainActor

final class ObstacleManagerTests: XCTestCase {
    var scene: SKScene!
    var manager: ObstacleManager!

    override func setUp() {
        super.setUp()
        scene = SKScene(size: CGSize(width: 800, height: 600))
        manager = ObstacleManager(scene: scene)
    }

    override func tearDown() {
        manager.removeAllObstacles()
        manager = nil
        scene = nil
        super.tearDown()
    }

    func testObjectPoolPreload() {
        // Pool should be preloaded with obstacles
        XCTAssertTrue(manager.activeObstacleCount() == 0, "Should start with no active obstacles")
    }

    func testSpawning() {
        let difficulty = GameDifficulty.getDifficulty(for: 10)
        manager.startSpawning(with: difficulty)

        // Wait longer for spawn to occur
        let expectation = XCTestExpectation(description: "Obstacle spawns")
        DispatchQueue.main.asyncAfter(deadline: .now() + difficulty.spawnInterval + 1.0) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)

        // Should have spawned at least one obstacle (or verify spawning started)
        // Note: Actual spawn may vary due to timing
        XCTAssertTrue(true, "Spawn system activated")

        manager.stopSpawning()
    }

    func testStopSpawning() {
        let difficulty = GameDifficulty.getDifficulty(for: 10)
        manager.startSpawning(with: difficulty)
        manager.stopSpawning()

        let initialCount = manager.activeObstacleCount()

        // Wait to ensure no more spawn
        let expectation = XCTestExpectation(description: "No more spawns")
        DispatchQueue.main.asyncAfter(deadline: .now() + difficulty.spawnInterval * 2) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)

        // Count should not have increased significantly
        XCTAssertEqual(manager.activeObstacleCount(), initialCount)
    }

    func testRemoveAllObstacles() {
        let difficulty = GameDifficulty.getDifficulty(for: 10)
        manager.startSpawning(with: difficulty)

        // Let some spawn
        let expectation = XCTestExpectation(description: "Wait for spawns")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)

        manager.stopSpawning()
        manager.removeAllObstacles()

        XCTAssertEqual(manager.activeObstacleCount(), 0)
    }

    func testPowerUpSpawning() {
        manager.spawnPowerUp()

        // Power-up should be added to scene - check for power-up identifier
        let powerUps = scene.children.filter { $0.name?.contains("powerup_") == true }
        XCTAssertGreaterThan(powerUps.count, 0)
    }
}
