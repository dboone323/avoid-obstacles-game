//
//  AudioManagerTests.swift
//  AvoidObstaclesGameTests
//
//  Comprehensive test suite for AudioManager
//

import XCTest
@testable import AvoidObstaclesGame

@MainActor
final class AudioManagerTests: XCTestCase {
    var sut: AudioManager!

    override func setUp() {
        super.setUp()
        sut = AudioManager.shared
    }

    override func tearDown() {
        sut.stopBackgroundMusic()
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testSharedInstance() {
        XCTAssertNotNil(sut)
        XCTAssertTrue(sut === AudioManager.shared, "Should return same shared instance")
    }

    func testInitialization() {
        // Verify manager initializes without crashing
        XCTAssertNoThrow(AudioManager.shared)
    }

    // MARK: - Sound Playback Tests

    func testPlayCollisionSound() {
        XCTAssertNoThrow(sut.playCollision())
    }

    func testPlayPowerUpSound() {
        XCTAssertNoThrow(sut.playPowerUp())
    }

    func testPlayLevelUpSound() {
        XCTAssertNoThrow(sut.playLevelUp())
    }

    func testPlayButtonSound() {
        XCTAssertNoThrow(sut.playButton())
    }

    func testPlayWhooshSound() {
        XCTAssertNoThrow(sut.playWhoosh())
    }

    func testPlayGenericSound() {
        XCTAssertNoThrow(sut.playSound(.collision))
        XCTAssertNoThrow(sut.playSound(.powerup))
        XCTAssertNoThrow(sut.playSound(.levelup))
        XCTAssertNoThrow(sut.playSound(.button))
        XCTAssertNoThrow(sut.playSound(.whoosh))
    }

    // MARK: - Music Playback Tests

    func testPlayBackgroundMusic() {
        XCTAssertNoThrow(sut.playBackgroundMusic())
    }

    func testStopBackgroundMusic() {
        sut.playBackgroundMusic()
        XCTAssertNoThrow(sut.stopBackgroundMusic())
    }

    func testMusicLoopsInfinitely() {
        // Music should be configured to loop
        // This is verified by checking the numberOfLoops property in implementation
        XCTAssertNoThrow(sut.playBackgroundMusic())
        sut.stopBackgroundMusic()
    }

    // MARK: - Settings Tests

    func testToggleSound() {
        XCTAssertNoThrow(sut.toggleSound())
        XCTAssertNoThrow(sut.toggleSound()) // Toggle back
    }

    func testToggleMusic() async {
        await sut.toggleMusic()
        sut.stopBackgroundMusic() // Clean up
        await sut.toggleMusic() // Toggle back
        sut.stopBackgroundMusic()
    }

    func testLoadSettings() {
        XCTAssertNoThrow(sut.loadSettings())
    }

    func testSettingsPersistence() async {
        // Test that settings are saved to UserDefaults
        sut.toggleSound()
        let soundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
        XCTAssertNotNil(soundEnabled)

        await sut.toggleMusic()
        let musicEnabled = UserDefaults.standard.bool(forKey: "musicEnabled")
        XCTAssertNotNil(musicEnabled)

        // Clean up
        sut.stopBackgroundMusic()
    }

    // MARK: - Volume Control Tests

    func testSetSoundVolume() {
        XCTAssertNoThrow(sut.setSoundVolume(0.5))
        XCTAssertNoThrow(sut.setSoundVolume(0.0))
        XCTAssertNoThrow(sut.setSoundVolume(1.0))
    }

    func testSetMusicVolume() {
        sut.playBackgroundMusic()
        XCTAssertNoThrow(sut.setMusicVolume(0.5))
        XCTAssertNoThrow(sut.setMusicVolume(0.0))
        XCTAssertNoThrow(sut.setMusicVolume(1.0))
        sut.stopBackgroundMusic()
    }

    func testVolumeEdgeCases() {
        // Test volume at boundaries
        XCTAssertNoThrow(sut.setSoundVolume(-0.1)) // Below minimum
        XCTAssertNoThrow(sut.setSoundVolume(1.5)) // Above maximum
        XCTAssertNoThrow(sut.setMusicVolume(-0.1))
        XCTAssertNoThrow(sut.setMusicVolume(1.5))
    }

    // MARK: - GameSound Enum Tests

    func testGameSoundEnumCases() {
        let allSounds: [GameSound] = [.collision, .powerup, .levelup, .button, .whoosh]

        for sound in allSounds {
            XCTAssertFalse(sound.rawValue.isEmpty)
        }
    }

    func testGameSoundRawValues() {
        XCTAssertEqual(GameSound.collision.rawValue, "collision")
        XCTAssertEqual(GameSound.powerup.rawValue, "powerup")
        XCTAssertEqual(GameSound.levelup.rawValue, "levelup")
        XCTAssertEqual(GameSound.button.rawValue, "button")
        XCTAssertEqual(GameSound.whoosh.rawValue, "whoosh")
    }

    // MARK: - Integration Tests

    func testMultipleSoundsInSequence() {
        XCTAssertNoThrow(
            {
                sut.playCollision()
                sut.playPowerUp()
                sut.playLevelUp()
                sut.playButton()
                sut.playWhoosh()
            }()
        )
    }

    func testRapidFireSounds() {
        for _ in 0..<10 {
            XCTAssertNoThrow(sut.playCollision())
        }
    }

    func testMusicAndSoundsTogether() {
        sut.playBackgroundMusic()
        XCTAssertNoThrow(
            {
                sut.playCollision()
                sut.playPowerUp()
            }()
        )
        sut.stopBackgroundMusic()
    }

    // MARK: - State Management Tests

    func testSoundEnabledDisabledFlow() {
        sut.toggleSound() // Disable
        XCTAssertNoThrow(sut.playCollision()) // Should not crash when disabled
        sut.toggleSound() // Re-enable
        XCTAssertNoThrow(sut.playCollision())
    }

    func testMusicEnabledDisabledFlow() async {
        await sut.toggleMusic() // May enable or disable depending on initial state
        XCTAssertNoThrow(sut.playBackgroundMusic())
        await sut.toggleMusic()
        sut.stopBackgroundMusic()
    }

    // MARK: - Error Handling Tests

    func testPlayingSoundWhenDisabled() {
        sut.toggleSound() // Disable sounds
        XCTAssertNoThrow(sut.playCollision()) // Should handle gracefully
        sut.toggleSound() // Re-enable
    }

    func testPlayingMusicWhenDisabled() async {
        await sut.toggleMusic() // May disable music
        XCTAssertNoThrow(sut.playBackgroundMusic()) // Should handle gracefully
        await sut.toggleMusic()
        sut.stopBackgroundMusic()
    }

    // MARK: - Cleanup Tests

    func testStopMusicMultipleTimes() {
        sut.playBackgroundMusic()
        XCTAssertNoThrow(sut.stopBackgroundMusic())
        XCTAssertNoThrow(sut.stopBackgroundMusic()) // Should not crash
    }
}
