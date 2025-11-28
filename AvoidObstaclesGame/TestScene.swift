//
// TestScene.swift
// AvoidObstaclesGame
//
// Minimal test scene to verify SpriteKit rendering
//

import SpriteKit

public class TestScene: SKScene {
    override public func didMove(to view: SKView) {
        backgroundColor = .red
        
        let label = SKLabelNode(text: "TEST SCENE - If you see this, SpriteKit works!")
        label.fontSize = 24
        label.fontColor = .white
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(label)
        
        let circle = SKShapeNode(circleOfRadius: 50)
        circle.fillColor = .yellow
        circle.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100)
        addChild(circle)
        
        print("✅ TestScene.didMove called - Scene has \(children.count) children")
        print("✅ Scene size: \(size)")
        print("✅ View: \(view)")
    }
}
