
import GameKit
#if canImport(UIKit)
import UIKit
#endif

// Enhancement #88: Multiplayer Mode
#if os(iOS)
class MultiplayerManager: NSObject, ObservableObject, GKMatchmakerViewControllerDelegate, GKMatchDelegate {
    @Published var match: GKMatch?
    
    func findMatch(vc: UIViewController) {
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        
        let mmvc = GKMatchmakerViewController(matchRequest: request)!
        mmvc.matchmakerDelegate = self
        vc.present(mmvc, animated: true)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        viewController.dismiss(animated: true)
        self.match = match
        match.delegate = self
    }
    
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(animated: true)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: any Error) {
        viewController.dismiss(animated: true)
        print("Matchmaker failed with error: \(error.localizedDescription)")
    }
    
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        // Handle game data
    }
}
#else
// macOS stub - multiplayer UI requires iOS
class MultiplayerManager: NSObject, ObservableObject {
    @Published var match: GKMatch?
    
    func findMatch() {
        // Multiplayer UI not available on macOS
        print("Multiplayer matchmaking is only available on iOS")
    }
}
#endif
