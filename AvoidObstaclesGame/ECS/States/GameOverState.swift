//
// GameOverState.swift
// AvoidObstaclesGame
//
// State for game over - score display, restart handling.
//

import GameplayKit
import SpriteKit

/// State representing game over.
class GameOverState: GKState {
    /// Reference to the game scene.
    weak var scene: GameScene?

    /// Callback for when restart is requested.
    var onRestartRequested: (() -> Void)?

    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass == GamePlayingState.self
    }

    override func didEnter(from previousState: GKState?) {
        GameLogger.shared.debug("💀 Entered Game Over State")

        guard let scene else { return }

        // Stop physics
        scene.physicsWorld.speed = 0.0

        // Stop spawning obstacles
        scene.removeAction(forKey: "spawnObstacles")

        // Show game over UI (handled by UIManager)
    }

    /// Called when the player requests a restart.
    func requestRestart() {
        onRestartRequested?()
        stateMachine?.enter(GamePlayingState.self)
    }

    override func willExit(to nextState: GKState) {
        GameLogger.shared.debug("💀 Exiting Game Over State -> \(type(of: nextState))")
    }
}
