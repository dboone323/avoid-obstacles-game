//
// PhysicsComponent.swift
// AvoidObstaclesGame
//
// Component that provides physics body configuration for collision detection.
//

import GameplayKit
import SpriteKit

/// Component that configures physics body for an entity.
class PhysicsComponent: GKComponent {
    /// Physics category for this entity.
    let categoryBitMask: UInt32

    /// Categories this entity should detect contact with.
    let contactTestBitMask: UInt32

    /// Categories this entity collides with (physical response).
    let collisionBitMask: UInt32

    /// Whether this body is affected by gravity.
    let affectedByGravity: Bool

    /// Whether this body is dynamic (moves in response to forces).
    let isDynamic: Bool

    /// Creates a physics component with specified configuration.
    init(
        categoryBitMask: UInt32,
        contactTestBitMask: UInt32,
        collisionBitMask: UInt32 = 0,
        affectedByGravity: Bool = false,
        isDynamic: Bool = true
    ) {
        self.categoryBitMask = categoryBitMask
        self.contactTestBitMask = contactTestBitMask
        self.collisionBitMask = collisionBitMask
        self.affectedByGravity = affectedByGravity
        self.isDynamic = isDynamic
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Applies the physics configuration to the sprite component's node.
    func applyToSprite() {
        guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else { return }
        let node = spriteComponent.node

        // Create physics body based on sprite size
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.categoryBitMask = categoryBitMask
        node.physicsBody?.contactTestBitMask = contactTestBitMask
        node.physicsBody?.collisionBitMask = collisionBitMask
        node.physicsBody?.affectedByGravity = affectedByGravity
        node.physicsBody?.isDynamic = isDynamic
        node.physicsBody?.allowsRotation = false
    }

    override func didAddToEntity() {
        applyToSprite()
    }
}
