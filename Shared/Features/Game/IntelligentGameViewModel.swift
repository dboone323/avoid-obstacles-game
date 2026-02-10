//
//  IntelligentGameViewModel.swift
//  AvoidObstaclesGame
//
//  Created on February 10, 2026
//  Phase 7: Advanced Features Integration
//
//  This view model demonstrates the integration of machine learning,
//  advanced analytics, and intelligent features into the game.
//

import Foundation
import SwiftUI
import Combine
import Shared_Kit

@MainActor
@Observable
final class IntelligentGameViewModel {
    // MARK: - Properties

    private let mlEngine = MachineLearningEngine.shared
    private let analyticsEngine = AnalyticsEngine.shared
    private let securityEngine = SecurityEngine.shared

    // Game state
    var currentScore: Int = 0
    var highScore: Int = 0
    var isGameActive: Bool = false
    var playerPosition: CGPoint = .zero
    var obstacles: [Obstacle] = []
    var powerUps: [PowerUp] = []

    // Intelligent features
    var personalizedDifficulty: Difficulty = .normal
    var recommendedActions: [GameRecommendation] = []
    var playerInsights: [String] = []
    var adaptiveElements: [AdaptiveElement] = []

    // Analytics
    var sessionAnalytics: GameSessionAnalytics?
    var behaviorPatterns: [BehaviorPattern] = []

    // Security
    var isBiometricEnabled: Bool = false
    var securityStatus: SecurityStatus = .unknown

    // MARK: - Initialization

    init() {
        setupIntelligentFeatures()
        loadPlayerData()
    }

    // MARK: - Game Logic

    func startGame() async {
        isGameActive = true
        currentScore = 0

        // Track game start event
        await trackEvent(.gameStarted)

        // Generate personalized difficulty
        await generatePersonalizedDifficulty()

        // Start adaptive elements
        await startAdaptiveElements()

        // Begin analytics collection
        startSessionAnalytics()
    }

    func endGame() async {
        isGameActive = false

        // Track game end event
        await trackEvent(.gameEnded, properties: ["score": currentScore, "duration": sessionAnalytics?.duration ?? 0])

        // Update high score if needed
        if currentScore > highScore {
            highScore = currentScore
            await trackEvent(.newHighScore, properties: ["score": highScore])
        }

        // Learn from this session
        await learnFromSession()

        // Generate insights
        await generatePlayerInsights()

        // End analytics collection
        endSessionAnalytics()
    }

    func updateGame(deltaTime: TimeInterval) async {
        guard isGameActive else { return }

        // Update adaptive elements
        await updateAdaptiveElements(deltaTime: deltaTime)

        // Generate real-time recommendations
        await generateRealTimeRecommendations()

        // Update analytics
        updateSessionAnalytics(deltaTime: deltaTime)
    }

    // MARK: - Intelligent Features

    private func setupIntelligentFeatures() {
        Task {
            // Check biometric availability
            let biometricAvailability = securityEngine.isBiometricAvailable()
            isBiometricEnabled = biometricAvailability.isAvailable

            // Load behavior patterns
            do {
                behaviorPatterns = try await analyticsEngine.getBehaviorPatterns(for: "current_user")
            } catch {
                print("Failed to load behavior patterns: \(error)")
            }

            // Generate initial recommendations
            await generateInitialRecommendations()
        }
    }

    private func generatePersonalizedDifficulty() async {
        do {
            // Use ML to predict optimal difficulty
            let context = UserContext(
                userId: "current_user",
                deviceType: .iPhone,
                location: nil,
                recentActions: [],
                appContext: AppContext(
                    appName: "AvoidObstaclesGame",
                    currentView: "GameView",
                    sessionDuration: 0,
                    previousActions: []
                )
            )

            let intent = try await mlEngine.predictUserIntent(from: context)

            // Adjust difficulty based on predicted intent
            switch intent {
            case .productivity:
                personalizedDifficulty = .hard
            case .health:
                personalizedDifficulty = .easy
            default:
                personalizedDifficulty = .normal
            }

            await trackEvent(.difficultyAdjusted, properties: ["difficulty": personalizedDifficulty.rawValue])
        } catch {
            print("Failed to generate personalized difficulty: \(error)")
            personalizedDifficulty = .normal
        }
    }

    private func startAdaptiveElements() async {
        // Create adaptive obstacles based on player behavior
        adaptiveElements = [
            AdaptiveElement(type: .dynamicObstacles, intensity: 0.5),
            AdaptiveElement(type: .powerUpPlacement, intensity: 0.7),
            AdaptiveElement(type: .speedVariation, intensity: 0.3)
        ]
    }

    private func updateAdaptiveElements(deltaTime: TimeInterval) async {
        for i in 0..<adaptiveElements.count {
            adaptiveElements[i].update(deltaTime: deltaTime, playerScore: currentScore)
        }
    }

    private func generateRealTimeRecommendations() async {
        var recommendations: [GameRecommendation] = []

        // Analyze current game state
        if currentScore > 100 && obstacles.count > 5 {
            recommendations.append(GameRecommendation(
                type: .usePowerUp,
                title: "Power Up Available",
                description: "Consider using a power up to clear obstacles",
                priority: .high
            ))
        }

        // Check player position patterns
        if playerPosition.x < 50 {
            recommendations.append(GameRecommendation(
                type: .moveRight,
                title: "Stay Centered",
                description: "Try moving more towards the center",
                priority: .medium
            ))
        }

        self.recommendedActions = recommendations
    }

    private func generateInitialRecommendations() async {
        do {
            let user = UserProfile(
                userId: "current_user",
                preferences: [:],
                behaviorPatterns: behaviorPatterns,
                demographics: nil,
                engagementHistory: []
            )

            let recommendations = try await mlEngine.generateRecommendations(for: user)

            // Convert to game recommendations
            self.recommendedActions = recommendations.map { rec in
                GameRecommendation(
                    type: .general,
                    title: rec.title,
                    description: rec.description,
                    priority: rec.impact == .high ? .high : .medium
                )
            }
        } catch {
            print("Failed to generate initial recommendations: \(error)")
        }
    }

    private func learnFromSession() async {
        guard let analytics = sessionAnalytics else { return }

        let interaction = UserInteraction(
            userId: "current_user",
            action: UserAction(type: .create, timestamp: Date(), context: "game_session"),
            context: UserContext(
                userId: "current_user",
                deviceType: .iPhone,
                location: nil,
                recentActions: [],
                appContext: AppContext(
                    appName: "AvoidObstaclesGame",
                    currentView: "GameView",
                    sessionDuration: analytics.duration,
                    previousActions: []
                )
            ),
            outcome: .success
        )

        await mlEngine.learn(from: interaction)
    }

    private func generatePlayerInsights() async {
        do {
            let timeRange = DateInterval(start: Date().addingTimeInterval(-7*24*60*60), end: Date())
            let insights = try await analyticsEngine.getInsights(for: "current_user", timeRange: timeRange)

            self.playerInsights = insights.summary.recommendations.map { $0.title }
        } catch {
            print("Failed to generate player insights: \(error)")
        }
    }

    // MARK: - Analytics

    private func startSessionAnalytics() {
        sessionAnalytics = GameSessionAnalytics(startTime: Date())
    }

    private func updateSessionAnalytics(deltaTime: TimeInterval) {
        sessionAnalytics?.duration += deltaTime
        sessionAnalytics?.events += 1
    }

    private func endSessionAnalytics() {
        sessionAnalytics?.endTime = Date()
    }

    private func trackEvent(_ event: GameEvent, properties: [String: Any] = [:]) async {
        let analyticsEvent = AnalyticsEvent(
            userId: "current_user",
            type: .custom(event.rawValue),
            properties: properties,
            sessionId: "game_session_\(Date().timeIntervalSince1970)",
            deviceInfo: DeviceInfo(
                model: "iPhone",
                osVersion: "17.0",
                appVersion: "1.0",
                screenSize: CGSize(width: 390, height: 844),
                locale: "en_US",
                timezone: .current
            ),
            context: EventContext(
                screenName: "GameView",
                userJourney: ["Menu", "Game"],
                campaignId: nil,
                referrer: nil
            )
        )

        await analyticsEngine.track(event: analyticsEvent)
    }

    // MARK: - Security

    func authenticateForHighScore() async -> Bool {
        guard isBiometricEnabled else { return true }

        do {
            return try await securityEngine.authenticateWithBiometrics(
                reason: "Authenticate to save high score"
            )
        } catch {
            print("Biometric authentication failed: \(error)")
            return false
        }
    }

    // MARK: - Data Management

    private func loadPlayerData() {
        // Load saved player data
        highScore = UserDefaults.standard.integer(forKey: "highScore")
        // Load other player preferences and data
    }

    func savePlayerData() {
        UserDefaults.standard.set(highScore, forKey: "highScore")
        // Save other player data
    }
}

// MARK: - Supporting Types

enum GameEvent: String {
    case gameStarted, gameEnded, newHighScore, difficultyAdjusted, powerUpUsed, obstacleAvoided
}

enum Difficulty {
    case easy, normal, hard
}

struct Obstacle {
    let position: CGPoint
    let size: CGSize
    let speed: CGFloat
}

struct PowerUp {
    let position: CGPoint
    let type: PowerUpType
    let duration: TimeInterval
}

enum PowerUpType {
    case shield, slowMotion, pointsMultiplier
}

struct GameRecommendation {
    let type: RecommendationType
    let title: String
    let description: String
    let priority: Priority

    enum RecommendationType {
        case usePowerUp, moveRight, general
    }

    enum Priority {
        case low, medium, high
    }
}

struct AdaptiveElement {
    var type: AdaptiveType
    var intensity: Double
    var lastUpdate: Date = Date()

    enum AdaptiveType {
        case dynamicObstacles, powerUpPlacement, speedVariation
    }

    mutating func update(deltaTime: TimeInterval, playerScore: Int) {
        // Update adaptive behavior based on game state
        let timeSinceUpdate = Date().timeIntervalSince(lastUpdate)

        if timeSinceUpdate > 5.0 { // Update every 5 seconds
            // Adjust intensity based on score
            if playerScore > 50 {
                intensity = min(intensity + 0.1, 1.0)
            } else if playerScore < 20 {
                intensity = max(intensity - 0.1, 0.1)
            }

            lastUpdate = Date()
        }
    }
}

struct GameSessionAnalytics {
    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval = 0
    var events: Int = 0
    var score: Int = 0
    var obstaclesAvoided: Int = 0
    var powerUpsCollected: Int = 0
}

enum SecurityStatus {
    case unknown, secure, compromised
}

// MARK: - Extensions

extension BiometricAvailability {
    var isAvailable: Bool {
        switch self {
        case .available: return true
        case .unavailable: return false
        }
    }
}
