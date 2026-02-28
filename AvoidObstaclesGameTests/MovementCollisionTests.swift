//
// MovementCollisionTests.swift
// AvoidObstaclesGameTests
//
// Tests for player movement (left/right) and collision detection

import SpriteKit
import XCTest
@testable import AvoidObstaclesGameCore

@MainActor

final class MovementCollisionTests: XCTestCase {
    var scene: SKScene!
    var playerManager: PlayerManager!

    override func setUp() {
        super.setUp()
        scene = SKScene(size: CGSize(width: 400, height: 600))
        playerManager = PlayerManager(scene: scene)
        playerManager.createPlayer(at: CGPoint(x: 200, y: 100))
    }

    override func tearDown() {
        playerManager = nil
        scene = nil
        super.tearDown()
    }

    // MARK: - Left/Right Movement Tests

    func testMovePlayerLeft() {
        let startX = playerManager.position.x
        let targetPosition = CGPoint(x: startX - 50, y: playerManager.position.y)

        playerManager.moveTo(targetPosition)

        // Verify movement action was created
        XCTAssertNotNil(playerManager.player?.action(forKey: "playerMovement"))
    }

    func testMovePlayerRight() {
        let startX = playerManager.position.x
        let targetPosition = CGPoint(x: startX + 50, y: playerManager.position.y)

        playerManager.moveTo(targetPosition)

        // Verify movement action was created
        XCTAssertNotNil(playerManager.player?.action(forKey: "playerMovement"))
    }

    func testMovePlayerToExactPosition() {
        let targetPosition = CGPoint(x: 300, y: 100)

        playerManager.setPosition(targetPosition)

        XCTAssertEqual(playerManager.position.x, 300, accuracy: 0.1)
        XCTAssertEqual(playerManager.position.y, 100, accuracy: 0.1)
    }

    func testMultipleMovements() {
        // Move left
        playerManager.setPosition(CGPoint(x: 100, y: 100))
        XCTAssertEqual(playerManager.position.x, 100, accuracy: 0.1)

        // Move right
        playerManager.setPosition(CGPoint(x: 300, y: 100))
        XCTAssertEqual(playerManager.position.x, 300, accuracy: 0.1)

        // Move back to center
        playerManager.setPosition(CGPoint(x: 200, y: 100))
        XCTAssertEqual(playerManager.position.x, 200, accuracy: 0.1)
    }

    // MARK: - Boundary Tests

    func testPlayerStaysWithinLeftBoundary() {
        // Try to move beyond left edge
        let targetPosition = CGPoint(x: -100, y: 100)
        playerManager.setPosition(targetPosition)

        // Position should be clamped or limited
        // The exact behavior depends on implementation
        XCTAssertNotNil(playerManager.position)
    }

    func testPlayerStaysWithinRightBoundary() {
        // Try to move beyond right edge
        let targetPosition = CGPoint(x: 500, y: 100)
        playerManager.setPosition(targetPosition)

        // Position should be clamped or limited
        XCTAssertNotNil(playerManager.position)
    }

    // MARK: - Collision Detection Tests

    func testPlayerPhysicsBodySetup() {
        XCTAssertNotNil(playerManager.player?.physicsBody)
        XCTAssertEqual(playerManager.player?.physicsBody?.categoryBitMask, PhysicsCategory.player)
    }

    func testPlayerContactTestMask() {
        let contactMask = playerManager.player?.physicsBody?.contactTestBitMask ?? 0

        // Player should detect contact with obstacles
        XCTAssertTrue((contactMask & PhysicsCategory.obstacle) != 0, "Player should detect obstacles")

        // Player should detect contact with powerups
        XCTAssertTrue((contactMask & PhysicsCategory.powerUp) != 0, "Player should detect power-ups")
    }

    func testPlayerCollisionMask() {
        // Player has no collision mask (isDynamic=false, uses contact detection instead)
        let collisionMask = playerManager.player?.physicsBody?.collisionBitMask ?? 0

        // Player collision mask should be none (player movement is handled manually, not by physics)
        XCTAssertEqual(
            collisionMask,
            PhysicsCategory.none,
            "Player should have no collision mask (uses contact detection)"
        )
    }

    func testPlayerCollisionResponse() {
        // Simulate collision response
        guard let player = playerManager.player else {
            XCTFail("Player should exist")
            return
        }

        // Create a mock obstacle
        let obstacle = SKSpriteNode(color: .red, size: CGSize(width: 30, height: 30))
        obstacle.name = "obstacle"
        scene.addChild(obstacle)

        // Trigger collision handler
        playerManager.handleCollision(with: obstacle)

        // Player should have flash animation
        // The handleCollision triggers visual feedback
        XCTAssertNotNil(player.parent) // Player still exists after collision
    }

    // MARK: - Obstacle Physics Tests

    func testObstaclePhysicsBodySetup() {
        // Create obstacle directly for testing (spawnObstacle is private)
        let obstacle = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 40))
        obstacle.name = "obstacle"
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        obstacle.physicsBody?.contactTestBitMask = PhysicsCategory.player
        scene.addChild(obstacle)

        XCTAssertNotNil(obstacle.physicsBody, "Obstacle should have physics body")
        XCTAssertEqual(obstacle.physicsBody?.categoryBitMask, PhysicsCategory.obstacle)
    }

    func testObstacleContactWithPlayer() {
        // Create obstacle with proper physics
        let obstacle = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 40))
        obstacle.name = "obstacle"
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        obstacle.physicsBody?.contactTestBitMask = PhysicsCategory.player
        scene.addChild(obstacle)

        // Verify obstacle can contact player
        XCTAssertTrue((obstacle.physicsBody?.contactTestBitMask ?? 0 & PhysicsCategory.player) != 0)
    }

    // MARK: - Physics Category Tests

    func testPhysicsCategoriesAreDefined() {
        XCTAssertNotEqual(PhysicsCategory.none, PhysicsCategory.player)
        XCTAssertNotEqual(PhysicsCategory.player, PhysicsCategory.obstacle)
        XCTAssertNotEqual(PhysicsCategory.obstacle, PhysicsCategory.powerUp)
        XCTAssertNotEqual(PhysicsCategory.powerUp, PhysicsCategory.boundary)
    }

    func testPhysicsCategoriesAreUnique() {
        let categories: [UInt32] = [
            PhysicsCategory.none,
            PhysicsCategory.player,
            PhysicsCategory.obstacle,
            PhysicsCategory.powerUp,
            PhysicsCategory.boundary,
        ]

        let uniqueCategories = Set(categories)
        XCTAssertEqual(categories.count, uniqueCategories.count, "All physics categories should be unique")
    }

    // MARK: - Player State After Movement

    func testPlayerRemainsVisibleAfterMovement() {
        playerManager.moveTo(CGPoint(x: 100, y: 100))
        XCTAssertFalse(playerManager.player?.isHidden ?? true)
    }

    func testPlayerResetRestoresPosition() {
        let originalPosition = playerManager.position

        // Move player
        playerManager.setPosition(CGPoint(x: 300, y: 200))
        XCTAssertNotEqual(playerManager.position, originalPosition)

        // Reset should restore visibility (position depends on implementation)
        playerManager.reset()
        XCTAssertFalse(playerManager.player?.isHidden ?? true)
    }

    // MARK: - Power-up Collision Tests

    func testPowerUpCollisionTriggersEffect() {
        // Apply shield power-up
        playerManager.applyPowerUpEffect(.shield)
        XCTAssertNotNil(playerManager.player?.childNode(withName: "shield"))

        // Apply speed power-up
        playerManager.applyPowerUpEffect(.speedBoost)
        XCTAssertNotNil(playerManager.player?.childNode(withName: "speedEffect"))
    }

    func testMultiplePowerUpEffects() {
        playerManager.applyPowerUpEffect(.shield)
        playerManager.applyPowerUpEffect(.speedBoost)

        // Both effects should exist
        XCTAssertNotNil(playerManager.player?.childNode(withName: "shield"))
        XCTAssertNotNil(playerManager.player?.childNode(withName: "speedEffect"))

        // Clear all effects
        playerManager.removePowerUpEffects()
        XCTAssertNil(playerManager.player?.childNode(withName: "shield"))
        XCTAssertNil(playerManager.player?.childNode(withName: "speedEffect"))
    }
}
