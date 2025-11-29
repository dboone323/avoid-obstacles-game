//
// PowerUpSystem.swift
// AvoidObstaclesGame  
//

import Foundation

enum PowerUpType: String, CaseIterable {
    case shield, speed, magnet, slowMotion, doublePoints
}

class PowerUpSystem {
    static let shared = PowerUpSystem()
    
    private var activePowerUps: [String: Date] = [:]
    
    func activate(_ type: PowerUpType, duration: TimeInterval = 5.0) {
        activePowerUps[type.rawValue] = Date().addingTimeInterval(duration)
        
        switch type {
        case .shield:
            NotificationCenter.default.post(name: .powerUpActivated, object: type)
        case .speed:
            NotificationCenter.default.post(name: .powerUpActivated, object: type)
        case .magnet:
            NotificationCenter.default.post(name: .powerUpActivated, object: type)
        case .slowMotion:
            NotificationCenter.default.post(name: .powerUpActivated, object: type)
        case .doublePoints:
            NotificationCenter.default.post(name: .powerUpActivated, object: type)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.deactivate(type)
        }
    }
    
    func deactivate(_ type: PowerUpType) {
        activePowerUps.removeValue(forKey: type.rawValue)
        NotificationCenter.default.post(name: .powerUpDeactivated, object: type)
    }
    
    func isActive(_ type: PowerUpType) -> Bool {
        guard let expiry = activePowerUps[type.rawValue] else { return false }
        return expiry > Date()
    }
    
    func getScoreMultiplier() -> Double {
        return isActive(.doublePoints) ? 2.0 : 1.0
    }
}

extension Notification.Name {
    static let powerUpActivated = Notification.Name("PowerUpActivated")
    static let powerUpDeactivated = Notification.Name("PowerUpDeactivated")
}
