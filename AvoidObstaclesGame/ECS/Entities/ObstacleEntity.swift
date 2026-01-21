//
// ObstacleEntity.swift
// AvoidObstaclesGame
//
// Entity representing an obstacle with components for rendering and physics.
//

import GameplayKit
import SpriteKit

/// Entity representing a falling obstacle.
class ObstacleEntity: GKEntity {
    /// The type of obstacle.
    let obstacleType: ObstacleType

    /// Convenience accessor for the sprite component's node.
    var node: SKSpriteNode? {
        component(ofType: SpriteComponent.self)?.node
    }

    /// Creates an obstacle entity.
    /// - Parameters:
    ///   - type: The type of obstacle to create.
    ///   - position: Initial position for the obstacle.
    init(type: ObstacleType, at position: CGPoint) {
        self.obstacleType = type
        super.init()

        let config = type.configuration

        // Add sprite component
        let spriteComponent = SpriteComponent(
            color: config.color,
            size: config.size
        )
        spriteComponent.node.name = "obstacle"
        spriteComponent.node.position = position
        spriteComponent.node.zPosition = 50
        addComponent(spriteComponent)

        // Add physics component
        let physicsComponent = PhysicsComponent(
            categoryBitMask: PhysicsCategory.obstacle,
            contactTestBitMask: PhysicsCategory.player,
            collisionBitMask: 0,
            affectedByGravity: false,
            isDynamic: true
        )
        addComponent(physicsComponent)

        // Add visual effects
        addVisualEffects(config: config)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Adds visual effects based on obstacle configuration.
    private func addVisualEffects(config: ObstacleConfiguration) {
        guard let node else { return }

        // Add border effect
        let borderWidth: CGFloat = 2.0
        let borderColor = config.borderColor

        let topBorder = SKSpriteNode(color: borderColor, size: CGSize(width: config.size.width, height: borderWidth))
        topBorder.position = CGPoint(x: 0, y: config.size.height / 2 - borderWidth / 2)
        node.addChild(topBorder)

        let bottomBorder = SKSpriteNode(color: borderColor, size: CGSize(width: config.size.width, height: borderWidth))
        bottomBorder.position = CGPoint(x: 0, y: -config.size.height / 2 + borderWidth / 2)
        node.addChild(bottomBorder)

        // Add glow for special obstacles
        if config.hasGlow {
            let glowSize = CGSize(width: config.size.width * 1.2, height: config.size.height * 1.2)
            let glowNode = SKSpriteNode(color: config.color.withAlphaComponent(0.3), size: glowSize)
            glowNode.zPosition = -1
            node.addChild(glowNode)
        }
    }

    /// Adds the obstacle to the scene.
    func addToScene(_ scene: SKScene) {
        guard let node else { return }
        scene.addChild(node)
    }

    /// Removes the obstacle from its parent.
    func removeFromScene() {
        node?.removeFromParent()
    }

    /// Resets the obstacle for reuse (object pooling).
    func reset(type: ObstacleType, at position: CGPoint) {
        guard let node else { return }

        let config = type.configuration
        node.color = config.color
        node.size = config.size
        node.position = position
        node.removeAllActions()
        node.isHidden = false

        // Re-apply physics
        component(ofType: PhysicsComponent.self)?.applyToSprite()
    }
}
