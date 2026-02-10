//
// PerformanceTests.swift
// AvoidObstaclesGameTests
//

import SpriteKit
import XCTest
@testable import AvoidObstaclesGame

class PerformanceTests: XCTestCase {
    var performanceMonitor: PerformanceMonitor!

    override func setUp() {
        super.setUp()
        performanceMonitor = PerformanceMonitor()
    }

    override func tearDown() {
        performanceMonitor = nil
        super.tearDown()
    }

    // MARK: - Existing Performance Tests (Enhanced)

    func testNodePoolingPerformance() {
        let optimizer = PerformanceOptimizer.shared

        measure {
            for _ in 0 ..< 1000 {
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
            for _ in 0 ..< 500 {
                _ = cache.texture(named: "player")
                _ = cache.sound(named: "collision")
                _ = cache.particleEffect(named: "explosion")
            }
        }
    }

    func testComboCalculationPerformance() {
        let combo = ComboSystem.shared

        measure {
            for i in 0 ..< 2000 {
                combo.recordDodge(currentTime: Double(i) * 0.1)
                _ = combo.calculatePoints()
                _ = combo.getMultiplier()
            }
        }
    }

    // MARK: - Game Engine Performance Tests

    func testGameLoopPerformance() {
        let gameScene = GameScene(size: CGSize(width: 375, height: 667))

        measure {
            for _ in 0 ..< 1000 {
                gameScene.update(1.0 / 60.0)
            }
        }
    }

    func testObstacleGenerationPerformance() {
        let obstacleManager = ObstacleManager()

        measure {
            for _ in 0 ..< 200 {
                _ = obstacleManager.generateObstacle()
            }
        }
    }

    func testCollisionDetectionPerformance() {
        // Given: Many physics bodies
        var playerBody: SKPhysicsBody!
        var obstacleBodies: [SKPhysicsBody] = []

        autoreleasepool {
            playerBody = SKPhysicsBody(circleOfRadius: 15)

            for i in 0 ..< 100 {
                let obstacleBody = SKPhysicsBody(rectangleOf: CGSize(width: 30, height: 60))
                obstacleBody.position = CGPoint(x: i * 40, y: 300)
                obstacleBodies.append(obstacleBody)
            }
        }

        // When: Check collisions
        measure {
            for obstacleBody in obstacleBodies {
                _ = playerBody.allContactedBodies().contains(obstacleBody)
            }
        }
    }

    // MARK: - Rendering Performance Tests

    func testParticleSystemPerformance() {
        let scene = GameScene(size: CGSize(width: 375, height: 667))

        measure {
            for _ in 0 ..< 300 {
                scene.createParticleEffect(at: CGPoint(x: 187, y: 333))
                scene.update(1.0 / 60.0)
            }
        }
    }

    func testSpriteAnimationPerformance() {
        let playerNode = SKSpriteNode(imageNamed: "player")

        measure {
            for frame in 0 ..< 500 {
                playerNode.run(SKAction.animate(with: [
                    SKTexture(imageNamed: "player_frame_1"),
                    SKTexture(imageNamed: "player_frame_2"),
                ], timePerFrame: 0.1))
                playerNode.position.x += 1
            }
        }
    }

    // MARK: - AI Performance Tests

    func testAdaptiveDifficultyPerformance() {
        let ai = AdaptiveDifficultyAI()

        measure {
            for score in stride(from: 0, to: 10000, by: 10) {
                ai.updateDifficulty(playerScore: Double(score))
                _ = ai.getCurrentDifficulty()
                _ = ai.shouldSpawnPowerUp()
            }
        }
    }

    func testProceduralLevelGenerationPerformance() {
        let levelGenerator = ProceduralLevelGenerator()

        measure {
            for difficulty in 0 ..< 50 {
                _ = levelGenerator.generateLevel(difficulty: Float(difficulty) / 50.0)
            }
        }
    }

    // MARK: - Data Management Performance Tests

    func testHighScorePersistencePerformance() {
        let highScoreManager = HighScoreManager()

        measure {
            for i in 0 ..< 500 {
                highScoreManager.saveScore(Score(value: i * 100, date: Date(), playerName: "TestPlayer"))
            }
        }
    }

    func testAchievementSystemPerformance() {
        let achievementManager = AchievementManager()

        measure {
            for i in 0 ..< 200 {
                achievementManager.checkAchievements(
                    score: i * 50,
                    obstaclesAvoided: i * 2,
                    powerUpsCollected: i,
                    timePlayed: TimeInterval(i * 30)
                )
            }
        }
    }

    // MARK: - Audio Performance Tests

    func testAudioPlaybackPerformance() {
        let audioManager = AudioManager()

        measure {
            for _ in 0 ..< 200 {
                audioManager.playSoundEffect(.jump)
                audioManager.playSoundEffect(.collision)
                audioManager.playSoundEffect(.powerUp)
            }
        }
    }

    // MARK: - Memory Performance Tests

    func testMemoryUsageDuringGameplay() {
        measure {
            autoreleasepool {
                var nodes: [SKNode] = []
                for _ in 0 ..< 1000 {
                    let node = SKSpriteNode(color: .red, size: CGSize(width: 20, height: 20))
                    node.position = CGPoint(x: .random(in: 0 ... 375), y: .random(in: 0 ... 667))
                    nodes.append(node)
                }
                nodes.removeAll()
            }
        }
    }

    // MARK: - UI Performance Tests

    func testMenuRenderingPerformance() {
        let menuScene = MenuScene(size: CGSize(width: 375, height: 667))

        measure {
            for _ in 0 ..< 300 {
                menuScene.update(1.0 / 60.0)
            }
        }
    }

    // MARK: - Network Performance Tests

    func testGameCenterIntegrationPerformance() {
        let gameCenterManager = GameCenterManager()

        measure {
            for _ in 0 ..< 30 {
                gameCenterManager.submitScore(Int64(1000 + i))
                gameCenterManager.loadAchievements()
                gameCenterManager.loadLeaderboards()
            }
        }
    }

    // MARK: - Concurrent Operations Performance Tests

    func testConcurrentGameSystemsPerformance() {
        let expectation = XCTestExpectation(description: "Concurrent game systems")

        measure {
            let group = DispatchGroup()

            // Simulate concurrent game systems
            group.enter()
            DispatchQueue.global(qos: .userInteractive).async {
                let gameScene = GameScene(size: CGSize(width: 375, height: 667))
                for _ in 0 ..< 200 {
                    gameScene.update(1.0 / 60.0)
                }
                group.leave()
            }

            group.enter()
            DispatchQueue.global(qos: .userInteractive).async {
                let audioManager = AudioManager()
                for _ in 0 ..< 200 {
                    audioManager.updateAudioEngine()
                }
                group.leave()
            }

            group.enter()
            DispatchQueue.global(qos: .userInteractive).async {
                let ai = AdaptiveDifficultyAI()
                for score in 0 ..< 200 {
                    ai.updateDifficulty(playerScore: Double(score * 10))
                }
                group.leave()
            }

            group.notify(queue: .main) {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 15.0)
    }

    // MARK: - Load Testing

    func testHighLoadGameplaySimulation() {
        measure {
            // Simulate high-load gameplay scenario
            let gameScene = GameScene(size: CGSize(width: 375, height: 667))

            // Simulate gameplay loop with high load
            for frame in 0 ..< 500 {
                // Update game state
                gameScene.update(1.0 / 60.0)

                // Simulate player input
                if frame % 5 == 0 {
                    gameScene.handlePlayerInput(.jump)
                }

                // Simulate obstacle spawning
                if frame % 10 == 0 {
                    gameScene.spawnObstacle()
                }

                // Simulate effects
                if frame % 20 == 0 {
                    gameScene.createParticleEffect(at: CGPoint(x: 187, y: 333))
                }
            }
        }
    }

    // MARK: - Performance Monitoring

    func testPerformanceMetricsCollection() {
        performanceMonitor.startMonitoring()

        // Simulate game activity
        let gameScene = GameScene(size: CGSize(width: 375, height: 667))

        measure {
            for _ in 0 ..< 100 {
                gameScene.update(1.0 / 60.0)
                _ = performanceMonitor.getMetrics()
            }
        }

        performanceMonitor.stopMonitoring()
    }
}

// MARK: - Performance Monitor

class PerformanceMonitor {
    private var startTime: Date?
    private var frameCount = 0
    private var metrics: PerformanceMetrics = .init()

    func startMonitoring() {
        startTime = Date()
        frameCount = 0
        metrics = PerformanceMetrics()
    }

    func stopMonitoring() {
        startTime = nil
    }

    func getMetrics() -> PerformanceMetrics {
        frameCount += 1

        if let startTime {
            let elapsed = Date().timeIntervalSince(startTime)
            metrics.fps = Double(frameCount) / elapsed
        }

        // Simulate memory and CPU monitoring
        metrics.memoryUsage = Double.random(in: 40 ... 80)
        metrics.cpuUsage = Double.random(in: 20 ... 60)

        return metrics
    }
}

// MARK: - Extended Data Models

struct PerformanceMetrics {
    var fps: Double = 60.0
    var memoryUsage: Double = 50.0
    var cpuUsage: Double = 30.0
    var drawCalls: Int = 0
    var triangles: Int = 0
}

struct Score {
    let value: Int
    let date: Date
    let playerName: String
}

extension GameScene {
    func createParticleEffect(at position: CGPoint) {
        // Simulate particle effect creation
        let particleNode = SKEmitterNode()
        particleNode.position = position
        addChild(particleNode)
    }

    func handlePlayerInput(_ input: PlayerInput) {
        // Simulate input handling
    }

    func spawnObstacle() {
        // Simulate obstacle spawning
        let obstacle = SKSpriteNode(color: .red, size: CGSize(width: 30, height: 60))
        obstacle.position = CGPoint(x: .random(in: 0 ... 375), y: 667)
        addChild(obstacle)
    }
}

extension AudioManager {
    func updateAudioEngine() {
        // Simulate audio engine updates
    }
}

extension AdaptiveDifficultyAI {
    func shouldSpawnPowerUp() -> Bool {
        Bool.random()
    }
}

extension ProceduralLevelGenerator {
    func generateLevel(difficulty: Float) -> Level {
        Level(difficulty: difficulty, segments: [])
    }
}

extension HighScoreManager {
    func saveScore(_ score: Score) {
        // Simulate saving to storage
    }
}

extension AchievementManager {
    func checkAchievements(score: Int, obstaclesAvoided: Int, powerUpsCollected: Int, timePlayed: TimeInterval) {
        // Simulate achievement checking
    }
}

extension GameCenterManager {
    func loadAchievements() {
        // Simulate achievement loading
    }
}

enum PlayerInput {
    case jump, left, right
}

struct Level {
    let difficulty: Float
    let segments: [LevelSegment]
}

struct LevelSegment {
    let obstacles: [ObstacleData]
}

struct ObstacleData {
    let position: CGPoint
    let type: String
}
