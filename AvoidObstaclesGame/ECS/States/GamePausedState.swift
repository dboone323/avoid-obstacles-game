//
// GamePausedState.swift
// AvoidObstaclesGame
//
// State for paused gameplay - physics stopped, UI overlay shown.
//

import GameplayKit
import SpriteKit

/// State representing paused gameplay.
class GamePausedState: GKState {
    
    /// Reference to the game scene.
    weak var scene: GameScene?
    
    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == GamePlayingState.self || stateClass == GameOverState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        GameLogger.shared.debug("⏸️ Entered Paused State")
        
        guard let scene = scene else { return }
        
        // Pause physics
        scene.physicsWorld.speed = 0.0
        
        // Show pause overlay (handled by UIManager)
    }
    
    override func willExit(to nextState: GKState) {
        GameLogger.shared.debug("⏸️ Exiting Paused State -> \(type(of: nextState))")
        
        guard let scene = scene else { return }
        
        // Resume physics if going back to playing
        if nextState is GamePlayingState {
            scene.physicsWorld.speed = 1.0
        }
    }
}
