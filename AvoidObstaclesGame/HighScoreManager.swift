//
// HighScoreManager.swift
// AvoidObstaclesGame
//
// Manages high scores with persistent storage using UserDefaults
//

import Foundation
import SwiftData


/// Manages high scores with persistent storage using SwiftData.
@MainActor
class HighScoreManager {
    static let shared = HighScoreManager()
    private let maxScores = 10

    private let modelContainer: ModelContainer
    private var modelContext: ModelContext { modelContainer.mainContext }

    private init() {
        do {
            modelContainer = try ModelContainer(for: HighScoreEntry.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    /// Retrieves all high scores sorted from highest to lowest.
    func getHighScores() -> [HighScoreEntry] {
        let descriptor = FetchDescriptor<HighScoreEntry>(sortBy: [SortDescriptor(\.score, order: .reverse), SortDescriptor(\.date, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    /// Async version
    func getHighScoresAsync() async -> [HighScoreEntry] {
        getHighScores()
    }

    /// Adds a new score to the high scores list.
    /// Returns true if the score is in the top 10 after adding.
    func addScore(_ score: Int, playerName: String) -> Bool {
        let entry = HighScoreEntry(score: score, playerName: playerName)
        modelContext.insert(entry)
        trimScoresIfNeeded()
        return isHighScore(score)
    }

    /// Async version
    func addScoreAsync(_ score: Int, playerName: String) async -> Bool {
        addScore(score, playerName: playerName)
    }

    /// Returns the highest score, or 0 if none exist.
    func getHighestScore() -> Int {
        getHighScores().first?.score ?? 0
    }

    func getHighestScoreAsync() async -> Int {
        getHighestScore()
    }

    /// Checks if a given score would qualify as a high score without adding it.
    func isHighScore(_ score: Int) -> Bool {
        let scores = getHighScores().map { $0.score }
        return scores.count < maxScores || score > (scores.last ?? 0)
    }

    func isHighScoreAsync(_ score: Int) async -> Bool {
        isHighScore(score)
    }

    /// Removes all high scores (for testing/reset)
    func clearHighScores() {
        let all = getHighScores()
        for entry in all { modelContext.delete(entry) }
    }

    func clearHighScoresAsync() async {
        clearHighScores()
    }

    /// Keeps only the top 10 scores
    private func trimScoresIfNeeded() {
        let scores = getHighScores()
        if scores.count > maxScores {
            for entry in scores[maxScores...] {
                modelContext.delete(entry)
            }
        }
    }
}

// MARK: - Object Pooling

/// Object pool for performance optimization
private nonisolated(unsafe) var objectPool: [Any] = []
private let maxPoolSize = 50

/// Get an object from the pool or create new one
private func getPooledObject<T>() -> T? {
    if let pooled = objectPool.popLast() as? T {
        return pooled
    }
    return nil
}

/// Return an object to the pool
private func returnToPool(_ object: Any) {
    if objectPool.count < maxPoolSize {
        objectPool.append(object)
    }
}
