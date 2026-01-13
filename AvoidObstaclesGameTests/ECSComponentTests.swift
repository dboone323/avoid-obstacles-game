//
// ECSComponentTests.swift
// AvoidObstaclesGameTests
//
// Unit tests for ECS components (SpriteComponent, MovementComponent, PhysicsComponent).
//

import XCTest
import GameplayKit
import SpriteKit
@testable import AvoidObstaclesGame

final class ECSComponentTests: XCTestCase {
    
    // MARK: - SpriteComponent Tests
    
    func testSpriteComponentInitWithColor() {
        let component = SpriteComponent(color: .blue, size: CGSize(width: 50, height: 50))
        
        XCTAssertNotNil(component.node)
        XCTAssertEqual(component.node.size, CGSize(width: 50, height: 50))
    }
    
    func testSpriteComponentInitWithNode() {
        let existingNode = SKSpriteNode(color: .red, size: CGSize(width: 100, height: 100))
        let component = SpriteComponent(node: existingNode)
        
        XCTAssertEqual(component.node, existingNode)
    }
    
    // MARK: - MovementComponent Tests
    
    func testMovementComponentDefaultValues() {
        let component = MovementComponent()
        
        XCTAssertEqual(component.velocity, .zero)
        XCTAssertEqual(component.maxSpeed, 300.0)
        XCTAssertTrue(component.constrainToScreen)
    }
    
    func testMovementComponentVelocity() {
        let component = MovementComponent()
        component.velocity = CGVector(dx: 100, dy: 50)
        
        XCTAssertEqual(component.velocity.dx, 100)
        XCTAssertEqual(component.velocity.dy, 50)
    }
    
    // MARK: - PhysicsComponent Tests
    
    func testPhysicsComponentInitialization() {
        let component = PhysicsComponent(
            categoryBitMask: 0x01,
            contactTestBitMask: 0x02,
            collisionBitMask: 0x00,
            affectedByGravity: false,
            isDynamic: true
        )
        
        XCTAssertEqual(component.categoryBitMask, 0x01)
        XCTAssertEqual(component.contactTestBitMask, 0x02)
        XCTAssertEqual(component.collisionBitMask, 0x00)
        XCTAssertFalse(component.affectedByGravity)
        XCTAssertTrue(component.isDynamic)
    }
    
    // MARK: - Entity Integration Tests
    
    func testPlayerEntityHasAllComponents() {
        let scene = SKScene(size: CGSize(width: 400, height: 600))
        let player = PlayerEntity(at: CGPoint(x: 200, y: 100), scene: scene)
        
        XCTAssertNotNil(player.component(ofType: SpriteComponent.self))
        XCTAssertNotNil(player.component(ofType: MovementComponent.self))
        XCTAssertNotNil(player.component(ofType: PhysicsComponent.self))
    }
    
    func testPlayerEntityNodeConfiguration() {
        let scene = SKScene(size: CGSize(width: 400, height: 600))
        let player = PlayerEntity(at: CGPoint(x: 200, y: 100), scene: scene)
        
        XCTAssertEqual(player.node?.name, "player")
        XCTAssertEqual(player.node?.position, CGPoint(x: 200, y: 100))
    }
    
    func testObstacleEntityCreation() {
        let obstacle = ObstacleEntity(type: .normal, at: CGPoint(x: 100, y: 500))
        
        XCTAssertNotNil(obstacle.component(ofType: SpriteComponent.self))
        XCTAssertNotNil(obstacle.component(ofType: PhysicsComponent.self))
        XCTAssertEqual(obstacle.node?.name, "obstacle")
    }
    
    // MARK: - EntityManager Tests
    
    func testEntityManagerCreatesPlayer() {
        let scene = SKScene(size: CGSize(width: 400, height: 600))
        let manager = EntityManager(scene: scene)
        
        manager.createPlayer(at: CGPoint(x: 200, y: 100))
        
        XCTAssertNotNil(manager.playerEntity)
    }
    
    func testEntityManagerObstaclePooling() {
        let scene = SKScene(size: CGSize(width: 400, height: 600))
        let manager = EntityManager(scene: scene)
        
        let obstacle1 = manager.getObstacle(type: .normal, at: CGPoint(x: 100, y: 500))
        XCTAssertEqual(manager.activeObstacleCount, 1)
        
        manager.recycleObstacle(obstacle1)
        XCTAssertEqual(manager.activeObstacleCount, 0)
    }
    
    func testEntityManagerRemoveAllObstacles() {
        let scene = SKScene(size: CGSize(width: 400, height: 600))
        let manager = EntityManager(scene: scene)
        
        _ = manager.getObstacle(type: .normal, at: CGPoint(x: 100, y: 500))
        _ = manager.getObstacle(type: .fast, at: CGPoint(x: 200, y: 500))
        _ = manager.getObstacle(type: .large, at: CGPoint(x: 300, y: 500))
        
        XCTAssertEqual(manager.activeObstacleCount, 3)
        
        manager.removeAllObstacles()
        XCTAssertEqual(manager.activeObstacleCount, 0)
    }
}
