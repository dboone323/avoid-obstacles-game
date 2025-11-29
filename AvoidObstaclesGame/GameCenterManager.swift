//
// GameCenterManager.swift
// AvoidObstaclesGame
//

import Foundation
import GameKit

class GameCenterManager: NSObject {
    static let shared = GameCenterManager()
    
    private(set) var isAuthenticated = false
    private(set) var localPlayer: GKLocalPlayer?
    
    private override init() {
        super.init()
    }
    
    func authenticatePlayer(completion: @escaping (Bool) -> Void) {
        localPlayer = GKLocalPlayer.local
        
        localPlayer?.authenticateHandler = { [weak self] viewController, error in
            if let error = error {
                print("GameCenter auth error: \(error)")
                completion(false)
                return
            }
            
            if let vc = viewController {
                // Present auth UI
                completion(false)
            } else if self?.localPlayer?.isAuthenticated == true {
                self?.isAuthenticated = true
                completion(true)
            }
        }
    }
    
    func submitScore(_ score: Int, leaderboardID: String = "com.game.highscore") {
        guard isAuthenticated else { return }
        
        GKLeaderboard.submitScore(score, context: 0, player: localPlayer!, 
                                 leaderboardIDs: [leaderboardID]) { error in
            if let error = error {
                print("Score submit error: \(error)")
            }
        }
    }
    
    func reportAchievement(_ identifier: String, percentComplete: Double = 100.0) {
        guard isAuthenticated else { return }
        
        let achievement = GKAchievement(identifier: identifier)
        achievement.percentComplete = percentComplete
        achievement.showsCompletionBanner = true
        
        GKAchievement.report([achievement]) { error in
            if let error = error {
                print("Achievement error: \(error)")
            }
        }
    }
    
    func showLeaderboard(from viewController: UIViewController) {
        guard isAuthenticated else { return }
        
        let vc = GKGameCenterViewController(state: .leaderboards)
        vc.gameCenterDelegate = self
        viewController.present(vc, animated: true)
    }
    
    func showAchievements(from viewController: UIViewController) {
        guard isAuthenticated else { return }
        
        let vc = GKGameCenterViewController(state: .achievements)
        vc.gameCenterDelegate = self
        viewController.present(vc, animated: true)
    }
}

extension GameCenterManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
