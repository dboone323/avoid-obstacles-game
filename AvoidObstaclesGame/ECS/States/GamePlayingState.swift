//
// GamePlayingState.swift
// AvoidObstaclesGame
//
// State for active gameplay - obstacles spawn, physics runs.
//

import GameplayKit
import SpriteKit

/// State representing active gameplay.
@MainActor
class GamePlayingState: GKState, @unchecked Sendable {
    /// Reference to the game scene.
    weak var scene: GameScene?

    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass == GamePausedState.self || stateClass == GameOverState.self
    }

    override func didEnter(from previousState: GKState?) {
        Task { @MainActor in
            GameLogger.shared.debug("🎮 Entered Playing State")

            guard let scene = self.scene else { return }

            scene.physicsWorld.speed = 1.0
            scene.isPaused = false

            // Start spawning obstacles
            scene.obstacleManager.startSpawning(with: scene.gameStateManager.getCurrentDifficulty())
        }
    }

    override func update(deltaTime seconds: TimeInterval) {
        // Update game logic each frame
        // Entity component updates are handled by component systems
    }

    override func willExit(to nextState: GKState) {
        let nextStateName = String(describing: type(of: nextState))
        Task { @MainActor in
            GameLogger.shared.debug("🎮 Exiting Playing State -> \(nextStateName)")
            self.scene?.obstacleManager.stopSpawning()
        }
    }
}
