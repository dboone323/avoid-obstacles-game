import SpriteKit

/// Manages power-ups in the game
class PowerUpManager {
    weak var scene: SKScene?
    private var activePowerUps: Set<PowerUpType> = []
    private var powerUpPool: [SKSpriteNode] = []
    private let maxPoolSize = 10
    
    // Power-up timers
    private var shieldTimer: Timer?
    private var slowTimeTimer: Timer?
    private var speedBoostTimer: Timer?
    
    init(scene: SKScene) {
        self.scene = scene
        preloadPowerUps()
    }
    
    // MARK: - Power-Up Spawning
    
    func spawnRandomPowerUp(at position: CGPoint) {
        let powerUpType = PowerUpType.allCases.randomElement() ?? .shield
        spawnPowerUp(type: powerUpType, at: position)
    }
    
    func spawnPowerUp(type: PowerUpType, at position: CGPoint) {
        let powerUp = getPooledPowerUp()
        powerUp.position = position
        powerUp.name = "powerup_\(type.rawValue)"
        powerUp.texture = SKTexture(imageNamed: type.iconName)
        powerUp.size = CGSize(width: 40, height: 40)
        powerUp.zPosition = 10
        
        // Physics
        powerUp.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        powerUp.physicsBody?.categoryBitMask = PhysicsCategory.powerUp
        powerUp.physicsBody?.collisionBitMask = 0
        powerUp.physicsBody?.contactTestBitMask = PhysicsCategory.player
        powerUp.physicsBody?.isDynamic = false
        
        // Animation
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 2.0)
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        powerUp.run(SKAction.repeatForever(rotate), withKey: "rotate")
        powerUp.run(SKAction.repeatForever(pulse), withKey: "pulse")
        
        scene?.addChild(powerUp)
    }
    
    // MARK: - Power-Up Activation
    
    func activatePowerUp(type: PowerUpType, for player: SKNode) {
        guard !activePowerUps.contains(type) else { return }
        
        activePowerUps.insert(type)
        
        switch type {
        case .shield:
            activateShield(for: player)
        case .slowTime:
            activateSlowTime()
        case .speedBoost:
            activateSpeedBoost(for: player)
        case .magnet:
            // Implement magnet
            break
        case .doublePoints:
            // Implement double points
            break
        }
        
        // Post notification
        NotificationCenter.default.post(name: .powerUpActivated, object: type)
    }
    
    private func activateShield(for player: SKNode) {
        // Visual shield effect
        let shield = SKShapeNode(circleOfRadius: 60)
        shield.strokeColor = .cyan
        shield.lineWidth = 3
        shield.fillColor = .cyan.withAlphaComponent(0.2)
        shield.name = "shield"
        shield.zPosition = -1
        player.addChild(shield)
        
        // Pulse animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        shield.run(SKAction.repeatForever(pulse))
        
        // Remove after 10 seconds
        shieldTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            shield.removeFromParent()
            self?.activePowerUps.remove(.shield)
        }
    }
    
    private func activateSlowTime() {
        scene?.speed = 0.5
        
        // Visual slow-mo effect
        let slowLabel = SKLabelNode(text: "SLOW TIME")
        slowLabel.fontSize = 30
        slowLabel.fontColor = .yellow
        slowLabel.position = CGPoint(x: 0, y: 100)
        slowLabel.zPosition = 100
        scene?.addChild(slowLabel)
        
        slowTimeTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.scene?.speed = 1.0
            slowLabel.removeFromParent()
            self?.activePowerUps.remove(.slowTime)
        }
    }
    
    private func activateSpeedBoost(for player: SKNode) {
        // Increase player speed (handled by PlayerManager)
        NotificationCenter.default.post(name: .speedBoostActivated, object: nil)
        
        // Trail effect
        if let emitter = SKEmitterNode(fileNamed: "SpeedTrail") {
            emitter.targetNode = scene
            player.addChild(emitter)
            emitter.name = "speedTrail"
            
            speedBoostTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { [weak self] _ in
                emitter.removeFromParent()
                self?.activePowerUps.remove(.speedBoost)
                NotificationCenter.default.post(name: .speedBoostDeactivated, object: nil)
            }
        }
    }
    
    // MARK: - Object Pooling
    
    private func preloadPowerUps() {
        for _ in 0..<maxPoolSize {
            let powerUp = SKSpriteNode()
            powerUp.isHidden = true
            powerUpPool.append(powerUp)
        }
    }
    
    private func getPooledPowerUp() -> SKSpriteNode {
        if let pooled = powerUpPool.first(where: { $0.parent == nil }) {
            pooled.isHidden = false
            return pooled
        }
        return SKSpriteNode()
    }
    
    func returnToPool(_ powerUp: SKSpriteNode) {
        powerUp.removeAllActions()
        powerUp.removeFromParent()
        powerUp.isHidden = true
    }
    
    // MARK: - Cleanup
    
    func cleanup() {
        shieldTimer?.invalidate()
        slowTimeTimer?.invalidate()
        speedBoostTimer?.invalidate()
        activePowerUps.removeAll()
    }
}

public enum PowerUpType: String, CaseIterable {
    case shield
    case slowTime
    case speedBoost
    case magnet
    case doublePoints
    
    var iconName: String {
        switch self {
        case .shield: return "shield"
        case .slowTime: return "clock"
        case .speedBoost: return "bolt"
        case .magnet: return "magnet"
        case .doublePoints: return "star"
        }
    }
    
    var identifier: String {
        "powerup_\(rawValue)"
    }
    
    var shape: PowerUpShape {
        switch self {
        case .shield: return .circle
        case .slowTime: return .triangle
        case .speedBoost: return .triangle
        case .magnet: return .square
        case .doublePoints: return .circle
        }
    }
    
    var color: SKColor {
        switch self {
        case .shield: return .cyan
        case .slowTime: return .yellow
        case .speedBoost: return .orange
        case .magnet: return .purple
        case .doublePoints: return .systemGreen
        }
    }
}

extension Notification.Name {
    static let speedBoostActivated = Notification.Name("speedBoostActivated")
    static let speedBoostDeactivated = Notification.Name("speedBoostDeactivated")
}
