//
// AssetCache.swift
// AvoidObstaclesGame
//

import SpriteKit

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

class AssetCache {
    static let shared = AssetCache()

    private var textures: [String: SKTexture] = [:]
    private var sounds: [String: SKAction] = [:]
    private var particles: [String: SKEmitterNode] = [:]

    private init() {}

    func preloadAssets() {
        // Preload common textures
        preloadTexture("player", color: PlatformColor.blue, size: CGSize(width: 50, height: 50))
        preloadTexture("obstacle", color: PlatformColor.red, size: CGSize(width: 40, height: 40))
        preloadTexture("powerup", color: PlatformColor.green, size: CGSize(width: 30, height: 30))

        // Preload sounds
        preloadSound("collision", filename: "collision.wav")
        preloadSound("powerup", filename: "powerup.wav")
        preloadSound("score", filename: "score.wav")
    }

    func texture(named name: String) -> SKTexture? {
        textures[name]
    }

    func sound(named name: String) -> SKAction? {
        sounds[name]
    }

    private func preloadTexture(_ name: String, color: PlatformColor, size: CGSize) {
        #if os(iOS)
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if let image {
            textures[name] = SKTexture(image: image)
        }
        #elseif os(macOS)
        let image = NSImage(size: size)
        image.lockFocus()
        color.setFill()
        NSRect(origin: .zero, size: size).fill()
        image.unlockFocus()
        textures[name] = SKTexture(image: image)
        #endif
    }

    private func preloadSound(_ name: String, filename: String) {
        sounds[name] = SKAction.playSoundFileNamed(filename, waitForCompletion: false)
    }

    func clearCache() {
        textures.removeAll()
        sounds.removeAll()
        particles.removeAll()
    }
}

