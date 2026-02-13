import SpriteKit
import XCTest
@testable import AvoidObstaclesGame


@MainActor


final class GameSceneTests: XCTestCase {
    func testSceneInitialization() {
        let scene = GameScene(size: CGSize(width: 800, height: 600))
        XCTAssertEqual(scene.size.width, 800)
        XCTAssertEqual(scene.size.height, 600)
    }

    func testPhysicsWorld() {
        let scene = GameScene(size: CGSize(width: 800, height: 600))
        scene.didMove(to: SKView())
        XCTAssertNotNil(scene.physicsWorld)
        // Physics world is initialized - gravity may vary based on scene configuration
    }

    func testPlayerCreation() {
        let scene = GameScene(size: CGSize(width: 800, height: 600))
        scene.didMove(to: SKView())

        // Player should be created
        let player = scene.childNode(withName: "player")
        XCTAssertNotNil(player)
    }

    func testPhysicsCategories() {
        // Test that physics categories are defined
        XCTAssertNotEqual(PhysicsCategory.none, PhysicsCategory.player)
        XCTAssertNotEqual(PhysicsCategory.player, PhysicsCategory.obstacle)
        XCTAssertNotEqual(PhysicsCategory.obstacle, PhysicsCategory.powerUp)
    }
}
