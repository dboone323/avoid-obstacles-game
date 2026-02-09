//
// EntityManager.swift
// AvoidObstaclesGame
//
// Manages all game entities and component systems.
//

import GameplayKit
import SpriteKit

/// Manages all game entities and provides access to component systems.
class EntityManager {
    /// Reference to the game scene.
    weak var scene: SKScene?

    /// All active entities.
    private var entities = Set<GKEntity>()

    /// The player entity.
    private(set) var playerEntity: PlayerEntity?

    /// Pool of reusable obstacle entities.
    private var obstaclePool: [ObstacleEntity] = []

    /// Active obstacle entities.
    private var activeObstacles = Set<ObstacleEntity>()

    /// Component system for movement updates.
    private let movementSystem = GKComponentSystem(componentClass: MovementComponent.self)

    // MARK: - Initialization

    init(scene: SKScene) {
        self.scene = scene
        initializeObstaclePool()
    }

    /// Pre-creates obstacle entities for object pooling.
    private func initializeObstaclePool() {
        for _ in 0..<20 {
            let obstacle = ObstacleEntity(type: .normal, at: .zero)
            obstaclePool.append(obstacle)
        }
    }

    // MARK: - Entity Management

    /// Adds an entity to the manager.
    func add(_ entity: GKEntity) {
        entities.insert(entity)

        // Add components to systems
        movementSystem.addComponent(foundIn: entity)
    }

    /// Removes an entity from the manager.
    func remove(_ entity: GKEntity) {
        entities.remove(entity)

        // Remove components from systems
        movementSystem.removeComponent(foundIn: entity)
    }

    // MARK: - Player

    /// Creates and adds the player entity.
    func createPlayer(at position: CGPoint) {
        guard let scene else { return }

        let player = PlayerEntity(at: position, scene: scene)
        playerEntity = player
        player.addToScene(scene)
        add(player)
    }

    /// Resets the player to initial position.
    func resetPlayer(to position: CGPoint) {
        guard let player = playerEntity, let scene else { return }

        player.reset(to: position)

        // Re-add to scene if needed
        if player.node?.parent == nil {
            player.addToScene(scene)
        }
    }

    // MARK: - Obstacles

    /// Gets an obstacle entity from the pool or creates a new one.
    func getObstacle(type: ObstacleType, at position: CGPoint) -> ObstacleEntity {
        let obstacle: ObstacleEntity

        if let pooled = obstaclePool.popLast() {
            pooled.reset(type: type, at: position)
            obstacle = pooled
        } else {
            obstacle = ObstacleEntity(type: type, at: position)
        }

        if let scene {
            obstacle.addToScene(scene)
        }

        activeObstacles.insert(obstacle)
        add(obstacle)

        return obstacle
    }

    /// Returns an obstacle to the pool.
    func recycleObstacle(_ obstacle: ObstacleEntity) {
        obstacle.removeFromScene()
        activeObstacles.remove(obstacle)
        remove(obstacle)
        obstaclePool.append(obstacle)
    }

    /// Removes all active obstacles.
    func removeAllObstacles() {
        for obstacle in activeObstacles {
            obstacle.removeFromScene()
            remove(obstacle)
            obstaclePool.append(obstacle)
        }
        activeObstacles.removeAll()
    }

    /// Gets count of active obstacles.
    var activeObstacleCount: Int {
        activeObstacles.count
    }

    // MARK: - Update

    /// Updates all component systems.
    func update(deltaTime: TimeInterval) {
        movementSystem.update(deltaTime: deltaTime)
    }
}
