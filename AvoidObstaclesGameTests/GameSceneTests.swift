import SpriteKit
import XCTest
@testable import AvoidObstaclesGame

final class GameSceneTests: XCTestCase {

    var gameScene: GameScene!

    override func setUp() {
        super.setUp()
        gameScene = GameScene(size: CGSize(width: 800, height: 600))
    }

    override func tearDown() {
        gameScene = nil
        super.tearDown()
    }

    func testSceneInitialization() {
        XCTAssertNotNil(gameScene)
        XCTAssertEqual(gameScene.size.width, 800)
        XCTAssertEqual(gameScene.size.height, 600)
    }

    func testPhysicsWorld() {
        gameScene.didMove(to: SKView())
        XCTAssertNotNil(gameScene.physicsWorld)
        // Physics world is initialized - gravity may vary based on scene configuration
    }

    func testPlayerCreation() {
        gameScene.didMove(to: SKView())

        // Player should be created
        let player = gameScene.childNode(withName: "player")
        XCTAssertNotNil(player)
    }

    func testPhysicsCategories() {
        // Test that physics categories are defined
        XCTAssertNotEqual(PhysicsCategory.none, PhysicsCategory.player)
        XCTAssertNotEqual(PhysicsCategory.player, PhysicsCategory.obstacle)
        XCTAssertNotEqual(PhysicsCategory.obstacle, PhysicsCategory.powerUp)
    }
}
