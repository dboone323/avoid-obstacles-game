import GameKit
import SpriteKit

/// Dedicated physics contact delegate for GameScene
class PhysicsContactDelegate: NSObject, SKPhysicsContactDelegate {

    weak var scene: SKScene?
    weak var gameStateManager: GameStateManager?
    weak var effectsManager: EffectsManager?
    weak var playerNode: SKNode?

    init(scene: SKScene, gameStateManager: GameStateManager, effectsManager: EffectsManager) {
        self.scene = scene
        self.gameStateManager = gameStateManager
        self.effectsManager = effectsManager
        super.init()
    }

    // MARK: - SKPhysicsContactDelegate

    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB

        // Determine which body is what
        let maskA = bodyA.categoryBitMask
        let maskB = bodyB.categoryBitMask

        // Player collisions
        if hasContact(
            mask1: maskA,
            mask2: maskB,
            category1: PhysicsCategory.player,
            category2: PhysicsCategory.obstacle
        ) {
            handlePlayerObstacleCollision(contact)
        } else if hasContact(
            mask1: maskA,
            mask2: maskB,
            category1: PhysicsCategory.player,
            category2: PhysicsCategory.powerUp
        ) {
            handlePlayerPowerUpCollision(contact)
        } else if hasContact(
            mask1: maskA,
            mask2: maskB,
            category1: PhysicsCategory.player,
            category2: PhysicsCategory.boundary
        ) {
            handlePlayerBoundaryCollision(contact)
        }
    }

    // MARK: - Collision Handlers

    private func handlePlayerObstacleCollision(_ contact: SKPhysicsContact) {
        guard gameStateManager?.isGameActive() == true else { return }

        let obstacleNode: SKNode
        let playerHitNode: SKNode
        
        if contact.bodyA.categoryBitMask == PhysicsCategory.obstacle {
            guard let obstacle = contact.bodyA.node, let player = contact.bodyB.node else { return }
            obstacleNode = obstacle
            playerHitNode = player
        } else {
            guard let obstacle = contact.bodyB.node, let player = contact.bodyA.node else { return }
            obstacleNode = obstacle
            playerHitNode = player
        }
        
        playerNode = playerHitNode

        // Create explosion effect
        effectsManager?.createExplosion(at: obstacleNode.position)

        guard gameStateManager?.isGameActive() == true else { return }

        // Play sound
        AudioManager.shared.playCollision()

        // Haptic feedback
        HapticFeedbackManager.shared.heavy()

        // Game over
        gameStateManager?.endGame()

        // Post notification
        NotificationCenter.default.post(name: .gameOver, object: nil)
    }

    private func handlePlayerPowerUpCollision(_ contact: SKPhysicsContact) {
        guard gameStateManager?.isGameActive() == true else { return }

        let powerUpNode: SKNode
        if contact.bodyA.categoryBitMask == PhysicsCategory.powerUp {
            guard let node = contact.bodyA.node else { return }
            powerUpNode = node
        } else {
            guard let node = contact.bodyB.node else { return }
            powerUpNode = node
        }

        // Play sound
        AudioManager.shared.playPowerUp()

        // Haptic feedback
        HapticFeedbackManager.shared.medium()

        // Determine power-up type from node name
        if let powerUpType = getPowerUpType(from: powerUpNode.name) {
            // Activate power-up
            NotificationCenter.default.post(
                name: .powerUpCollected,
                object: powerUpType
            )

            // Visual effect
            effectsManager?.createPowerUpCollectionEffect(at: powerUpNode.position)

            // Remove power-up
            powerUpNode.removeFromParent()

            // Haptic feedback already handled above

            // Add score bonus
            gameStateManager?.addScore(50)
        }
    }

    private func handlePlayerBoundaryCollision(_ contact: SKPhysicsContact) {
        // Keep player in bounds
        if let player = playerNode {
            let point = contact.contactPoint

            // Determine which boundary
            let sceneSize = scene?.size ?? .zero

            if point.x <= 50 || point.x >= sceneSize.width - 50 {
                // Side boundary
                player.physicsBody?.velocity.dx = 0
            }

            if point.y <= 50 || point.y >= sceneSize.height - 50 {
                // Top/bottom boundary
                player.physicsBody?.velocity.dy = 0
            }
        }
    }

    // MARK: - Helpers

    private func hasContact(mask1: UInt32, mask2: UInt32, category1: UInt32, category2: UInt32) -> Bool {
        (mask1 == category1 && mask2 == category2) ||
            (mask1 == category2 && mask2 == category1)
    }

    private func getPowerUpType(from nodeName: String?) -> PowerUpType? {
        guard let name = nodeName else { return nil }

        if name.contains("shield") { return .shield }
        if name.contains("slowTime") { return .slowTime }
        if name.contains("speedBoost") { return .speedBoost }

        return nil
    }
}

// Notification extensions
extension Notification.Name {
    static let gameOver = Notification.Name("gameOver")
    static let powerUpCollected = Notification.Name("powerUpCollected")
}
