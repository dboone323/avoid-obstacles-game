//
// SpatialAudioManager.swift
// AvoidObstaclesGame
//

import AVFoundation
import SpriteKit

class SpatialAudioManager {
    static let shared = SpatialAudioManager()

    private var audioEngine: AVAudioEngine?
    private var players: [String: AVAudioPlayerNode] = [:]
    private var environment: AVAudioEnvironmentNode?

    private init() {
        setupAudioEngine()
    }

    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        environment = AVAudioEnvironmentNode()

        if let engine = audioEngine, let env = environment {
            engine.attach(env)
            engine.connect(env, to: engine.mainMixerNode, format: nil)

            do {
                try engine.start()
            } catch {
                GameLogger.shared.debug("Audio engine failed: \(error)")
            }
        }
    }

    func playSound(_ name: String, at position: CGPoint, in scene: SKScene) {
        guard GameConfiguration.load().audio.soundEffectsEnabled else { return }

        let x = Float((position.x / scene.size.width) * 2 - 1)
        let y = Float((position.y / scene.size.height) * 2 - 1)

        environment?.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)

        // In production, load actual audio files
        #if DEBUG
            GameLogger.shared.debug("🔊 Spatial audio: \(name) at (\(x), \(y))")
        #endif
    }
}
