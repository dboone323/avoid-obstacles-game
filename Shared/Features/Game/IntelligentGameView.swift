//
//  IntelligentGameView.swift
//  AvoidObstaclesGame
//
//  Created on February 10, 2026
//  Phase 7: Advanced Features Integration
//
//  This view demonstrates the integration of machine learning,
//  advanced analytics, and intelligent features into the game UI.
//

import Shared_Kit
import SwiftUI

struct IntelligentGameView: View {
    @State private var viewModel = IntelligentGameViewModel()
    @State private var showInsights = false
    @State private var showRecommendations = false

    var body: some View {
        ZStack {
            // Game background
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Header with intelligent features
                headerView

                // Game area
                gameArea

                // Intelligent controls
                intelligentControls

                // Recommendations overlay
                if showRecommendations && !viewModel.recommendedActions.isEmpty {
                    recommendationsOverlay
                }
            }
        }
        .sheet(isPresented: $showInsights) {
            insightsView
        }
        .onAppear {
            Task {
                await viewModel.startGame()
            }
        }
        .onDisappear {
            Task {
                await viewModel.endGame()
            }
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Intelligent Avoid Obstacles")
                    .font(.title2)
                    .foregroundColor(.white)

                HStack {
                    Text("Score: \(viewModel.currentScore)")
                        .foregroundColor(.white)

                    Spacer()

                    Text("Difficulty: \(viewModel.personalizedDifficulty.rawValue.capitalized)")
                        .foregroundColor(.yellow)

                    Spacer()

                    Button(action: { showInsights.toggle() }, label: {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.blue)
                    })
                }
            }
        }
        .padding()
    }

    // MARK: - Game Area

    private var gameArea: some View {
        ZStack {
            // Game field
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 400)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )

            VStack {
                if viewModel.isGameActive {
                    Text("🎮 Game Active")
                        .font(.largeTitle)
                        .foregroundColor(.white)

                    // Player representation
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 30, height: 30)
                        .position(viewModel.playerPosition)
                        .animation(.easeInOut, value: viewModel.playerPosition)

                    // Adaptive elements indicator
                    HStack {
                        ForEach(viewModel.adaptiveElements, id: \.type) { element in
                            Circle()
                                .fill(Color.green.opacity(element.intensity))
                                .frame(width: 10, height: 10)
                        }
                    }
                    .padding(.top, 300)
                } else {
                    VStack(spacing: 20) {
                        Text("🚀 Ready to Play")
                            .font(.largeTitle)
                            .foregroundColor(.white)

                        Button(action: {
                            Task {
                                await viewModel.startGame()
                            }
                        }, label: {
                            Text("Start Intelligent Game")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        })
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Intelligent Controls

    private var intelligentControls: some View {
        HStack(spacing: 20) {
            // Recommendations button
            Button(action: { showRecommendations.toggle() }, label: {
                VStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.title)
                    Text("Tips")
                        .font(.caption)
                }
                .foregroundColor(.yellow)
                .padding()
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(10)
            })

            // Analytics button
            Button(action: { showInsights.toggle() }, label: {
                VStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.title)
                    Text("Stats")
                        .font(.caption)
                }
                .foregroundColor(.green)
                .padding()
                .background(Color.green.opacity(0.2))
                .cornerRadius(10)
            })

            // Security status
            VStack {
                Image(systemName: viewModel.isBiometricEnabled ? "lock.fill" : "lock.open")
                    .font(.title)
                    .foregroundColor(viewModel.isBiometricEnabled ? .green : .red)
                Text("Security")
                    .font(.caption)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
        }
    }

    // MARK: - Recommendations Overlay

    private var recommendationsOverlay: some View {
        VStack {
            Text("🤖 AI Recommendations")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(viewModel.recommendedActions, id: \.title) { recommendation in
                        recommendationCard(for: recommendation)
                    }
                }
                .padding()
            }

            Button(action: { showRecommendations = false }, label: {
                Text("Dismiss")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            })
            .padding(.bottom)
        }
        .background(Color.black.opacity(0.8))
        .cornerRadius(20)
        .padding()
        .frame(maxHeight: 300)
    }

    private func recommendationCard(for recommendation: GameRecommendation) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(recommendation.title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(recommendation.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }

            Spacer()

            priorityIndicator(for: recommendation.priority)
        }
        .padding()
        .background(Color.gray.opacity(0.3))
        .cornerRadius(10)
    }

    private func priorityIndicator(for priority: GameRecommendation.Priority) -> some View {
        Circle()
            .fill(priorityColor(for: priority))
            .frame(width: 12, height: 12)
    }

    private func priorityColor(for priority: GameRecommendation.Priority) -> Color {
        switch priority {
        case .high: .red
        case .medium: .yellow
        case .low: .green
        }
    }

    // MARK: - Insights View

    private var insightsView: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("🧠 Player Insights")
                        .font(.largeTitle)
                        .foregroundColor(.white)

                    // Current session stats
                    if let analytics = viewModel.sessionAnalytics {
                        sessionStatsCard(analytics: analytics)
                    }

                    // Behavior patterns
                    behaviorPatternsCard

                    // Player insights
                    playerInsightsCard

                    // Security status
                    securityStatusCard
                }
                .padding()
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationBarItems(trailing: Button(action: { showInsights = false }, label: {
                Text("Done")
            }))
        }
    }

    private func sessionStatsCard(analytics: GameSessionAnalytics) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("📊 Session Statistics")
                .font(.title2)
                .foregroundColor(.white)

            HStack {
                statItem(label: "Duration", value: String(format: "%.1f", analytics.duration))
                statItem(label: "Events", value: "\(analytics.events)")
                statItem(label: "Score", value: "\(analytics.score)")
            }

            HStack {
                statItem(label: "Obstacles Avoided", value: "\(analytics.obstaclesAvoided)")
                statItem(label: "Power-ups", value: "\(analytics.powerUpsCollected)")
            }
        }
        .padding()
        .background(Color.blue.opacity(0.2))
        .cornerRadius(15)
    }

    private func statItem(label: String, value: String) -> some View {
        VStack {
            Text(value)
                .font(.title)
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }

    private var behaviorPatternsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("🎯 Behavior Patterns")
                .font(.title2)
                .foregroundColor(.white)

            if viewModel.behaviorPatterns.isEmpty {
                Text("No behavior patterns analyzed yet")
                    .foregroundColor(.gray)
            } else {
                ForEach(viewModel.behaviorPatterns, id: \.patternType) { pattern in
                    HStack {
                        Text(pattern.patternType.description)
                        Spacer()
                        Text(String(format: "Confidence: %.1f%%", pattern.confidence * 100))
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.2))
        .cornerRadius(15)
    }

    private var playerInsightsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("💡 AI Insights")
                .font(.title2)
                .foregroundColor(.white)

            if viewModel.playerInsights.isEmpty {
                Text("Play more to generate insights!")
                    .foregroundColor(.gray)
            } else {
                ForEach(viewModel.playerInsights, id: \.self) { insight in
                    Text("• \(insight)")
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color.purple.opacity(0.2))
        .cornerRadius(15)
    }

    private var securityStatusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("🔒 Security Status")
                .font(.title2)
                .foregroundColor(.white)

            HStack {
                Image(systemName: viewModel.isBiometricEnabled ? "checkmark.shield.fill" : "xmark.shield")
                    .foregroundColor(viewModel.isBiometricEnabled ? .green : .red)

                Text(viewModel.isBiometricEnabled
                    ? "Biometric authentication available"
                    : "Biometric authentication not available")
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.red.opacity(0.2))
        .cornerRadius(15)
    }
}

// MARK: - Extensions

extension Difficulty {
    var rawValue: String {
        switch self {
        case .easy: "easy"
        case .normal: "normal"
        case .hard: "hard"
        }
    }
}

extension BehaviorPattern.PatternType {
    var description: String {
        switch self {
        case .timeBased: "Time-based activity"
        case .locationBased: "Location-based activity"
        case .activityBased: "Activity patterns"
        case .socialBased: "Social interactions"
        }
    }
}

#Preview {
    IntelligentGameView()
}
