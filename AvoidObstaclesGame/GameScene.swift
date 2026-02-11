//
// GameScene.swift
// AvoidObstaclesGame
//
// The main SpriteKit scene that coordinates all game services and systems.
//

import GameplayKit
import SpriteKit
#if canImport(UIKit)
    import UIKit
#endif

/// The main SpriteKit scene for AvoidObstaclesGame.
/// Coordinates all game services and manages the high-level game flow.
public class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Service Managers

    /// Game state management
    private let gameStateManager = GameStateManager()

    /// Player management
    private let playerManager: PlayerManager

    /// Obstacle management
    private let obstacleManager: ObstacleManager

    /// UI management
    private let uiManager: UIManager

    /// Physics management
    private let physicsManager: PhysicsManager

    /// Effects management
    private let effectsManager: EffectsManager

    /// Audio management (shared)
    private let audioManager = AudioManager.shared

    /// Achievement management (shared)
    private let achievementManager = AchievementManager.shared

    /// Performance management (shared)
    private let performanceManager = PerformanceManager.shared

    // MARK: - Properties

    /// Last update time for game loop
    private var lastUpdateTime: TimeInterval = 0

    /// Game statistics for achievements
    private var currentGameStats = GameStats()

    // MARK: - Initialization

    override init(size: CGSize) {
        // Create temporary placeholder scenes for initialization
        let tempScene = SKScene()
        playerManager = PlayerManager(scene: tempScene)
        obstacleManager = ObstacleManager(scene: tempScene)
        uiManager = UIManager(scene: tempScene)
        physicsManager = PhysicsManager(scene: tempScene)
        effectsManager = EffectsManager(scene: tempScene)

        super.init(size: size)

        // Now assign the actual scene to each manager
        playerManager.scene = self
        obstacleManager.scene = self
        uiManager.scene = self
        physicsManager.scene = self
        effectsManager.scene = self

        // Setup service relationships
        setupServiceDelegates()
    }

    required init?(coder aDecoder: NSCoder) {
        // Create temporary placeholder scenes for initialization
        let tempScene = SKScene()
        playerManager = PlayerManager(scene: tempScene)
        obstacleManager = ObstacleManager(scene: tempScene)
        uiManager = UIManager(scene: tempScene)
        physicsManager = PhysicsManager(scene: tempScene)
        effectsManager = EffectsManager(scene: tempScene)

        super.init(coder: aDecoder)

        // Now assign the actual scene to each manager
        playerManager.scene = self
        obstacleManager.scene = self
        uiManager.scene = self
        physicsManager.scene = self
        effectsManager.scene = self

        // Setup service relationships
        setupServiceDelegates()
    }

    /// Sets up delegates between services
    private func setupServiceDelegates() {
        // Game state delegates
        gameStateManager.delegate = self

        // Player manager delegates
        playerManager.delegate = self

        // Obstacle manager delegates
        obstacleManager.delegate = self

        // UI manager delegates
        uiManager.delegate = self

        // Physics manager delegates
        physicsManager.delegate = self

        // Achievement manager delegates
        achievementManager.delegate = self

        // Performance manager delegates
        performanceManager.delegate = self
    }

    // MARK: - Scene Lifecycle

    /// Called when the scene is first presented by the view.
    override public func didMove(to view: SKView) {
        GameLogger.shared.debug("🎮 GameScene.didMove(to:) called - Scene size: \(size)")
        GameLogger.shared.debug("🎮 View bounds: \(view.bounds)")

        // Setup the scene
        setupScene()

        // Start background music
        audioManager.playBackgroundMusic()

        // Start the game
        startGame()

        GameLogger.shared.debug("🎮 GameScene setup complete - children count: \(children.count)")
    }

    /// Sets up the basic scene configuration
    private func setupScene() {
        GameLogger.shared.debug("🎮 setupScene() starting...")

        // Configure crash reporting
        CrashReportingManager.shared.configure()

        // Configure physics world
        physicsWorld.contactDelegate = self

        // Setup background
        setupBackground()

        // Setup UI
        GameLogger.shared.debug("🎮 Setting up UI...")
        uiManager.setupUI()

        // Setup player
        GameLogger.shared.debug("🎮 Creating player...")
        playerManager.createPlayer(at: CGPoint(x: size.width / 2, y: 100))

        // Enable tilt controls if available
        enableTiltControlsIfAvailable()

        // Setup effects
        effectsManager.createExplosion(at: .zero) // Preload explosion effect

        GameLogger.shared.debug("🎮 setupScene() complete")

        // Setup ComboSystem callbacks
        ComboSystem.shared.onComboChanged = { [weak self] _, points in
            self?.gameStateManager.addScore(points)
        }
    }

    /// Sets up the animated background
    private func setupBackground() {
        // Create gradient background
        let backgroundNode = SKSpriteNode(color: .systemCyan, size: size)
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode.zPosition = -100
        addChild(backgroundNode)

        // Add animated clouds (only if scene has valid size)
        guard size.width > 60 && size.height > 0 else { return }

        let minY = max(0, size.height * 0.7)
        let maxY = max(minY, size.height)

        for _ in 0..<5 {
            let cloud = SKSpriteNode(color: .white.withAlphaComponent(0.3), size: CGSize(width: 60, height: 30))
            cloud.position = CGPoint(
                x: CGFloat.random(in: 0...max(1, size.width)),
                y: CGFloat.random(in: minY...maxY)
            )
            cloud.zPosition = -50

            // Animate clouds
            let moveAction = SKAction.moveBy(x: -size.width - 60, y: 0, duration: TimeInterval.random(in: 10...20))
            let resetAction = SKAction.moveTo(x: size.width + 60, duration: 0)
            let sequence = SKAction.sequence([moveAction, resetAction])
            cloud.run(SKAction.repeatForever(sequence))

            addChild(cloud)
        }
    }

    /// Enables tilt controls if the device supports motion and user has enabled it
    private func enableTiltControlsIfAvailable() {
        // Check if tilt controls should be enabled (could be from user settings)
        let tiltEnabled = UserDefaults.standard.bool(forKey: "tiltControlsEnabled")
        if tiltEnabled {
            playerManager.enableTiltControls(sensitivity: 0.7)
        }
    }

    /// Starts a new game
    private func startGame() {
        gameStateManager.startGame()
        currentGameStats = GameStats()
        CrashReportingManager.shared.logGameStart()
    }

    // MARK: - Game Flow

    /// Handles game over
    private func handleGameOver() {
        gameStateManager.endGame()

        // Stop physics simulation but don't pause entire scene (so UI can animate)
        physicsWorld.speed = 0

        // Stop spawning obstacles and clear existing ones
        obstacleManager.stopSpawning()
        obstacleManager.removeAllObstacles()

        // Update achievements
        achievementManager.updateProgress(for: .gameCompleted, value: Int(gameStateManager.survivalTime))

        // Show game over screen
        let isNewHighScore = HighScoreManager.shared.addScore(gameStateManager.score)
        uiManager.showGameOverScreen(finalScore: gameStateManager.score, isNewHighScore: isNewHighScore)

        // Play game over sound
        audioManager.playCollision()

        // Log for crash reporting
        CrashReportingManager.shared.logGameOver(
            score: gameStateManager.score,
            survivalTime: gameStateManager.survivalTime,
            level: gameStateManager.getCurrentDifficultyLevel()
        )
    }

    /// Restarts the game
    private func restartGame() {
        GameLogger.shared.debug("🔄 Restarting game...")
        // Hide game over screen
        uiManager.hideGameOverScreen()

        // Reset power-up system (CRITICAL FIX: prevents shields from persisting)
        PowerUpSystem.shared.reset()

        // Reset player
        playerManager.reset()
        playerManager.setPosition(CGPoint(x: size.width / 2, y: 100))

        // Clear obstacles
        obstacleManager.removeAllObstacles()

        // Ensure physics speed is restored
        physicsWorld.speed = 1.0

        // Start new game
        startGame()
    }

    // MARK: - Touch Handling

    // Handles touch input
    #if canImport(UIKit)
        override public func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)

            if gameStateManager.isGameOver() {
                // Handle restart
                uiManager.handleTouch(at: location)
            } else {
                // Handle player movement
                playerManager.moveTo(location)
            }
        }

        /// Handles touch movement for player control
        override public func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
            guard !gameStateManager.isGameOver(), let touch = touches.first else { return }
            let location = touch.location(in: self)
            playerManager.moveTo(location)
        }
    #else
        override public func mouseDown(with event: NSEvent) {
            let location = event.location(in: self)

            if gameStateManager.isGameOver() {
                // Handle restart
                uiManager.handleTouch(at: location)
            } else {
                // Handle player movement
                playerManager.moveTo(location)
            }
        }

        override public func mouseDragged(with event: NSEvent) {
            guard !gameStateManager.isGameOver() else { return }
            let location = event.location(in: self)
            playerManager.moveTo(location)
        }
    #endif

    // MARK: - Physics Contact Delegate

    /// Handles physics collisions
    public func didBegin(_ contact: SKPhysicsContact) {
        physicsManager.didBegin(contact)
    }

    // MARK: - Update Loop

    /// Main game update loop
    override public func update(_ currentTime: TimeInterval) {
        // Calculate time since last update
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }

        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update managerstate if playing
        if gameStateManager.isGameActive() {
            updateGameplay(dt)
        }

        // Update obstacle manager
        obstacleManager.updateObstacles()

        // Update effects
        effectsManager.updateBackgroundEffects(for: gameStateManager.getCurrentDifficulty())
    }

    /// Updates gameplay logic
    private func updateGameplay(_ deltaTime: TimeInterval) {
        // Update score based on time
        let scoreIncrement = Int(deltaTime * Double(gameStateManager.getCurrentDifficulty().scoreMultiplier))
        if scoreIncrement > 0 {
            gameStateManager.addScore(scoreIncrement)
        }

        // Update survival time
        currentGameStats.survivalTime += deltaTime
    }
}

// MARK: - Service Delegates

extension GameScene: GameStateDelegate {
    func gameStateDidChange(from _: GameState, to newState: GameState) {
        switch newState {
        case .playing:
            obstacleManager.startSpawning(with: gameStateManager.getCurrentDifficulty())
        case .gameOver:
            // Don't call handleGameOver here - that would create infinite recursion!
            // handleGameOver() is called directly from playerDidCollide, not from state change
            obstacleManager.stopSpawning()
        default:
            break
        }
    }

    func scoreDidChange(to newScore: Int) {
        uiManager.updateScore(newScore)
        currentGameStats.finalScore = newScore
        achievementManager.updateProgress(for: .scoreReached(score: newScore))
    }

    func difficultyDidIncrease(to level: Int) {
        uiManager.updateDifficultyLevel(level)
        uiManager.showLevelUpEffect()
        effectsManager.createLevelUpCelebration()
        audioManager.playLevelUp()
        achievementManager.updateProgress(for: .difficultyReached(level: level))
    }

    func gameDidEnd(withScore finalScore: Int, survivalTime: TimeInterval) {
        currentGameStats.finalScore = finalScore
        currentGameStats.survivalTime = survivalTime
        currentGameStats.maxDifficultyReached = gameStateManager.getCurrentDifficultyLevel()
    }
}

extension GameScene: PlayerDelegate {
    func playerDidMove(to _: CGPoint) {
        // Handle player movement feedback if needed
    }

    func playerDidCollide(with _: SKNode) {
        // Quick early exit if already handling game over
        guard gameStateManager.currentState != .gameOver else { return }

        // Minimal collision handling - just call game over
        handleGameOver()
    }
}

extension GameScene: ObstacleDelegate {
    func obstacleDidSpawn(_: SKSpriteNode) {
        // Obstacle spawned successfully
    }

    func obstacleDidRecycle(_ obstacle: SKSpriteNode) {
        // Obstacle recycled = successfully dodged!
        if gameStateManager.isGameActive() {
            ComboSystem.shared.recordDodge(currentTime: lastUpdateTime)
            currentGameStats.obstaclesAvoided += 1

            // Show combo popup at milestones
            let combo = ComboSystem.shared.getCurrentCombo()
            if combo % 10 == 0 && combo > 0 {
                effectsManager.createScorePopup(
                    score: ComboSystem.shared.calculatePoints(),
                    at: playerManager.position,
                    color: .cyan
                )
            }
        }
    }
}

extension GameScene: UIManagerDelegate {
    func restartButtonTapped() {
        restartGame()
    }
}

extension GameScene: PhysicsManagerDelegate {
    func playerDidCollideWithObstacle(_: SKNode, obstacle: SKNode) {
        // Trigger screen shake (now that loop issues are fixed)
        effectsManager.createScreenShake()

        playerManager.handleCollision(with: obstacle)
    }

    func playerDidCollideWithPowerUp(_: SKNode, powerUp: SKNode) {
        // Handle power-up collection
        powerUp.removeFromParent()
        effectsManager.createPowerUpCollectionEffect(at: powerUp.position)
        audioManager.playPowerUp()

        // Determine power-up type from identifier (accessible - not color-based)
        let powerUpType: PowerUpType = if let nodeName = powerUp.name {
            switch nodeName {
            case PowerUpType.shield.identifier:
                .shield
            case PowerUpType.speedBoost.identifier:
                .speedBoost
            case PowerUpType.magnet.identifier:
                .magnet
            case PowerUpType.slowTime.identifier:
                .slowTime
            case PowerUpType.doublePoints.identifier:
                .doublePoints
            default:
                .shield // Default fallback
            }
        } else {
            .shield // Default fallback
        }

        playerManager.applyPowerUpEffect(powerUpType)

        achievementManager.updateProgress(for: .powerUpCollected)
    }
}

extension GameScene: AchievementDelegate {
    func achievementUnlocked(_ achievement: Achievement) {
        // Show achievement notification
        uiManager.showScorePopup(score: achievement.points, at: CGPoint(x: size.width / 2, y: size.height / 2))
    }

    func achievementProgressUpdated(_: Achievement, progress _: Float) {
        // Could show progress indicator
    }
}

extension GameScene: PerformanceDelegate {
    func performanceWarningTriggered(_ warning: PerformanceWarning) {
        switch warning {
        case .highMemoryUsage, .memoryPressure:
            // Reduce obstacle count or effects
            obstacleManager.removeAllObstacles()
        case .lowFrameRate:
            // Reduce visual effects
            effectsManager.cleanupUnusedEffects()
        default:
            break
        }
    }

    func frameRateDropped(below targetFPS: Int) {
        // Handle frame rate drops
        GameLogger.shared.debug("Frame rate dropped below \(targetFPS) FPS")
    }
}

/// Game statistics for achievements and analytics
struct GameStats {
    var finalScore: Int = 0
    var survivalTime: TimeInterval = 0
    var maxDifficultyReached: Int = 1
    var powerUpsCollected: Int = 0
    var obstaclesAvoided: Int = 0
}
