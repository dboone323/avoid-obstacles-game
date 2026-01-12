//
// MovementComponent.swift
// AvoidObstaclesGame
//
// Component that handles entity movement and position updates.
//

import GameplayKit
import SpriteKit

/// Component that handles movement for an entity.
class MovementComponent: GKComponent {
    
    /// Current velocity of the entity.
    var velocity: CGVector = .zero
    
    /// Maximum speed the entity can move.
    var maxSpeed: CGFloat = 300.0
    
    /// Whether the entity should be constrained to screen bounds.
    var constrainToScreen: Bool = true
    
    /// The scene bounds for constraint checking.
    weak var scene: SKScene?
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Moves the entity to a target position with smooth animation.
    /// - Parameter position: Target position to move to.
    func moveTo(_ position: CGPoint) {
        guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else { return }
        
        var targetPosition = position
        
        // Constrain to screen bounds if enabled
        if constrainToScreen, let scene = scene {
            let halfWidth = spriteComponent.node.size.width / 2
            let halfHeight = spriteComponent.node.size.height / 2
            
            targetPosition.x = max(halfWidth, min(scene.size.width - halfWidth, targetPosition.x))
            targetPosition.y = max(halfHeight, min(scene.size.height - halfHeight, targetPosition.y))
        }
        
        // Smooth movement animation
        let moveAction = SKAction.move(to: targetPosition, duration: 0.1)
        moveAction.timingMode = .easeOut
        spriteComponent.node.run(moveAction)
    }
    
    /// Sets position directly without animation.
    /// - Parameter position: Position to set.
    func setPosition(_ position: CGPoint) {
        guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else { return }
        spriteComponent.node.position = position
    }
    
    /// Gets the current position.
    var position: CGPoint {
        entity?.component(ofType: SpriteComponent.self)?.node.position ?? .zero
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard velocity != .zero,
              let spriteComponent = entity?.component(ofType: SpriteComponent.self) else { return }
        
        var newPosition = spriteComponent.node.position
        newPosition.x += velocity.dx * CGFloat(seconds)
        newPosition.y += velocity.dy * CGFloat(seconds)
        
        // Apply constraints
        if constrainToScreen, let scene = scene {
            let halfWidth = spriteComponent.node.size.width / 2
            let halfHeight = spriteComponent.node.size.height / 2
            newPosition.x = max(halfWidth, min(scene.size.width - halfWidth, newPosition.x))
            newPosition.y = max(halfHeight, min(scene.size.height - halfHeight, newPosition.y))
        }
        
        spriteComponent.node.position = newPosition
    }
}
