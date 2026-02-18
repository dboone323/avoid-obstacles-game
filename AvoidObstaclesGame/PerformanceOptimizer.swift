//
// PerformanceOptimizer.swift
// AvoidObstaclesGame
//

import SpriteKit

@MainActor
class PerformanceOptimizer {
    @MainActor static let shared = PerformanceOptimizer()

    private var nodePool: [String: [SKNode]] = [:]
    private let maxPoolSize = 50
    private var frameRateMonitor: FrameRateMonitor?

    func getNode(type: String, creator: () -> SKNode) -> SKNode {
        if var pool = nodePool[type], !pool.isEmpty {
            return pool.removeLast()
        }
        return creator()
    }

    func returnNode(_ node: SKNode, type: String) {
        node.removeFromParent()
        node.removeAllActions()

        if var pool = nodePool[type], pool.count < maxPoolSize {
            pool.append(node)
            nodePool[type] = pool
        } else if nodePool[type] == nil {
            nodePool[type] = [node]
        }
    }

    func optimizeScene(_ scene: SKScene) {
        // Remove off-screen nodes
        scene.enumerateChildNodes(withName: "//obstacle") { node, _ in
            if node.position.y < -100 {
                node.removeFromParent()
            }
        }

        // Batch sprite rendering
        if let view = scene.view {
            view.ignoresSiblingOrder = true
            view.shouldCullNonVisibleNodes = true
        }
    }

    func startMonitoring(scene: SKScene) {
        frameRateMonitor = FrameRateMonitor(scene: scene)
    }
}

@MainActor
class FrameRateMonitor {
    private weak var scene: SKScene?
    private var lastUpdate: TimeInterval = 0
    private var frameCount = 0
    private var currentFPS: Double = 60.0

    init(scene: SKScene) {
        self.scene = scene
    }

    func update(_ currentTime: TimeInterval) {
        if lastUpdate == 0 {
            lastUpdate = currentTime
            return
        }

        frameCount += 1
        let delta = currentTime - lastUpdate

        if delta >= 1.0 {
            currentFPS = Double(frameCount) / delta
            frameCount = 0
            lastUpdate = currentTime

            if currentFPS < 55 {
                adjustQuality()
            }
        }
    }

    private func adjustQuality() {
        // Reduce particle count or quality if FPS drops
        scene?.enumerateChildNodes(withName: "//particle") { node, _ in
            if let emitter = node as? SKEmitterNode {
                emitter.particleBirthRate *= 0.7
            }
        }
    }
}
