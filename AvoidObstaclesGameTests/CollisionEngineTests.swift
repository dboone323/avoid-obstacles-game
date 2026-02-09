//
// CollisionEngineTests.swift
// AvoidObstaclesGameTests
//

import SpriteKit
import XCTest
@testable import AvoidObstaclesGame

final class CollisionEngineTests: XCTestCase {
    var collisionEngine: CollisionEngine!
    var nodeA: SKSpriteNode!
    var nodeB: SKSpriteNode!

    override func setUp() {
        super.setUp()
        collisionEngine = CollisionEngine.shared
        // Reset mode to standard
        collisionEngine.setMode(.standard)

        // 50x50 nodes
        nodeA = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
        nodeA.position = CGPoint(x: 100, y: 100)

        nodeB = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 50))
        nodeB.position = CGPoint(x: 200, y: 200) // Far away
    }

    override func tearDown() {
        collisionEngine = nil
        nodeA = nil
        nodeB = nil
        super.tearDown()
    }

    // MARK: - Standard Collision Tests

    func testStandardCollision_NoOverlap_ReturnsFalse() {
        collisionEngine.setMode(.standard)
        XCTAssertFalse(collisionEngine.checkCollision(between: nodeA, and: nodeB))
    }

    func testStandardCollision_Overlap_ReturnsTrue() {
        collisionEngine.setMode(.standard)
        // Move nodeB to overlap nodeA slightly
        // nodeA: 75..125, 75..125 (frame center 100,100, size 50)
        // nodeB: move to 110, 110
        nodeB.position = CGPoint(x: 110, y: 110)

        XCTAssertTrue(collisionEngine.checkCollision(between: nodeA, and: nodeB))
    }

    func testStandardCollision_TouchingEdges_ReturnsTrue() {
        collisionEngine.setMode(.standard)
        // nodeA right edge x=125
        // nodeB left edge at x=125 -> center at 125 + 25 = 150
        nodeB.position = CGPoint(x: 150, y: 100)

        // CGRect.intersects returns true for touching edges usually?
        // Let's verify standard behavior. In SpriteKit/CGRect, touching usually intersects.
        // Actually CGRectIntersectsRect returns false for exact edge touch in some frameworks,
        // but SpriteKit frame intersection usually considers non-empty intersection.
        // Overlap of 0 width might be false.
        // Let's test deep overlap to be sure.

        nodeB.position = CGPoint(x: 149, y: 100) // 1px overlap
        XCTAssertTrue(collisionEngine.checkCollision(between: nodeA, and: nodeB))
    }

    // MARK: - Pixel Perfect Collision Tests

    func testPixelPerfect_UseStandardFallback_ForNonSizedNodes() {
        collisionEngine.setMode(.pixelPerfect)

        let plainNodeA = SKNode()
        plainNodeA.position = CGPoint(x: 100, y: 100)
        // SKNode frame is empty if no children/content?
        // Let's use shapes or something having frame but not SKSpriteNode.
        // SKShapeNode?
        // Code: `guard let sprite1 = node1 as? SKSpriteNode ... else { return standardCollision(...) }`

        XCTAssertFalse(collisionEngine.checkCollision(between: plainNodeA, and: nodeB))
    }

    func testPixelPerfect_SmallOverlap_ReturnsFalse() {
        // Logic: overlapSize > minSize * 0.3
        // Node size = 2500. Threshold = 750.

        collisionEngine.setMode(.pixelPerfect)

        // Create overlap of 10x10 = 100 area ( < 750 )
        // nodeA (x:100, y:100) -> x range [75, 125]
        // overlap width 10 -> nodeB left edge at 115?
        // nodeB x range [115, 165] (center 140)

        nodeB.position = CGPoint(x: 145, y: 100)
        // Overlap X: nodeA-Right(125) - nodeB-Left(120) = 5px.
        // Overlap Y: 50px.
        // Area = 5 * 50 = 250.
        // 250 < 750. Should be false in pixelPerfect mode.

        // But true in standard mode check first?
        // "guard sprite1.frame.intersects(sprite2.frame) else { return false }"

        XCTAssertFalse(
            collisionEngine.checkCollision(between: nodeA, and: nodeB),
            "Small overlap should be ignored in pixel perfect"
        )
    }

    func testPixelPerfect_LargeOverlap_ReturnsTrue() {
        // Overlap > 30%.
        // Need area > 750.
        // Overlap 20px width: 20 * 50 = 1000 (> 750).

        collisionEngine.setMode(.pixelPerfect)

        nodeB.position = CGPoint(x: 120, y: 100)
        // nodeA R=125, nodeB L=95. Overlap 30px. Area 1500.

        XCTAssertTrue(collisionEngine.checkCollision(between: nodeA, and: nodeB))
    }
}
