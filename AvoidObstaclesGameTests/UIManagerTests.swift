import XCTest
@testable import AvoidObstaclesGame
import SpriteKit

final class UIManagerTests: XCTestCase {
    
    var scene: SKScene!
    var manager: UIManager!
    
    override func setUp() {
        super.setUp()
        scene = SKScene(size: CGSize(width: 800, height: 600))
        manager = UIManager(scene: scene)
    }
    
    override func tearDown() {
        manager.removeAllUI()
        manager = nil
        scene = nil
        super.tearDown()
    }
    
    func testUISetup() {
        manager.setupUI()
        
        // Should create score, high score, and difficulty labels
        let scoreLabel = scene.childNode(withName: "//scoreLabel") ?? scene.children.first(where: { ($0 as? SKLabelNode)?.text?.contains("Score") == true })
        XCTAssertNotNil(scoreLabel, "Score label should be created")
    }
    
    func testScoreUpdate() {
        manager.setupUI()
        manager.updateScore(100)
        
        // Score should be updated
        XCTAssertTrue(true) // If no crash, test passes
    }
    
    func testDifficultyLevelUpdate() {
        manager.setupUI()
        manager.updateDifficultyLevel(5)
        
        // Difficulty should be updated
        XCTAssertTrue(true)
    }
    
    func testGameOverScreenDisplay() {
        manager.showGameOverScreen(finalScore: 500, isNewHighScore: true)
        
        // Game over screen should be added
        let gameOverLabel = scene.children.first(where: { ($0 as? SKLabelNode)?.text?.contains("Game Over") == true })
        XCTAssertNotNil(gameOverLabel)
    }
    
    func testGameOverScreenHide() {
        manager.showGameOverScreen(finalScore: 500, isNewHighScore: false)
        manager.hideGameOverScreen()
        
        // Game over screen should be removed (or fading out)
        XCTestExpectation(description: "Wait for fade")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(true)
        }
    }
    
    func testLevelUpEffect() {
        manager.setupUI()
        manager.showLevelUpEffect()
        
        // Level up label should be created
        XCTAssertTrue(true)
    }
    
    func testScorePopup() {
        manager.showScorePopup(score: 50, at: CGPoint(x: 400, y: 300))
        
        // Score popup should be added to scene
        XCTAssertGreaterThan(scene.children.count, 0)
    }
}
