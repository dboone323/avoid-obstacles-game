//
// GameLogger.swift
// AvoidObstaclesGame
//
// Centralized logging for the game, replacing print() statements.
//

import Foundation
import os.log

/// Centralized logger for AvoidObstaclesGame.
/// Replaces print() statements with structured logging.
final class GameLogger {
    @MainActor static let shared = GameLogger()

    // MARK: - Log Categories

    private let gameLog = Logger(subsystem: "com.avoidobstacles", category: "game")
    private let physicsLog = Logger(subsystem: "com.avoidobstacles", category: "physics")
    private let audioLog = Logger(subsystem: "com.avoidobstacles", category: "audio")
    private let inputLog = Logger(subsystem: "com.avoidobstacles", category: "input")
    private let networkLog = Logger(subsystem: "com.avoidobstacles", category: "network")
    private let ecsLog = Logger(subsystem: "com.avoidobstacles", category: "ecs")

    private init() {}

    // MARK: - Game Events

    func gameStarted() {
        gameLog.info("🎮 Game started")
    }

    func gamePaused() {
        gameLog.info("⏸️ Game paused")
    }

    func gameResumed() {
        gameLog.info("▶️ Game resumed")
    }

    func gameOver(score: Int, level: Int) {
        gameLog.info("💀 Game over - Score: \(score), Level: \(level)")
    }

    func newHighScore(_ score: Int) {
        gameLog.notice("🏆 New high score: \(score)")
    }

    func levelUp(to level: Int) {
        gameLog.info("📈 Level up to \(level)")
    }

    // MARK: - Physics Events

    func collision(player: String, obstacle: String) {
        physicsLog.debug("💥 Collision: \(player) hit \(obstacle)")
    }

    func nearMiss(distance: Float) {
        physicsLog.debug("😅 Near miss - distance: \(distance)")
    }

    // MARK: - Power-ups

    func powerUpCollected(type: String) {
        gameLog.info("⬆️ Power-up collected: \(type)")
    }

    func powerUpExpired(type: String) {
        gameLog.debug("⏱️ Power-up expired: \(type)")
    }

    // MARK: - ECS Events

    func entityCreated(type: String, id: String) {
        ecsLog.debug("➕ Entity created: \(type) [\(id)]")
    }

    func entityDestroyed(type: String, id: String) {
        ecsLog.debug("➖ Entity destroyed: \(type) [\(id)]")
    }

    func componentAdded(component: String, to entity: String) {
        ecsLog.debug("🔗 Component \(component) added to \(entity)")
    }

    func systemUpdate(system: String, deltaTime: Double) {
        ecsLog.debug("🔄 System update: \(system) (dt: \(deltaTime))")
    }

    // MARK: - Audio Events

    func audioPlayed(sound: String) {
        audioLog.debug("🔊 Playing: \(sound)")
    }

    func audioError(_ error: String) {
        audioLog.error("❌ Audio error: \(error)")
    }

    // MARK: - Input Events

    func touchBegan(x: Float, y: Float) {
        inputLog.debug("👆 Touch began at (\(x), \(y))")
    }

    func touchMoved(x: Float, y: Float) {
        inputLog.debug("👆 Touch moved to (\(x), \(y))")
    }

    func touchEnded() {
        inputLog.debug("👆 Touch ended")
    }

    // MARK: - Network/GameCenter Events

    func gameCenterAuth(success: Bool) {
        if success {
            networkLog.info("✅ Game Center authenticated")
        } else {
            networkLog.warning("⚠️ Game Center auth failed")
        }
    }

    func scoreSubmitted(score: Int, success: Bool) {
        if success {
            networkLog.info("📤 Score \(score) submitted successfully")
        } else {
            networkLog.error("❌ Failed to submit score \(score)")
        }
    }

    // MARK: - Debug/Error

    func debug(_ message: String) {
        #if DEBUG
            gameLog.debug("🐛 \(message)")
        #endif
    }

    func error(_ message: String) {
        gameLog.error("❌ \(message)")
    }

    func warning(_ message: String) {
        gameLog.warning("⚠️ \(message)")
    }
}

// MARK: - Convenience Global Function

/// Drop-in replacement for print() that uses structured logging
func gameLog(_ message: String, category: LogCategory = .game) {
    #if DEBUG
        switch category {
        case .game:
            GameLogger.shared.debug(message)
        case .physics:
            GameLogger.shared.debug(message)
        case .audio:
            GameLogger.shared.debug(message)
        case .input:
            GameLogger.shared.debug(message)
        case .ecs:
            GameLogger.shared.debug(message)
        }
    #endif
}

enum LogCategory {
    case game
    case physics
    case audio
    case input
    case ecs
}
