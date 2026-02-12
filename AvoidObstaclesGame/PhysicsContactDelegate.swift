import GameKit
import SpriteKit

/// Dedicated physics contact delegate for GameScene
@MainActor
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

    nonisolated func didBegin(_ contact: SKPhysicsContact) {
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
            // Extract contact data before sending to main actor
            let contactPoint = contact.contactPoint
            let obstacleNode: SKNode?
            let playerHitNode: SKNode?

            if contact.bodyA.categoryBitMask == PhysicsCategory.obstacle {
                obstacleNode = contact.bodyA.node
                playerHitNode = contact.bodyB.node
            } else {
                obstacleNode = contact.bodyB.node
                playerHitNode = contact.bodyA.node
            }

            Task { @MainActor in
                self.handlePlayerObstacleCollision(
                    contactPoint: contactPoint,
                    obstacleNode: obstacleNode,
                    playerNode: playerHitNode
                )
            }
        } else if hasContact(
            mask1: maskA,
            mask2: maskB,
            category1: PhysicsCategory.player,
            category2: PhysicsCategory.powerUp
        ) {
            // Extract contact data before sending to main actor
            let contactPoint = contact.contactPoint
            let powerUpNode: SKNode? = if contact.bodyA.categoryBitMask == PhysicsCategory.powerUp {
                contact.bodyA.node
            } else {
                contact.bodyB.node
            }

            Task { @MainActor in
                self.handlePlayerPowerUpCollision(contactPoint: contactPoint, powerUpNode: powerUpNode)
            }
        } else if hasContact(
            mask1: maskA,
            mask2: maskB,
            category1: PhysicsCategory.player,
            category2: PhysicsCategory.boundary
        ) {
            // Extract contact data before sending to main actor
            let contactPoint = contact.contactPoint

            Task { @MainActor in
                self.handlePlayerBoundaryCollision(contactPoint: contactPoint)
            }
        }
    }

    // MARK: - Collision Handlers

    @MainActor
    private func handlePlayerObstacleCollision(contactPoint: CGPoint, obstacleNode: SKNode?, playerNode: SKNode?) {
        guard gameStateManager?.isGameActive() == true else { return }
        guard let obstacleNode, let playerNode else { return }

        self.playerNode = playerNode

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

    @MainActor
    private func handlePlayerPowerUpCollision(contactPoint: CGPoint, powerUpNode: SKNode?) {
        guard gameStateManager?.isGameActive() == true else { return }
        guard let powerUpNode else { return }

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

    @MainActor
    private func handlePlayerBoundaryCollision(contactPoint: CGPoint) {
        // Keep player in bounds
        if let player = playerNode {
            // Determine which boundary
            let sceneSize = scene?.size ?? .zero

            if contactPoint.x <= 50 || contactPoint.x >= sceneSize.width - 50 {
                // Side boundary
                player.physicsBody?.velocity.dx = 0
            }

            if contactPoint.y <= 50 || contactPoint.y >= sceneSize.height - 50 {
                // Top/bottom boundary
                player.physicsBody?.velocity.dy = 0
            }
        }
    }

    // MARK: - Helpers

    private nonisolated func hasContact(mask1: UInt32, mask2: UInt32, category1: UInt32, category2: UInt32) -> Bool {
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

/// Notification extensions
extension Notification.Name {
    static let gameOver = Notification.Name("gameOver")
    static let powerUpCollected = Notification.Name("powerUpCollected")
}
