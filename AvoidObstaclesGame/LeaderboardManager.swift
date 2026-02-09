import GameKit
#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

/// Manages Game Center leaderboards and achievements
class LeaderboardManager: NSObject {
    @MainActor static let shared = LeaderboardManager()

    private var isAuthenticated = false

    // Leaderboard IDs
    private let highScoreLeaderboard = "com.momentumfinance.avoidobstacles.highscore"
    private let longestRunLeaderboard = "com.momentumfinance.avoidobstacles.longestrun"

    override private init() {
        super.init()
        authenticatePlayer()
    }

    // MARK: - Authentication

    func authenticatePlayer() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            if let viewController {
                // Present authentication view controller
                #if os(iOS)
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = scene.windows.first?.rootViewController
                    {
                        rootVC.present(viewController, animated: true)
                    }
                #elseif os(macOS)
                    // On macOS, present the view controller in a window
                    if let window = NSApplication.shared.windows.first {
                        window.contentViewController?.presentAsSheet(viewController)
                    }
                #endif
            } else if GKLocalPlayer.local.isAuthenticated {
                self?.isAuthenticated = true
                GameLogger.shared.debug("✅ Game Center authenticated")
            } else {
                if let error {
                    GameLogger.shared.debug("❌ Game Center authentication failed: \(error)")
                }
                self?.isAuthenticated = false
            }
        }
    }

    // MARK: - Submit Score

    func submitScore(_ score: Int) {
        guard isAuthenticated else {
            GameLogger.shared.debug("⚠️ Not authenticated with Game Center")
            return
        }

        GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local,
                                  leaderboardIDs: [highScoreLeaderboard])
        { error in
            if let error {
                GameLogger.shared.debug("❌ Failed to submit score: \(error)")
            } else {
                GameLogger.shared.debug("✅ Score submitted: \(score)")
            }
        }
    }

    // MARK: - Show Leaderboard

    #if os(iOS)
        func showLeaderboard(from viewController: UIViewController) {
            guard isAuthenticated else {
                GameLogger.shared.debug("⚠️ Not authenticated with Game Center")
                return
            }

            let gcVC = GKGameCenterViewController(state: .leaderboards)
            gcVC.gameCenterDelegate = self
            viewController.present(gcVC, animated: true)
        }

    #elseif os(macOS)
        func showLeaderboard() {
            guard isAuthenticated else {
                GameLogger.shared.debug("⚠️ Not authenticated with Game Center")
                return
            }
            // On macOS, use GKDialogController or present modally
            GameLogger.shared.debug("Leaderboard display not fully implemented for macOS")
        }
    #endif

    // MARK: - Achievements

    func unlockAchievement(identifier: String, percentComplete: Double = 100.0) {
        guard isAuthenticated else { return }

        let achievement = GKAchievement(identifier: identifier)
        achievement.percentComplete = percentComplete
        achievement.showsCompletionBanner = true

        GKAchievement.report([achievement]) { error in
            if let error {
                GameLogger.shared.debug("❌ Failed to report achievement: \(error)")
            } else {
                GameLogger.shared.debug("✅ Achievement unlocked: \(identifier)")
            }
        }
    }

    // MARK: - Load Leaderboard Data

    func loadTopScores(completion: @escaping ([GKLeaderboard.Entry]) -> Void) {
        guard isAuthenticated else {
            completion([])
            return
        }

        GKLeaderboard.loadLeaderboards(IDs: [highScoreLeaderboard]) { leaderboards, _ in
            guard let leaderboard = leaderboards?.first else {
                completion([])
                return
            }

            leaderboard.loadEntries(for: .global, timeScope: .allTime, range: NSRange(
                location: 1,
                length: 10
            )) { _, entries, _, _ in
                completion(entries ?? [])
            }
        }
    }
}

// MARK: - Game Center Delegate

extension LeaderboardManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        #if os(iOS)
            gameCenterViewController.dismiss(animated: true)
        #elseif os(macOS)
            gameCenterViewController.dismiss(nil)
        #endif
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
