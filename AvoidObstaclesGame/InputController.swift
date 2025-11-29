import SpriteKit

/// Handles all player input (touch and keyboard)
class InputController {
    weak var playerNode: SKNode?
    private var touchLocation: CGPoint?
    
    // Input settings
    var touchSensitivity: CGFloat = 1.0
    var keyboardSpeed: CGFloat = 300.0
    
    // Active keys (for keyboard)
    #if os(macOS)
    private var activeKeys: Set<KeyCode> = []
    #endif
    
    init(playerNode: SKNode) {
        self.playerNode = playerNode
    }
    
    // MARK: - Touch Input
    
    func handleTouchBegan(_ touch: UITouch, in scene: SKScene) {
        touchLocation = touch.location(in: scene)
    }
    
    func handleTouchMoved(_ touch: UITouch, in scene: SKScene) {
        touchLocation = touch.location(in: scene)
        updatePlayerPosition()
    }
    
    func handleTouchEnded(_ touch: UITouch, in scene: SKScene) {
        touchLocation = nil
    }
    
    private func updatePlayerPosition() {
        guard let player = playerNode,
              let target = touchLocation else { return }
        
        // Smooth movement toward touch
        let dx = (target.x - player.position.x) * touchSensitivity * 0.1
        let dy = (target.y - player.position.y) * touchSensitivity * 0.1
        
        player.position.x += dx
        player.position.y += dy
    }
    
    // MARK: - Keyboard Input (macOS)
    
    #if os(macOS)
    func handleKeyDown(_ event: NSEvent) {
        guard let key = KeyCode.from(event) else { return }
        activeKeys.insert(key)
    }
    
    func handleKeyUp(_ event: NSEvent) {
        guard let key = KeyCode.from(event) else { return }
        activeKeys.remove(key)
    }
    
    func update(deltaTime: TimeInterval) {
        guard let player = playerNode else { return }
        
        var dx: CGFloat = 0
        var dy: CGFloat = 0
        
        if activeKeys.contains(.left) || activeKeys.contains(.a) {
            dx -= keyboardSpeed * CGFloat(deltaTime)
        }
        if activeKeys.contains(.right) || activeKeys.contains(.d) {
            dx += keyboardSpeed * CGFloat(deltaTime)
        }
        if activeKeys.contains(.up) || activeKeys.contains(.w) {
            dy += keyboardSpeed * CGFloat(deltaTime)
        }
        if activeKeys.contains(.down) || activeKeys.contains(.s) {
            dy -= keyboardSpeed * CGFloat(deltaTime)
        }
        
        player.position.x += dx
        player.position.y += dy
    }
    #endif
    
    // MARK: - Gestures
    
    func handleSwipe(direction: SwipeDirection, velocity: CGFloat) {
        guard let player = playerNode else { return }
        
        let force: CGFloat = 500 * velocity
        
        switch direction {
        case .up:
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: force))
        case .down:
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -force))
        case .left:
            player.physicsBody?.applyImpulse(CGVector(dx: -force, dy: 0))
        case .right:
            player.physicsBody?.applyImpulse(CGVector(dx: force, dy: 0))
        }
    }
    
    // MARK: - Input Modes
    
    enum InputMode {
        case touch      // Follow touch location
        case drag       // Drag player directly
        case relative   // Relative to player (joystick-style)
    }
    
    var inputMode: InputMode = .touch
    
    func setInputMode(_ mode: InputMode) {
        inputMode = mode
        touchLocation = nil
    }
}

// MARK: - Key Codes

#if os(macOS)
enum KeyCode: UInt16 {
    case w = 13
    case a = 0
    case s = 1
    case d = 2
    case up = 126
    case down = 125
    case left = 123
    case right = 124
    case space = 49
    
    static func from(_ event: NSEvent) -> KeyCode? {
        KeyCode(rawValue: event.keyCode)
    }
}
#endif

enum SwipeDirection {
    case up, down, left, right
}
