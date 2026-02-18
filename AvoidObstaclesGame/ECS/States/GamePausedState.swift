//
// GamePausedState.swift
// AvoidObstaclesGame
//
// State for paused gameplay - physics stopped, UI overlay shown.
//

import GameplayKit
import SpriteKit

/// State representing paused gameplay.
@MainActor
class GamePausedState: GKState, @unchecked Sendable {
    /// Reference to the game scene.
    weak var scene: GameScene?

    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass == GamePlayingState.self || stateClass == GameOverState.self
    }

    override func didEnter(from previousState: GKState?) {
        Task { @MainActor in
            guard let scene = self.scene else { return }

            scene.physicsWorld.speed = 0.0
            scene.isPaused = true

            GameLogger.shared.debug("⏸️ Game Paused")
        }
    }

    override func willExit(to nextState: GKState) {
        let nextStateName = String(describing: type(of: nextState))
        let isGoingToPlaying = nextState is GamePlayingState

        Task { @MainActor in
            GameLogger.debugNonIsolated("⏸️ Exiting Paused State -> \(nextStateName)")

            guard let scene = self.scene else { return }

            // Resume physics if going back to playing
            if isGoingToPlaying {
                scene.physicsWorld.speed = 1.0
            }
        }
    }
}
