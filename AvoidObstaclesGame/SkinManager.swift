import SpriteKit

/// Manages player appearance customization
class SkinManager {
    @MainActor static let shared = SkinManager()

    private var currentSkin: PlayerSkin = .default
    private var unlockedSkins: Set<PlayerSkin> = [.default]

    private init() {
        loadUnlockedSkins()
    }

    // MARK: - Skin Application

    @MainActor func applySkin(_ skin: PlayerSkin, to node: SKSpriteNode) {
        guard unlockedSkins.contains(skin) else {
            GameLogger.shared.debug("Skin \(skin.name) is locked")
            return
        }

        currentSkin = skin

        // Apply visual changes
        node.color = skin.color
        node.colorBlendFactor = 0.8

        // Add particle trail if skin has one
        if let trailColor = skin.trailColor {
            addTrailEffect(to: node, color: trailColor)
        }

        // Apply glow effect if skin has glow
        if skin.hasGlow {
            addGlowEffect(to: node)
        }

        // Save preference
        UserDefaults.standard.set(skin.id, forKey: "selectedSkin")
    }

    // MARK: - Skin Unlocking

    func unlockSkin(_ skin: PlayerSkin) {
        unlockedSkins.insert(skin)
        saveUnlockedSkins()

        // Show unlock animation
        NotificationCenter.default.post(
            name: .skinUnlocked,
            object: skin
        )
    }

    func isUnlocked(_ skin: PlayerSkin) -> Bool {
        unlockedSkins.contains(skin)
    }

    func unlockProgress(for skin: PlayerSkin) -> Double {
        let requiredScore = getScoreRequired(for: skin)
        let currentScore = UserDefaults.standard.integer(forKey: "highScore")
        return min(1.0, Double(currentScore) / Double(requiredScore))
    }

    // MARK: - Available Skins

    func getAvailableSkins() -> [PlayerSkin] {
        PlayerSkin.allSkins
    }

    func getUnlockedSkins() -> [PlayerSkin] {
        Array(unlockedSkins)
    }

    func getLockedSkins() -> [PlayerSkin] {
        PlayerSkin.allSkins.filter { !unlockedSkins.contains($0) }
    }

    // MARK: - Effects

    private func addTrailEffect(to node: SKNode, color: SKColor) {
        let trail = SKEmitterNode()
        trail.particleTexture = SKTexture(imageNamed: "particle")
        trail.particleBirthRate = 100
        trail.particleLifetime = 0.5
        trail.particleColor = color
        trail.particleAlpha = 0.6
        trail.particleScale = 0.1
        trail.particleSpeed = 0
        trail.particleSpeedRange = 20
        trail.emissionAngleRange = .pi * 2
        trail.name = "trail"
        trail.targetNode = node.parent
        trail.zPosition = -1
        node.addChild(trail)
    }

    @MainActor private func addGlowEffect(to node: SKNode) {
        let glow = SKEffectNode()
        glow.shouldRasterize = true
        glow.filter = CIFilter(name: "CIBloom", parameters: [
            "inputIntensity": 0.5,
            "inputRadius": 10.0,
        ])
        node.parent?.addChild(glow)
        glow.addChild(node)
    }

    // MARK: - Persistence

    private func saveUnlockedSkins() {
        let skinIds = unlockedSkins.map(\.id)
        UserDefaults.standard.set(skinIds, forKey: "unlockedSkins")
    }

    private func loadUnlockedSkins() {
        if let savedIds = UserDefaults.standard.array(forKey: "unlockedSkins") as? [String] {
            unlockedSkins = Set(savedIds.compactMap { PlayerSkin.fromId($0) })
        }
    }

    private func getScoreRequired(for skin: PlayerSkin) -> Int {
        switch skin {
        case .default: 0
        case .blue: 100
        case .red: 500
        case .gold: 1000
        case .rainbow: 5000
        case .cosmic: 10000
        default: 100_000 // Fallback for unknown skins
        }
    }
}

// MARK: - Player Skin Definition

struct PlayerSkin: Hashable {
    let id: String
    let name: String
    let color: SKColor
    let trailColor: SKColor?
    let hasGlow: Bool

    static let `default` = PlayerSkin(
        id: "default",
        name: "Default",
        color: .white,
        trailColor: nil,
        hasGlow: false
    )

    static let blue = PlayerSkin(
        id: "blue",
        name: "Ocean Blue",
        color: .cyan,
        trailColor: .blue,
        hasGlow: false
    )

    static let red = PlayerSkin(
        id: "red",
        name: "Fire Red",
        color: .red,
        trailColor: .orange,
        hasGlow: true
    )

    static let gold = PlayerSkin(
        id: "gold",
        name: "Golden",
        color: .yellow,
        trailColor: .orange,
        hasGlow: true
    )

    static let rainbow = PlayerSkin(
        id: "rainbow",
        name: "Rainbow",
        color: .magenta,
        trailColor: .cyan,
        hasGlow: true
    )

    static let cosmic = PlayerSkin(
        id: "cosmic",
        name: "Cosmic",
        color: .purple,
        trailColor: .white,
        hasGlow: true
    )

    static let allSkins: [PlayerSkin] = [
        .default, .blue, .red, .gold, .rainbow, .cosmic,
    ]

    static func fromId(_ id: String) -> PlayerSkin? {
        allSkins.first { $0.id == id }
    }
}

extension Notification.Name {
    static let skinUnlocked = Notification.Name("skinUnlocked")
}
