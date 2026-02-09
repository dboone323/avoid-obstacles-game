//
// PerformanceTests.swift
// AvoidObstaclesGameTests
//

import SpriteKit
import XCTest
@testable import AvoidObstaclesGame

class PerformanceTests: XCTestCase {
    func testNodePoolingPerformance() {
        let optimizer = PerformanceOptimizer.shared

        measure {
            for _ in 0..<100 {
                let node = optimizer.getNode(type: "test") {
                    SKNode()
                }
                optimizer.returnNode(node, type: "test")
            }
        }
    }

    func testAssetCachePerformance() {
        let cache = AssetCache.shared
        cache.preloadAssets()

        measure {
            for _ in 0..<100 {
                _ = cache.texture(named: "player")
                _ = cache.sound(named: "collision")
            }
        }
    }

    func testComboCalculationPerformance() {
        let combo = ComboSystem.shared

        measure {
            for i in 0..<1000 {
                combo.recordDodge(currentTime: Double(i) * 0.1)
                _ = combo.calculatePoints()
            }
        }
    }
}
