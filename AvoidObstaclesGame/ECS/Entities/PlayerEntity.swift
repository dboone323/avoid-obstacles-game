//
// PlayerEntity.swift
// AvoidObstaclesGame
//
// Entity representing the player character with all necessary components.
//

import GameplayKit
import SpriteKit

/// Entity representing the player character.
class PlayerEntity: GKEntity {
    /// Convenience accessor for the sprite component's node.
    var node: SKSpriteNode? {
        component(ofType: SpriteComponent.self)?.node
    }

    /// Convenience accessor for the movement component.
    var movement: MovementComponent? {
        component(ofType: MovementComponent.self)
    }

    /// Creates a player entity at the specified position.
    /// - Parameters:
    ///   - position: Initial position for the player.
    ///   - scene: The scene to constrain movement to.
    init(at position: CGPoint, scene: SKScene) {
        super.init()

        // Add sprite component
        let spriteComponent = SpriteComponent(
            color: .systemBlue,
            size: CGSize(width: 50, height: 50)
        )
        spriteComponent.node.name = "player"
        spriteComponent.node.position = position
        spriteComponent.node.zPosition = 100
        addComponent(spriteComponent)

        // Add movement component
        let movementComponent = MovementComponent()
        movementComponent.scene = scene
        movementComponent.constrainToScreen = true
        addComponent(movementComponent)

        // Add physics component
        let physicsComponent = PhysicsComponent(
            categoryBitMask: PhysicsCategory.player,
            contactTestBitMask: PhysicsCategory.obstacle | PhysicsCategory.powerUp,
            collisionBitMask: 0,
            affectedByGravity: false,
            isDynamic: true
        )
        addComponent(physicsComponent)

        // Add visual effects
        addGlowEffect()
        addTrailEffect()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Adds a glow effect to the player.
    private func addGlowEffect() {
        guard let node else { return }

        let glowEffect = SKEffectNode()
        glowEffect.shouldRasterize = true
        glowEffect.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 3.0])

        let glowNode = SKSpriteNode(color: .cyan, size: CGSize(width: 55, height: 55))
        glowEffect.addChild(glowNode)
        glowEffect.zPosition = -1

        node.addChild(glowEffect)
    }

    /// Adds a trail effect behind the player.
    private func addTrailEffect() {
        guard let node else { return }

        let trailEffect = SKEmitterNode()
        trailEffect.particleBirthRate = 50
        trailEffect.particleLifetime = 0.5
        trailEffect.particleSpeed = 20
        trailEffect.particleSpeedRange = 10
        trailEffect.emissionAngle = .pi / 2
        trailEffect.emissionAngleRange = .pi / 4
        trailEffect.particleColor = .cyan
        trailEffect.particleBlendMode = .add
        trailEffect.particleScale = 0.1
        trailEffect.particleScaleRange = 0.05
        trailEffect.particleAlpha = 0.5
        trailEffect.particleAlphaSpeed = -1.0
        trailEffect.zPosition = -2
        trailEffect.targetNode = node.parent

        node.addChild(trailEffect)
    }

    /// Adds the player to the scene.
    /// - Parameter scene: The scene to add the player to.
    func addToScene(_ scene: SKScene) {
        guard let node else { return }
        scene.addChild(node)
    }

    /// Removes the player from its parent scene.
    func removeFromScene() {
        node?.removeFromParent()
    }

    /// Resets the player to initial state.
    /// - Parameter position: Position to reset to.
    func reset(to position: CGPoint) {
        guard let node else { return }

        // Ensure player is in scene
        if node.parent == nil {
            // Will need to be re-added to scene
        }

        node.position = position
        node.isHidden = false
        node.alpha = 1.0
        node.setScale(1.0)

        // Remove any power-up effects
        node.childNode(withName: "shield")?.removeFromParent()
        node.childNode(withName: "speedEffect")?.removeFromParent()
        node.childNode(withName: "magnetEffect")?.removeFromParent()
    }
}
