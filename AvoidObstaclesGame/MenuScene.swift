//
// MenuScene.swift
// AvoidObstaclesGame
//

import SpriteKit

class MenuScene: SKScene {
    private var playButton: SKLabelNode!
    private var settingsButton: SKLabelNode!
    private var leaderboardButton: SKLabelNode!
    private var titleLabel: SKLabelNode!
    
    var onPlay: (() -> Void)?
    var onSettings: (() -> Void)?
    var onLeaderboard: (() -> Void)?
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupUI()
        applyTheme()
    }
    
    private func setupBackground() {
        let theme = ThemeManager.shared.currentTheme
        backgroundColor = theme.backgroundColor
    }
    
    private func setupUI() {
        let theme = ThemeManager.shared.currentTheme
        
        titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Avoid Obstacles"
        titleLabel.fontSize = 48
        titleLabel.fontColor = theme.uiTextColor
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        addChild(titleLabel)
        
        playButton = createButton("Play", at: CGPoint(x: size.width / 2, y: size.height * 0.5))
        settingsButton = createButton("Settings", at: CGPoint(x: size.width / 2, y: size.height * 0.4))
        leaderboardButton = createButton("Leaderboard", at: CGPoint(x: size.width / 2, y: size.height * 0.3))
    }
    
    private func createButton(_ text: String, at position: CGPoint) -> SKLabelNode {
        let theme = ThemeManager.shared.currentTheme
        let button = SKLabelNode(fontNamed: "AvenirNext-Medium")
        button.text = text
        button.fontSize = 32
        button.fontColor = theme.accentColor
        button.position = position
        button.name = text.lowercased()
        addChild(button)
        return button
    }
    
    private func applyTheme() {
        ThemeManager.shared.applyTheme(to: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tapped = atPoint(location)
        
        if #available(iOS 10.0, *) {
            HapticFeedbackManager.shared.selection()
        }
        
        switch tapped.name {
        case "play": onPlay?()
        case "settings": onSettings?()
        case "leaderboard": onLeaderboard?()
        default: break
        }
    }
}
