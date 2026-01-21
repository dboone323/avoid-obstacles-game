//
// GamePlayingState.swift
// AvoidObstaclesGame
//
// State for active gameplay - obstacles spawn, physics runs.
//

import GameplayKit
import SpriteKit

/// State representing active gameplay.
class GamePlayingState: GKState {
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
        GameLogger.shared.debug("🎮 Entered Playing State")

        guard let scene else { return }

        // Ensure physics is running
        scene.physicsWorld.speed = 1.0
        scene.isPaused = false

        // Start spawning if coming from pause
        if previousState is GamePausedState {
            // Resume spawning
        }
    }

    override func update(deltaTime seconds: TimeInterval) {
        // Update game logic each frame
        // Entity component updates are handled by component systems
    }

    override func willExit(to nextState: GKState) {
        GameLogger.shared.debug("🎮 Exiting Playing State -> \(type(of: nextState))")
    }
}
