//
// SpriteComponent.swift
// AvoidObstaclesGame
//
// Component that provides a visual representation via SKSpriteNode.
//

import GameplayKit
import SpriteKit

/// Component that provides a visual representation for an entity.
class SpriteComponent: GKComponent {
    /// The sprite node representing this entity.
    let node: SKSpriteNode

    /// Creates a sprite component with a colored rectangle.
    /// - Parameters:
    ///   - color: The fill color of the sprite.
    ///   - size: The size of the sprite.
    init(color: SKColor, size: CGSize) {
        self.node = SKSpriteNode(color: color, size: size)
        super.init()
    }

    /// Creates a sprite component with an existing node.
    /// - Parameter node: An existing SKSpriteNode.
    init(node: SKSpriteNode) {
        self.node = node
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Updates the node's position from the entity's other components if needed.
    override func update(deltaTime seconds: TimeInterval) {
        // Position sync handled by MovementComponent
    }
}
