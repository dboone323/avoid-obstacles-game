//
//  String+Localization.swift
//  AvoidObstaclesGame
//
//  Localization helper extension
//

import Foundation

extension String {
    /// Returns a localized version of the string
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    /// Returns a localized string with format arguments
    func localized(with arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }
}

// MARK: - Localization Keys

/// Centralized localization keys for type-safe access
enum L10n {
    enum App {
        static let name = "app.name".localized
        static let tagline = "app.tagline".localized
    }
    
    enum Menu {
        static let title = "menu.title".localized
        static let play = "menu.play".localized
        static let settings = "menu.settings".localized
        static let leaderboard = "menu.leaderboard".localized
        static let achievements = "menu.achievements".localized
        static let howToPlay = "menu.howToPlay".localized
    }
    
    enum Game {
        static func score(_ score: Int) -> String {
            "game.score".localized(with: score)
        }
        
        static func highScore(_ score: Int) -> String {
            "game.highScore".localized(with: score)
        }
        
        static func lives(_ lives: Int) -> String {
            "game.lives".localized(with: lives)
        }
        
        static func level(_ level: Int) -> String {
            "game.level".localized(with: level)
        }
        
        static let start = "game.start".localized
        static let pause = "game.pause".localized
        static let resume = "game.resume".localized
        static let restart = "game.restart".localized
        static let quit = "game.quit".localized
    }
    
    enum GameOver {
        static let title = "gameover.title".localized
        static let newHighScore = "gameover.newHighScore".localized
        static let playAgain = "gameover.playAgain".localized
        static let mainMenu = "gameover.mainMenu".localized
        static let share = "gameover.share".localized
        
        static func score(_ score: Int) -> String {
            "gameover.score".localized(with: score)
        }
    }
    
    enum PowerUp {
        static let shield = "powerup.shield".localized
        static let slowmo = "powerup.slowmo".localized
        static let magnet = "powerup.magnet".localized
        static let doublePoints = "powerup.doublePoints".localized
        static let extraLife = "powerup.extraLife".localized
    }
    
    enum Settings {
        static let title = "settings.title".localized
        static let sound = "settings.sound".localized
        static let music = "settings.music".localized
        static let vibration = "settings.vibration".localized
        static let controls = "settings.controls".localized
        static let theme = "settings.theme".localized
        static let difficulty = "settings.difficulty".localized
        static let reset = "settings.reset".localized
    }
    
    enum Achievement {
        static let unlocked = "achievement.unlocked".localized
    }
    
    enum Action {
        static let ok = "action.ok".localized
        static let cancel = "action.cancel".localized
        static let yes = "action.yes".localized
        static let no = "action.no".localized
        static let back = "action.back".localized
        static let close = "action.close".localized
    }
    
    enum Accessibility {
        static let playButton = "a11y.playButton".localized
        static let pauseButton = "a11y.pauseButton".localized
        static let obstacle = "a11y.obstacle".localized
        static let powerup = "a11y.powerup".localized
        
        static func scoreDisplay(_ score: Int) -> String {
            "a11y.scoreDisplay".localized(with: score)
        }
    }
}
