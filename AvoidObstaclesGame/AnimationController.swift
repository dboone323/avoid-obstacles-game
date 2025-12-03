//
// AnimationController.swift
// AvoidObstaclesGame
//

import SpriteKit

class AnimationController {
    static let shared = AnimationController()

    private init() {}

    func animateScoreIncrease(on label: SKLabelNode, from oldScore: Int, to newScore: Int) {
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.15)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.15)
        let sequence = SKAction.sequence([scaleUp, scaleDown])

        label.run(sequence)

        // Animate number counting
        let duration = 0.3
        let steps = 10
        let increment = (newScore - oldScore) / steps

        for i in 0...steps {
            let delay = duration * Double(i) / Double(steps)
            let action = SKAction.run {
                label.text = "Score: \(oldScore + increment * i)"
            }
            label.run(SKAction.sequence([SKAction.wait(forDuration: delay), action]))
        }
    }

    func animatePowerUpActivation(on node: SKNode) {
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2),
        ])
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 0.4)
        let group = SKAction.group([pulse, rotate])

        node.run(group)
    }

    func animateComboPopup(score: Int, at position: CGPoint, in scene: SKScene) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "+\(score) COMBO!"
        label.fontSize = 24
        label.fontColor = .yellow
        label.position = position
        label.zPosition = 100

        scene.addChild(label)

        let moveUp = SKAction.moveBy(x: 0, y: 100, duration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let scale = SKAction.scale(to: 1.5, duration: 1.0)
        let group = SKAction.group([moveUp, fadeOut, scale])

        label.run(SKAction.sequence([group, SKAction.removeFromParent()]))
    }

    func animateObstacleDestruction(obstacle: SKNode) {
        let shrink = SKAction.scale(to: 0, duration: 0.3)
        let rotate = SKAction.rotate(byAngle: .pi * 4, duration: 0.3)
        let group = SKAction.group([shrink, rotate])

        obstacle.run(SKAction.sequence([group, SKAction.removeFromParent()]))
    }
}
