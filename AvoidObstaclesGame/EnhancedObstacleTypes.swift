//
// EnhancedObstacleTypes.swift
// AvoidObstaclesGame
//

import SpriteKit

enum EnhancedObstacleType: CaseIterable {
    case basic
    case spinning
    case zigzag
    case splitting
    case phasing

    var points: Int {
        switch self {
        case .basic: return 1
        case .spinning: return 2
        case .zigzag: return 3
        case .splitting: return 4
        case .phasing: return 5
        }
    }

    func createObstacle(size: CGSize, color: PlatformColor) -> SKSpriteNode {
        let obstacle = SKSpriteNode(color: color, size: size)
        obstacle.name = "obstacle"

        switch self {
        case .basic:
            break

        case .spinning:
            let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 2.0)
            obstacle.run(SKAction.repeatForever(rotate))

        case .zigzag:
            let moveRight = SKAction.moveBy(x: 50, y: 0, duration: 0.5)
            let moveLeft = SKAction.moveBy(x: -50, y: 0, duration: 0.5)
            let sequence = SKAction.sequence([moveRight, moveLeft])
            obstacle.run(SKAction.repeatForever(sequence))

        case .splitting:
            obstacle.userData = ["canSplit": true]

        case .phasing:
            let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 1.0)
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 1.0)
            let sequence = SKAction.sequence([fadeOut, fadeIn])
            obstacle.run(SKAction.repeatForever(sequence))
        }

        return obstacle
    }
}

extension ObstacleManager {
    func spawnEnhancedObstacle(type: EnhancedObstacleType, difficulty: GameDifficulty) {
        guard let scene else { return }

        let config = GameConfiguration.load()
        let theme = ThemeManager.shared.currentTheme

        let obstacle = type.createObstacle(
            size: config.obstacle.minSize,
            color: theme.obstacleColor
        )

        let randomX = CGFloat.random(in: 50 ... (scene.size.width - 50))
        obstacle.position = CGPoint(x: randomX, y: scene.size.height + 50)
        obstacle.zPosition = 50

        scene.addChild(obstacle)

        let moveAction = SKAction.moveBy(
            x: 0,
            y: -(scene.size.height + 100),
            duration: TimeInterval(scene.size.height / difficulty.obstacleSpeed)
        )

        obstacle.run(SKAction.sequence([
            moveAction,
            SKAction.removeFromParent()
        ]))
    }
}
