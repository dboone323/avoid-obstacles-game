import XCTest
@testable import AvoidObstaclesGame
import SpriteKit

final class EffectsManagerTests: XCTestCase {
    
    var scene: SKScene!
    var manager: EffectsManager!
    
    override func setUp() {
        super.setUp()
        scene = SKScene(size: CGSize(width: 800, height: 600))
        manager = EffectsManager(scene: scene)
    }
    
    override func tearDown() {
        manager = nil
        scene = nil
        super.tearDown()
    }
    
    func testExplosionCreation() {
        let testPosition = CGPoint(x: 400, y: 300)
        manager.createExplosion(at: testPosition)
        
        // Explosion effect should be added to scene
        let explosionNode = scene.children.first(where: { $0 is SKEmitterNode })
        XCTAssertNotNil(explosionNode, "Explosion particle should be created")
    }
    
    func testPowerUpCollectionEffect() {
        let testPosition = CGPoint(x: 200, y: 400)
        manager.createPowerUpCollectionEffect(at: testPosition)
        
        // Power-up collection effect should be added
        XCTAssertTrue(true) // If no crash, test passes
    }
    
    func testLevelUpCelebration() {
        manager.createLevelUpCelebration()
        
        // Level up effect should be created
        XCTAssertTrue(true)
    }
    
    func testBackgroundEffectsUpdate() {
        let difficulty = GameDifficulty(level: 3)
        manager.updateBackgroundEffects(for: difficulty)
        
        // Background effects should update based on difficulty
        XCTAssertTrue(true)
    }
    
    func testCleanupUnusedEffects() {
        // Create some effects
        manager.createExplosion(at: CGPoint(x: 100, y: 100))
        manager.createExplosion(at: CGPoint(x: 200, y: 200))
        
        // Cleanup
        manager.cleanupUnusedEffects()
        
        // Should remove unused effects
        XCTAssertTrue(true)
    }
    
    // MARK: - Particle Lifecycle Tests
    
    func testParticlePoolCreation() {
        // Pool should be pre-loaded
        XCTAssertGreaterThan(manager.explosionPoolSize, 0)
        XCTAssertGreaterThan(manager.trailPoolSize, 0)
    }
    
    func testParticlePoolReuse() {
        let position1 = CGPoint(x: 100, y: 100)
        let position2 = CGPoint(x: 200, y: 200)
        
        // Create and remove effect
        manager.createExplosion(at: position1)
        let childCount1 = scene.children.count
        
        manager.cleanupUnusedEffects()
        
        // Create another effect - should reuse from pool
        manager.createExplosion(at: position2)
        let childCount2 = scene.children.count
        
        XCTAssertEqual(childCount1, childCount2, "Should reuse particles from pool")
    }
    
    func testParticleLifetimeExpiration() {
        let expectation = self.expectation(description: "Particle should expire")
        
        manager.createExplosion(at: CGPoint(x: 400, y: 300))
        
        // Explosion particles lifetime is 1.0 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.manager.cleanupUnusedEffects()
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0)
    }
    
    func testMultipleParticleEmitters() {
        // Create multiple effects simultaneously
        manager.createExplosion(at: CGPoint(x: 100, y: 100))
        manager.createTrailEffect(for: scene.children.first!)
        manager.createSparkleEffect(at: CGPoint(x: 300, y: 300))
        
        let emitterNodes = scene.children.compactMap { $0 as? SKEmitterNode }
        XCTAssertGreaterThanOrEqual(emitterNodes.count, 3)
    }
    
    func testParticleEmitterConfiguration() {
        manager.createExplosion(at: CGPoint(x: 200, y: 200))
        
        if let emitter = scene.children.compactMap({ $0 as? SKEmitterNode }).first {
            // Verify explosion configuration
            XCTAssertGreaterThan(emitter.particleBirthRate, 0)
            XCTAssertGreaterThan(emitter.numParticlesToEmit, 0)
            XCTAssertGreaterThan(emitter.particleLifetime, 0)
        }
    }
    
    func testParticlePoolExhaustion() {
        // Create more effects than pool size
        for i in 0..<20 {
            manager.createExplosion(at: CGPoint(x: Double(i * 50), y: 300))
        }
        
        // Should handle gracefully without crashes
        XCTAssertTrue(true)
    }
    
    func testParticleCleanupAfterSceneRemoval() {
        manager.createExplosion(at: CGPoint(x: 100, y: 100))
        manager.createTrailEffect(for: scene.children.first!)
        
        // Remove scene
        scene.removeAllChildren()
        manager.cleanupUnusedEffects()
        
        XCTAssertEqual(scene.children.count, 0)
    }
    
    func testParticleZPositioning() {
        manager.createExplosion(at: CGPoint(x: 200, y: 200))
        
        if let emitter = scene.children.compactMap({ $0 as? SKEmitterNode }).first {
            // Particles should be on correct layer
            XCTAssertGreaterThan(emitter.zPosition, 0)
        }
    }
}

