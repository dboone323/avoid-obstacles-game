import Foundation
import SharedKit
import AvoidObstaclesGameCore

@available(macOS 15.0, *)
@main
struct GameBalanceAudit {
    static func main() async {
        print(">>> [AvoidObstaclesGame Agent] Starting Dynamic Balancing task...")
        
        // Initialize agent
        let agent = GameBalanceAgent()
        
        // Mock player metrics context
        let context: [String: Sendable] = [
            "player_performance": [
                "current_speed": 5.0,
                "consecutive_dodges": 12,
                "game_duration": 45.0,
                "avg_frame_rate": 60.0
            ]
        ]
        
        print(">>> [Task] Running autonomous difficulty adjustment based on player skill...")
        do {
            let result = try await agent.execute(context: context)
            print("\n--- Agent Result: \(result.agentId) ---")
            print("Status: \(result.success ? "SUCCESS" : "FAILURE")")
            print("Summary: \(result.summary)")
            print("Adjustment: \(result.detail["adjustment"] ?? "None")")
            print("New Speed: \(result.detail["suggested_speed"] ?? "Current")")
            print("Timestamp: \(result.timestamp)")
        } catch {
            print("Error executing agent: \(error)")
        }
        
        print("\n>>> [AvoidObstaclesGame Agent] Task completed.")
    }
}
