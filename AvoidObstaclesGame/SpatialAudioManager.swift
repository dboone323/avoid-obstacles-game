//
// SpatialAudioManager.swift
// AvoidObstaclesGame
//

import AVFoundation
import SpriteKit

class SpatialAudioManager {
    @MainActor static let shared = SpatialAudioManager()

    private var audioEngine: AVAudioEngine?
    private var players: [String: AVAudioPlayerNode] = [:]
    private var environment: AVAudioEnvironmentNode?
    private var audioBuffers: [String: AVAudioPCMBuffer] = [:]

    @MainActor
    private init() {
        setupAudioEngine()
    }

    @MainActor
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        environment = AVAudioEnvironmentNode()

        guard let engine = audioEngine, let env = environment else { return }

        engine.attach(env)
        engine.connect(env, to: engine.mainMixerNode, format: nil)

        do {
            try engine.start()
        } catch {
            NSLog("[SpatialAudioManager] ERROR: Audio engine failed: \(error.localizedDescription)")
        }
    }

    @MainActor
    func playSound(_ name: String, at position: CGPoint, in scene: SKScene) {
        guard GameConfiguration.load().audio.soundEffectsEnabled else { return }
        guard let engine = audioEngine, let env = environment else { return }

        let x = Float((position.x / scene.size.width) * 2 - 1)
        let z = Float((position.y / scene.size.height) * 2 - 1) // Using Z for depth in spatial audio

        env.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)

        // Attempt to play from buffer if available, otherwise log and schedule
        if let buffer = audioBuffers[name] {
            let player = players[name] ?? AVAudioPlayerNode()
            if players[name] == nil {
                engine.attach(player)
                engine.connect(player, to: env, format: buffer.format)
                players[name] = player
            }

            if !player.isPlaying {
                player.play()
            }

            player.position = AVAudio3DPoint(x: x, y: 0, z: z)
            player.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        } else {
            // In a production environment, this would trigger an async load of the buffer.
            // For now, we log the spatial intent clearly.
            NSLog(
                "[SpatialAudioManager] LOG: Playing sound '\(name)' at spatial position (x: \(x), z: \(z))"
            )
        }
    }
}
