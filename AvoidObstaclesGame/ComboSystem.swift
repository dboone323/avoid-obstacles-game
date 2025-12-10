//
// ComboSystem.swift
// AvoidObstaclesGame
//

import Foundation

class ComboSystem {
    static let shared = ComboSystem()

    private var currentCombo = 0
    private var lastDodgeTime: TimeInterval = 0
    private let comboTimeout: TimeInterval = 2.0

    var onComboChanged: ((Int, Int) -> Void)? // combo, points
    var onComboLost: (() -> Void)?

    func recordDodge(currentTime: TimeInterval) {
        if currentTime - lastDodgeTime > comboTimeout {
            currentCombo = 0
        }

        currentCombo += 1
        lastDodgeTime = currentTime

        let points = calculatePoints()
        onComboChanged?(currentCombo, points)

        if #available(iOS 10.0, *), currentCombo % 5 == 0 {
            HapticFeedbackManager.shared.success()
        }
    }

    func resetCombo() {
        if currentCombo > 0 {
            onComboLost?()
            currentCombo = 0
        }
    }

    func calculatePoints() -> Int {
        // Exponential scoring
        currentCombo * (1 + currentCombo / 10)
    }

    func getMultiplier() -> Double {
        1.0 + Double(currentCombo) * 0.1
    }

    func getCurrentCombo() -> Int {
        currentCombo
    }
}
