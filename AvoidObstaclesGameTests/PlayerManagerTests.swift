import XCTest
@testable import AvoidObstaclesGame
import SpriteKit

final class PlayerManagerTests: XCTestCase {
    
    var scene: SKScene!
    var manager: PlayerManager!
    
    override func setUp() {
        super.setUp()
        scene = SKScene(size: CGSize(width: 800, height: 600))
        manager = PlayerManager(scene: scene)
    }
    
    override func tearDown() {
        manager = nil
        scene = nil
        super.tearDown()
    }
    
    func testPlayerCreation() {
        let testPosition = CGPoint(x: 400, y: 300)
        manager.createPlayer(at: testPosition)
        
        XCTAssertNotNil(manager.player)
        XCTAssertEqual(manager.player?.name, "player")
        XCTAssertEqual(manager.position, testPosition)
    }
    
    func testPlayerMovement() {
        manager.createPlayer(at: CGPoint(x: 400, y: 300))
        
        let targetPosition = CGPoint(x: 500, y: 300)
        manager.moveTo(targetPosition)
        
        // Player should have movement action
        XCTAssertTrue(manager.player?.action(forKey: "playerMovement") != nil)
    }
    
    func testPlayerPositionSetting() {
        manager.createPlayer(at: CGPoint(x: 400, y: 300))
        
        let newPosition = CGPoint(x: 200, y: 300)
        manager.setPosition(newPosition)
        
        XCTAssertEqual(manager.position, newPosition)
    }
    
    func testPlayerVisibility() {
        manager.createPlayer(at: CGPoint(x: 400, y: 300))
        
        manager.hide()
        XCTAssertTrue(manager.player?.isHidden == true)
        
        manager.show()
        XCTAssertFalse(manager.player?.isHidden == true)
    }
    
    func testPlayerReset() {
        manager.createPlayer(at: CGPoint(x: 400, y: 300))
        
        manager.hide()
        manager.reset()
        
        XCTAssertFalse(manager.player?.isHidden == true)
    }
    
    func testPowerUpEffects() {
        manager.createPlayer(at: CGPoint(x: 400, y: 300))
        
        manager.applyPowerUpEffect(.shield)
        XCTAssertNotNil(manager.player?.childNode(withName: "shield"))
        
        manager.removePowerUpEffects()
        XCTAssertNil(manager.player?.childNode(withName: "shield"))
    }
}
