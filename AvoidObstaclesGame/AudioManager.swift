import AVFoundation

/// Manages sound effects for the game
class AudioManager {
    @MainActor static let shared = AudioManager()

    private var soundPlayers: [String: AVAudioPlayer] = [:]
    private var musicPlayer: AVAudioPlayer?

    private var isSoundEnabled = true
    private var isMusicEnabled = true

    private init() {
        preloadSounds()
    }

    // MARK: - Sound Preloading

    private func preloadSounds() {
        let soundFiles = [
            "collision": "collision.wav",
            "powerup": "powerup.wav",
            "levelup": "levelup.wav",
            "button": "button.wav",
            "whoosh": "whoosh.wav",
        ]

        for (key, filename) in soundFiles {
            if let url = Bundle.main.url(forResource: filename, withExtension: nil) {
                if let player = try? AVAudioPlayer(contentsOf: url) {
                    player.prepareToPlay()
                    soundPlayers[key] = player
                }
            }
        }
    }

    // MARK: - Sound Playback

    func playSound(_ sound: GameSound) {
        guard isSoundEnabled else { return }

        soundPlayers[sound.rawValue]?.play()
    }

    func playCollision() {
        playSound(.collision)
    }

    func playPowerUp() {
        playSound(.powerup)
    }

    func playLevelUp() {
        playSound(.levelup)
    }

    func playButton() {
        playSound(.button)
    }

    func playWhoosh() {
        playSound(.whoosh)
    }

    // MARK: - Music Playback

    @MainActor
    func playBackgroundMusic() {
        guard isMusicEnabled else { return }

        if let url = Bundle.main.url(forResource: "background.mp3", withExtension: nil) {
            do {
                musicPlayer = try AVAudioPlayer(contentsOf: url)
                musicPlayer?.numberOfLoops = -1 // Infinite loop
                musicPlayer?.volume = 0.3
                musicPlayer?.play()
            } catch {
                GameLogger.shared.error("Error playing music: \(error)")
            }
        }
    }

    func stopBackgroundMusic() {
        musicPlayer?.stop()
    }

    // MARK: - Settings

    func toggleSound() {
        isSoundEnabled.toggle()
        UserDefaults.standard.set(isSoundEnabled, forKey: "soundEnabled")
    }

    func toggleMusic() async {
        isMusicEnabled.toggle()
        UserDefaults.standard.set(isMusicEnabled, forKey: "musicEnabled")

        if isMusicEnabled {
            await playBackgroundMusic()
        } else {
            stopBackgroundMusic()
        }
    }

    func loadSettings() {
        isSoundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
        isMusicEnabled = UserDefaults.standard.bool(forKey: "musicEnabled")
    }

    // MARK: - Volume Control

    func setSoundVolume(_ volume: Float) {
        for (_, player) in soundPlayers {
            player.volume = volume
        }
    }

    func setMusicVolume(_ volume: Float) {
        musicPlayer?.volume = volume
    }
}

enum GameSound: String {
    case collision
    case powerup
    case levelup
    case button
    case whoosh
}
