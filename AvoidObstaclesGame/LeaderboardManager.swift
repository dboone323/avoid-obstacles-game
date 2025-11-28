import GameKit

/// Manages Game Center leaderboards and achievements
class LeaderboardManager: NSObject {
    static let shared = LeaderboardManager()
    
    private var isAuthenticated = false
    
    // Leaderboard IDs
    private let highScoreLeaderboard = "com.momentumfinance.avoidobstacles.highscore"
    private let longestRunLeaderboard = "com.momentumfinance.avoidobstacles.longestrun"
    
    private override init() {
        super.init()
        authenticatePlayer()
    }
    
    // MARK: - Authentication
    
    func authenticatePlayer() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            if let viewController = viewController {
                // Present authentication view controller
                if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                    rootVC.present(viewController, animated: true)
                }
            } else if GKLocalPlayer.local.isAuthenticated {
                self?.isAuthenticated = true
                print("✅ Game Center authenticated")
            } else {
                if let error = error {
                    print("❌ Game Center authentication failed: \(error)")
                }
                self?.isAuthenticated = false
            }
        }
    }
    
    // MARK: - Submit Score
    
    func submitScore(_ score: Int) {
        guard isAuthenticated else {
            print("⚠️ Not authenticated with Game Center")
            return
        }
        
        let scoreValue = GKLeaderboardScore(leaderboardID: highScoreLeaderboard)
        scoreValue.value = score
        scoreValue.context = 0
        
        GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local,
                                 leaderboardIDs: [highScoreLeaderboard]) { error in
            if let error = error {
                print("❌ Failed to submit score: \(error)")
            } else {
                print("✅ Score submitted: \(score)")
            }
        }
    }
    
    // MARK: - Show Leaderboard
    
    func showLeaderboard(from viewController: UIViewController) {
        guard isAuthenticated else {
            print("⚠️ Not authenticated with Game Center")
            return
        }
        
        let gcVC = GKGameCenterViewController(state: .leaderboards)
        gcVC.gameCenterDelegate = self
        viewController.present(gcVC, animated: true)
    }
    
    // MARK: - Achievements
    
    func unlockAchievement(identifier: String, percentComplete: Double = 100.0) {
        guard isAuthenticated else { return }
        
        let achievement = GKAchievement(identifier: identifier)
        achievement.percentComplete = percentComplete
        achievement.showsCompletionBanner = true
        
        GKAchievement.report([achievement]) { error in
            if let error = error {
                print("❌ Failed to report achievement: \(error)")
            } else {
                print("✅ Achievement unlocked: \(identifier)")
            }
        }
    }
    
    // MARK: - Load Leaderboard Data
    
    func loadTopScores(completion: @escaping ([GKLeaderboard.Entry]) -> Void) {
        guard isAuthenticated else {
            completion([])
            return
        }
        
        GKLeaderboard.loadLeaderboards(IDs: [highScoreLeaderboard]) { leaderboards, error in
            guard let leaderboard = leaderboards?.first else {
                completion([])
                return
            }
            
            leaderboard.loadEntries(for: .global, timeScope: .allTime, range: NSRange(location: 1, length: 10)) { local, entries, totalCount, error in
                completion(entries ?? [])
            }
        }
    }
}

// MARK: - Game Center Delegate

extension LeaderboardManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}

// Achievement IDs
extension LeaderboardManager {
    enum Achievement {
        static let firstGame = "com.momentumfinance.avoidobstacles.firstgame"
        static let score100 = "com.momentumfinance.avoidobstacles.score100"
        static let score500 = "com.momentumfinance.avoidobstacles.score500"
        static let score1000 = "com.momentumfinance.avoidobstacles.score1000"
        static let perfectRun = "com.momentumfinance.avoidobstacles.perfectrun"
    }
}
