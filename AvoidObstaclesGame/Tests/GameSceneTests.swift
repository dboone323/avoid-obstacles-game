import XCTest

class GameSceneTests: XCTestCase {
    
    var gameScene: GameScene!
    
    override func setUp() {
        super.setUp()
        
        let size = CGSize(width: 320, height: 480)
        gameScene = GameScene(size: size)
        gameScene.playerManager.scene = gameScene
        gameScene.obstacleManager.scene = gameScene
        gameScene.uiManager.scene = gameScene
        gameScene.physicsManager.scene = gameScene
        gameScene.effectsManager.scene = gameScene
        
        // Set up service relationships
        gameScene.setupServiceDelegates()
    }
    
    override func tearDown() {
        gameScene = nil
        super.tearDown()
    }
    
    func testInitialization() {
        XCTAssertNotNil(gameScene.playerManager)
        XCTAssertNotNil(gameScene.obstacleManager)
        XCTAssertNotNil(gameScene.uiManager)
        XCTAssertNotNil(gameScene.physicsManager)
        XCTAssertNotNil(gameScene.effectsManager)
        XCTAssertEqual(gameScene.gameStateManager.currentState, .menu)
    }
    
    func testStartGame() {
        gameScene.startGame()
        XCTAssertTrue(gameScene.gameStateManager.isGameActive())
    }
    
    func testHandleGameOver() {
        gameScene.gameStateManager.setState(.gameOver)
        gameScene.handleGameOver()
        XCTAssertTrue(gameScene.gameStateManager.isGameOver())
        XCTAssertEqual(gameScene.physicsWorld.speed, 0)
    }
    
    func testRestartGame() {
        gameScene.gameStateManager.setState(.gameOver)
        gameScene.restartGame()
        XCTAssertTrue(gameScene.gameStateManager.isGameActive())
        XCTAssertEqual(gameScene.physicsWorld.speed, 1.0)
    }
    
    func testUpdateGameplay() {
        let currentTime = Date().timeIntervalSince1970
        gameScene.lastUpdateTime = currentTime - 1.0
        gameScene.update(currentTime)
        
        // Check if score and survival time are updated
        XCTAssertTrue(gameScene.gameStateManager.score > 0)
        XCTAssertTrue(gameScene.currentGameStats.survivalTime > 0)
    }
    
    func testTouchHandling() {
        let location = CGPoint(x: 160, y: 240)
        
        // Simulate touch began
        #if canImport(UIKit)
            gameScene.touchesBegan([UITouch(location: location, view: nil)], with: nil)
        #else
            gameScene.mouseDown(with: NSEvent(mouseLocation: location))
        #endif
        
        // Check if player moved to the touched location
        XCTAssertTrue(gameScene.playerManager.position == location)
        
        // Simulate touch moved
        #if canImport(UIKit)
            gameScene.touchesMoved([UITouch(location: CGPoint(x: 180, y: 260), view: nil)], with: nil)
        #else
            gameScene.mouseDragged(with: NSEvent(mouseLocation: CGPoint(x: 180, y: 260)))
        #endif
        
        // Check if player moved to the new touched location
        XCTAssertTrue(gameScene.playerManager.position == CGPoint(x: 180, y: 260))
    }
    
    func testPhysicsContactDelegate() {
        let contact = SKPhysicsContact()
        gameScene.didBegin(contact)
        
        // Check if obstacle manager is updated
        XCTAssertTrue(gameScene.obstacleManager.isSpawning)
    }
}
