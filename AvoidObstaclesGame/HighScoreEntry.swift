import Foundation
import SwiftData

@Model
final class HighScoreEntry {
    var id: UUID
    var score: Int
    var date: Date
    var playerName: String

    init(score: Int, playerName: String, date: Date = Date()) {
        self.id = UUID()
        self.score = score
        self.playerName = playerName
        self.date = date
    }
}
