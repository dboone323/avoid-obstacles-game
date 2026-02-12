//
// ComboSystem.swift
// AvoidObstaclesGame
//
// Enhanced combo system for tracking consecutive obstacle dodges

import Foundation

class ComboSystem {
    @MainActor static let shared = ComboSystem()

    private var currentCombo = 0
    private var bestCombo = 0
    private var lastDodgeTime: TimeInterval = 0
    private let comboTimeout: TimeInterval = 2.0
    private var totalDodges = 0

    var onComboChanged: ((Int, Int) -> Void)? // combo, points
    var onComboLost: (() -> Void)?
    var onComboMilestone: ((Int) -> Void)? // Called at 5, 10, 25, 50 combo

    private init() {
        loadBestCombo()
    }

    @MainActor
    func recordDodge(currentTime: TimeInterval) {
        if currentTime - lastDodgeTime > comboTimeout {
            currentCombo = 0
        }

        currentCombo += 1
        totalDodges += 1
        lastDodgeTime = currentTime

        // Update best combo
        if currentCombo > bestCombo {
            bestCombo = currentCombo
            saveBestCombo()
        }

        let points = calculatePoints()
        onComboChanged?(currentCombo, points)

        // Check for milestones
        let milestones = [5, 10, 25, 50, 100]
        if milestones.contains(currentCombo) {
            onComboMilestone?(currentCombo)
            HapticFeedbackManager.shared.success()
        } else if currentCombo % 5 == 0 {
            HapticFeedbackManager.shared.selection()
        }
    }

    func resetCombo() {
        if currentCombo > 0 {
            onComboLost?()
            currentCombo = 0
        }
    }

    func calculatePoints() -> Int {
        // CHANGED: Linear scoring to fix rapid difficulty progression
        // 1 point base + 1 extra point for every 10 combo
        1 + (currentCombo / 10)
    }

    func getMultiplier() -> Double {
        1.0 + Double(currentCombo) * 0.15
    }

    func getCurrentCombo() -> Int {
        currentCombo
    }

    func getBestCombo() -> Int {
        bestCombo
    }

    func getTotalDodges() -> Int {
        totalDodges
    }

    // MARK: - Persistence

    private func loadBestCombo() {
        bestCombo = UserDefaults.standard.integer(forKey: "bestCombo")
    }

    private func saveBestCombo() {
        UserDefaults.standard.set(bestCombo, forKey: "bestCombo")
    }

    func resetStats() {
        currentCombo = 0
        totalDodges = 0
    }
}
