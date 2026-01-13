//
// PowerUpComponent.swift
// AvoidObstaclesGame
//
// Step 33: Power-up ECS components.
//

import Foundation
import GameplayKit
import SpriteKit

// MARK: - Power-Up Types

enum PowerUpType: String, CaseIterable {
    case shield = "shield"
    case speedBoost = "speed"
    case slowMotion = "slow"
    case magnet = "magnet"
    case doublePoints = "double"
    
    var color: SKColor {
        switch self {
        case .shield: return .cyan
        case .speedBoost: return .yellow
        case .slowMotion: return .purple
        case .magnet: return .gray
        case .doublePoints: return .green
        }
    }
    
    var duration: TimeInterval {
        switch self {
        case .shield: return 5.0
        case .speedBoost: return 3.0
        case .slowMotion: return 4.0
        case .magnet: return 6.0
        case .doublePoints: return 10.0
        }
    }
    
    var iconName: String {
        switch self {
        case .shield: return "shield.fill"
        case .speedBoost: return "bolt.fill"
        case .slowMotion: return "clock.fill"
        case .magnet: return "sparkle.magnifyingglass"
        case .doublePoints: return "star.fill"
        }
    }
}

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
        
        node.run(SKAction.sequence([
            SKAction.group([fadeOut, scaleUp]),
            remove
        ]))
    }
}

// MARK: - Power-Up Manager

class PowerUpManager {
    
    private var activePowerUps: [PowerUpType: TimeInterval] = [:]
    
    func activatePowerUp(_ type: PowerUpType) {
        activePowerUps[type] = type.duration
        print("[PowerUp] Activated: \(type.rawValue) for \(type.duration)s")
    }
    
    func update(deltaTime: TimeInterval) {
        for (type, remaining) in activePowerUps {
            let newRemaining = remaining - deltaTime
            if newRemaining <= 0 {
                activePowerUps.removeValue(forKey: type)
                print("[PowerUp] Expired: \(type.rawValue)")
            } else {
                activePowerUps[type] = newRemaining
            }
        }
    }
    
    func isActive(_ type: PowerUpType) -> Bool {
        activePowerUps[type] != nil
    }
    
    func remainingTime(for type: PowerUpType) -> TimeInterval {
        activePowerUps[type] ?? 0
    }
    
    var hasShield: Bool { isActive(.shield) }
    var hasSpeedBoost: Bool { isActive(.speedBoost) }
    var hasSlowMotion: Bool { isActive(.slowMotion) }
    var hasMagnet: Bool { isActive(.magnet) }
    var hasDoublePoints: Bool { isActive(.doublePoints) }
    
    func reset() {
        activePowerUps.removeAll()
    }
}

// MARK: - Physics Categories

struct PhysicsCategory {
    static let none: UInt32      = 0
    static let player: UInt32    = 0x1 << 0
    static let obstacle: UInt32  = 0x1 << 1
    static let powerUp: UInt32   = 0x1 << 2
    static let boundary: UInt32  = 0x1 << 3
}
