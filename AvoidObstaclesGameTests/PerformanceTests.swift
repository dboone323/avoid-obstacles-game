//
// PerformanceTests.swift
// AvoidObstaclesGameTests
//

import SpriteKit
import XCTest

@testable import AvoidObstaclesGameCore

@MainActor
final class PerformanceTests: XCTestCase {
    func testNodePoolingPerformance() {
        let optimizer = PerformanceOptimizer.shared

        measure {
            for _ in 0..<1000 {
                let node = optimizer.getNode(type: "perf") { SKNode() }
                optimizer.returnNode(node, type: "perf")
            }
        }
    }

    func testAssetCacheLookupPerformance() {
        let cache = AssetCache.shared
        cache.preloadAssets()

        measure {
            for _ in 0..<500 {
                _ = cache.texture(named: "player")
                _ = cache.sound(named: "collision")
            }
        }
    }

    func testComboCalculationPerformance() {
        let combo = ComboSystem.shared
        combo.resetStats()

        measure {
            for i in 0..<2000 {
                combo.recordDodge(currentTime: Double(i) * 0.1)
                _ = combo.calculatePoints()
                _ = combo.getMultiplier()
            }
        }
    }

    func testGameSceneUpdatePerformance() {
        let scene = GameScene(size: CGSize(width: 375, height: 667))

        measure {
            for frame in 0..<1000 {
                scene.update(Double(frame) / 60.0)
            }
        }
    }

    func testObstacleManagerPowerUpSpawnPerformance() {
        let scene = SKScene(size: CGSize(width: 375, height: 667))
        let manager = ObstacleManager(scene: scene)

        measure {
            for _ in 0..<250 {
                manager.spawnPowerUp()
                manager.updateObstacles()
            }
            manager.removeAllObstacles()
        }
    }

    func testCollisionIntersectionPerformance() {
        let playerNode = SKSpriteNode(color: .blue, size: CGSize(width: 30, height: 30))
        playerNode.position = CGPoint(x: 200, y: 300)

        let obstacles: [SKSpriteNode] = (0..<120).map { index in
            let node = SKSpriteNode(color: .red, size: CGSize(width: 30, height: 60))
            node.position = CGPoint(x: CGFloat(index) * 5.0, y: 300)
            return node
        }

        measure {
            for obstacle in obstacles {
                _ = playerNode.frame.intersects(obstacle.frame)
            }
        }
    }

    func testAdaptiveDifficultyPerformance() {
        let ai = AdaptiveDifficultyAI.shared
        let baseLevel = GameConfiguration.Difficulty.default.levels[0]

        measure {
            for score in stride(from: 0, to: 10_000, by: 25) {
                ai.recordPerformance(
                    score: score,
                    survivalTime: TimeInterval((score % 120) + 10),
                    collisions: score % 5
                )
                _ = ai.getDifficultyMultiplier()
                _ = ai.getAdjustedDifficulty(base: baseLevel)
            }
        }
    }

    func testProceduralLevelGenerationPerformance() {
        let generator = ProceduralLevelGenerator.shared

        measure {
            for difficulty in 0..<100 {
                _ = generator.generateLevel(difficulty: difficulty % 6, seed: difficulty)
            }
        }
    }

    func testHighScorePersistencePerformance() {
        let manager = HighScoreManager.shared
        manager.clearHighScores()

        measure {
            for i in 0..<500 {
                _ = manager.addScore(i * 100, playerName: "Player")
            }
        }
    }

    func testAchievementUpdatePerformance() {
        let manager = AchievementManager.shared

        measure {
            for i in 0..<250 {
                manager.updateProgress(for: .scoreReached(score: i * 25))
                manager.updateProgress(for: .powerUpCollected)
            }
        }
    }

    func testAudioPlaybackDispatchPerformance() {
        let audio = AudioManager.shared

        measure {
            for _ in 0..<200 {
                audio.playSound(.collision)
                audio.playSound(.powerup)
                audio.playSound(.levelup)
            }
        }
    }

    func testGameCenterSubmissionCallPerformance() {
        let gameCenter = GameCenterManager()

        measure {
            for score in 1000..<1050 {
                gameCenter.submitScore(score: score)
            }
        }
    }

    func testPerformanceStatsReadPerformance() {
        let manager = PerformanceManager.shared

        measure {
            for _ in 0..<500 {
                _ = manager.getRecommendedPoolSizes()
                _ = manager.getPerformanceStats()
            }
        }
    }
}
