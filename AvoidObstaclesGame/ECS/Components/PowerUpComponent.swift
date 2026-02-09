//
// PowerUpComponent.swift
// AvoidObstaclesGame
//
// Step 33: Power-up ECS components.
// NOTE: PowerUpType, PowerUpManager, and PhysicsCategory are defined in PowerUpManager.swift
//

import Foundation
import GameplayKit
import SpriteKit

// MARK: - Power-Up Component

class PowerUpComponent: GKComponent {
    let powerUpType: PowerUpType
    var isCollected: Bool = false
    var remainingDuration: TimeInterval

    init(type: PowerUpType) {
        self.powerUpType = type
        self.remainingDuration = type.duration
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update(deltaTime seconds: TimeInterval) {
        if isCollected && remainingDuration > 0 {
            remainingDuration -= seconds
        }
    }

    var isExpired: Bool {
        isCollected && remainingDuration <= 0
    }
}

// MARK: - Power-Up Entity

class PowerUpEntity: GKEntity {
    let powerUpType: PowerUpType

    var node: SKSpriteNode? {
        component(ofType: SpriteComponent.self)?.node
    }

    init(type: PowerUpType, at position: CGPoint) {
        self.powerUpType = type
        super.init()

        // Sprite component
        let size = CGSize(width: 30, height: 30)
        let spriteComponent = SpriteComponent(color: type.color, size: size)
        spriteComponent.node.position = position
        spriteComponent.node.name = "powerup_\(type.rawValue)"
        spriteComponent.node.zPosition = 5
        addComponent(spriteComponent)

        // Power-up component
        addComponent(PowerUpComponent(type: type))

        // Physics component
        let physicsComponent = PhysicsComponent(
            categoryBitMask: PhysicsCategory.powerUp,
            contactTestBitMask: PhysicsCategory.player,
            collisionBitMask: 0,
            affectedByGravity: false,
            isDynamic: false
        )
        addComponent(physicsComponent)

        // Add visual effects
        addPulseEffect()
        addGlowEffect()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addPulseEffect() {
        guard let node = self.node else { return }

        let scaleUp = SKAction.scale(to: 1.2, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        node.run(SKAction.repeatForever(pulse))
    }

    private func addGlowEffect() {
        guard let node = self.node else { return }

        let glow = SKShapeNode(circleOfRadius: 20)
        glow.fillColor = powerUpType.color.withAlphaComponent(0.3)
        glow.strokeColor = .clear
        glow.zPosition = -1
        node.addChild(glow)

        let fadeOut = SKAction.fadeAlpha(to: 0.1, duration: 0.5)
        let fadeIn = SKAction.fadeAlpha(to: 0.5, duration: 0.5)
        glow.run(SKAction.repeatForever(SKAction.sequence([fadeOut, fadeIn])))
    }

    func collect() {
        guard let powerUpComponent = component(ofType: PowerUpComponent.self) else { return }
        powerUpComponent.isCollected = true

        // Remove from scene with effect
        guard let node = self.node else { return }

        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let remove = SKAction.removeFromParent()

        node.run(
            SKAction.sequence([
                SKAction.group([fadeOut, scaleUp]),
                remove,
            ]))
    }
}
