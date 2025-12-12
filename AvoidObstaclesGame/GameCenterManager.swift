
import GameKit
import SwiftUI

// Enhancement #86: Game Center Leaderboards
class GameCenterManager: NSObject, ObservableObject {
    @Published var isAuthenticated = false
    
    override init() {
        super.init()
        authenticateUser()
    }
    
    func authenticateUser() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] vc, error in
            if vc != nil {
                // Present vc if needed (usually handled by root VC)
                print("Game Center auth required")
            } else if GKLocalPlayer.local.isAuthenticated {
                self?.isAuthenticated = true
            } else {
                print("Game Center auth failed: \(error?.localizedDescription ?? "unknown")")
            }
        }
    }
    
    func submitScore(score: Int) {
        if isAuthenticated {
            GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: ["highscore_leaderboard"]) { error in
                if let error = error {
                    print("Error submitting score: \(error)")
                }
            }
        }
    }
}

#if os(iOS)
extension GameCenterManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
#endif
