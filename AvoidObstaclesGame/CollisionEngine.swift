//
// CollisionEngine.swift
// AvoidObstaclesGame
//

import SpriteKit

class CollisionEngine {
    static let shared = CollisionEngine()
    
    enum CollisionMode {
        case standard
        case pixelPerfect
    }
    
    private var mode: CollisionMode = .standard
    
    func setMode(_ mode: CollisionMode) {
        self.mode = mode
    }
    
    func checkCollision(between node1: SKNode, and node2: SKNode) -> Bool {
        switch mode {
        case .standard:
            return standardCollision(node1, node2)
        case .pixelPerfect:
            return pixelPerfectCollision(node1, node2)
        }
    }
    
    private func standardCollision(_ node1: SKNode, _ node2: SKNode) -> Bool {
        return node1.frame.intersects(node2.frame)
    }
    
    private func pixelPerfectCollision(_ node1: SKNode, _ node2: SKNode) -> Bool {
        guard let sprite1 = node1 as? SKSpriteNode,
              let sprite2 = node2 as? SKSpriteNode else {
            return standardCollision(node1, node2)
        }
        
        // Check bounding box first for performance
        guard sprite1.frame.intersects(sprite2.frame) else {
            return false
        }
        
        // Calculate overlap rectangle
        let intersection = sprite1.frame.intersection(sprite2.frame)
        
        // For pixel-perfect, we'd check alpha channels
        // Simplified: if overlap is > 50% of smaller node, collision
        let size1 = sprite1.frame.width * sprite1.frame.height
        let size2 = sprite2.frame.width * sprite2.frame.height
        let overlapSize = intersection.width * intersection.height
        let minSize = min(size1, size2)
        
        return overlapSize > minSize * 0.3
    }
}
