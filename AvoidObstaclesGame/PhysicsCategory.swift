//
// PhysicsCategory.swift
// AvoidObstaclesGame
//
// Defines physics category bitmasks for collision detection in SpriteKit.
//

import Foundation

/**
 Physics category bitmasks for collision detection and physics interactions.

 ## Overview
 SpriteKit uses bitmasks to determine how physics bodies interact with each other.
 Each physics body has three bitmask properties:
 - `categoryBitMask`: Defines what category this body belongs to
 - `contactTestBitMask`: Defines which categories this body should detect contacts with
 - `collisionBitMask`: Defines which categories this body should physically collide with

 ## Bitmask Values
 Each category uses a unique power of 2 (bit position) to allow combining categories:
 - `none`: 0 (no category)
 - `player`: 1 << 0 (bit 0 = 1)
 - `obstacle`: 1 << 1 (bit 1 = 2)
 - `powerUp`: 1 << 2 (bit 2 = 4)

 ## Usage Example
 ```swift
 // Player setup: Player detects contacts with obstacles and power-ups
 player.physicsBody?.categoryBitMask = PhysicsCategory.player
 player.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.powerUp
 player.physicsBody?.collisionBitMask = PhysicsCategory.none // No physical collision

 // Obstacle setup: Obstacle detects contact with player only
 obstacle.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
 obstacle.physicsBody?.contactTestBitMask = PhysicsCategory.player
 obstacle.physicsBody?.collisionBitMask = PhysicsCategory.none
 ```

 ## Collision Matrix
 | Category | Detects Contact With | Physically Collides With |
 |----------|---------------------|--------------------------|
 | Player   | Obstacle, PowerUp   | None                     |
 | Obstacle | Player              | None                     |
 | PowerUp  | Player              | None                     |

 - Note: None of the objects physically collide (all use `PhysicsCategory.none` for collisionBitMask)
         because we want to detect contacts for game logic only, not physical bouncing.
 */
enum PhysicsCategory {
    static let none: UInt32 = 0 // 0
    static let player: UInt32 = 0b1 // Binary 1 (decimal 1)
    static let obstacle: UInt32 = 0b10 // Binary 2 (decimal 2)
    static let powerUp: UInt32 = 0b100 // Binary 4 (decimal 4)
    static let boundary: UInt32 = 0b1000 // Binary 8 (decimal 8)
}
