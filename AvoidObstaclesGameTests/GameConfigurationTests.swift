//
// GameConfigurationTests.swift
// AvoidObstaclesGameTests
//
// Unit tests for GameConfiguration
//

import XCTest
@testable import AvoidObstaclesGame

class GameConfigurationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Reset configuration before each test
        GameConfiguration.reset()
    }
    
    override func tearDown() {
        GameConfiguration.reset()
        super.tearDown()
    }
    
    // MARK: - Default Configuration Tests
    
    func testDefaultConfiguration() {
        let config = GameConfiguration.default
        
        // Player defaults
        XCTAssertEqual(config.player.size.width, 50)
        XCTAssertEqual(config.player.size.height, 50)
        XCTAssertEqual(config.player.maxSpeed, 500)
        
        // Obstacle defaults
        XCTAssertEqual(config.obstacle.poolSize, 20)
        
        // Audio defaults
        XCTAssertTrue(config.audio.backgroundMusicEnabled)
        XCTAssertTrue(config.audio.soundEffectsEnabled)
        XCTAssertEqual(config.audio.backgroundMusicVolume, 0.6, accuracy: 0.01)
        
        // Visual defaults
        XCTAssertEqual(config.visual.theme, "auto")
        XCTAssertEqual(config.visual.frameRateCap, 60)
    }
    
    // MARK: - Persistence Tests
    
    func testSaveAndLoad() {
        var config = GameConfiguration.default
        
        // Modify configuration
        var modifiedAudio = config.audio
        modifiedAudio = GameConfiguration.Audio(
            backgroundMusicEnabled: false,
            soundEffectsEnabled: true,
            backgroundMusicVolume: 0.3,
            soundEffectsVolume: 0.9,
            hapticsEnabled: false
        )
        
        let modifiedConfig = GameConfiguration(
            player: config.player,
            obstacle: config.obstacle,
            difficulty: config.difficulty,
            audio: modifiedAudio,
            accessibility: config.accessibility,
            visual: config.visual
        )
        
        // Save modified configuration
        modifiedConfig.save()
        
        // Load configuration
        let loadedConfig = GameConfiguration.load()
        
        // Verify changes persisted
        XCTAssertFalse(loadedConfig.audio.backgroundMusicEnabled)
        XCTAssertEqual(loadedConfig.audio.backgroundMusicVolume, 0.3, accuracy: 0.01)
        XCTAssertFalse(loadedConfig.audio.hapticsEnabled)
    }
    
    func testReset() {
        // Save modified configuration
        var config = GameConfiguration.default
        var modifiedAudio = config.audio
        modifiedAudio = GameConfiguration.Audio(
            backgroundMusicEnabled: false,
            soundEffectsEnabled: false,
            backgroundMusicVolume: 0.1,
            soundEffectsVolume: 0.1,
            hapticsEnabled: false
        )
        
        GameConfiguration(
            player: config.player,
            obstacle: config.obstacle,
            difficulty: config.difficulty,
            audio: modifiedAudio,
            accessibility: config.accessibility,
            visual: config.visual
        ).save()
        
        // Reset
        GameConfiguration.reset()
        
        // Load should return default
        let loadedConfig = GameConfiguration.load()
        XCTAssertTrue(loadedConfig.audio.backgroundMusicEnabled)
        XCTAssertEqual(loadedConfig.audio.backgroundMusicVolume, 0.6, accuracy: 0.01)
    }
    
    // MARK: - Dark Mode Tests
    
    func testDarkModeDetection() {
        var config = GameConfiguration.default
        
        // Test explicit dark mode
        var darkVisual = config.visual
        darkVisual = GameConfiguration.Visual(
            theme: "dark",
            particleQuality: "high",
            frameRateCap: 60,
            showFPS: false
        )
        
        let darkConfig = GameConfiguration(
            player: config.player,
            obstacle: config.obstacle,
            difficulty: config.difficulty,
            audio: config.audio,
            accessibility: config.accessibility,
            visual: darkVisual
        )
        
        XCTAssertTrue(darkConfig.isDarkMode)
        
        // Test explicit light mode
        var lightVisual = config.visual
        lightVisual = GameConfiguration.Visual(
            theme: "light",
            particleQuality: "high",
            frameRateCap: 60,
            showFPS: false
        )
        
        let lightConfig = GameConfiguration(
            player: config.player,
            obstacle: config.obstacle,
            difficulty: config.difficulty,
            audio: config.audio,
            accessibility: config.accessibility,
            visual: lightVisual
        )
        
        XCTAssertFalse(lightConfig.isDarkMode)
    }
    
    // MARK: - Accessibility Tests
    
    func testReduceMotionDetection() {
        var config = GameConfiguration.default
        
        // Enable reduce motion
        var modifiedAccessibility = config.accessibility
        modifiedAccessibility = GameConfiguration.Accessibility(
            reduceMotion: true,
            increaseContrast: false,
            largerTouchTargets: false,
            voiceOverEnabled: false,
            colorBlindMode: "none"
        )
        
        let modifiedConfig = GameConfiguration(
            player: config.player,
            obstacle: config.obstacle,
            difficulty: config.difficulty,
            audio: config.audio,
            accessibility: modifiedAccessibility,
            visual: config.visual
        )
        
        XCTAssertTrue(modifiedConfig.shouldReduceMotion)
    }
    
    func testColorBlindModes() {
        let config = GameConfiguration.default
        
        // Test all colorblind modes
        let modes = ["protanopia", "deuteranopia", "tritanopia"]
        
        for mode in modes {
            var modifiedAccessibility = config.accessibility
            modifiedAccessibility = GameConfiguration.Accessibility(
                reduceMotion: false,
                increaseContrast: false,
                largerTouchTargets: false,
                voiceOverEnabled: false,
                colorBlindMode: mode
            )
            
            let modifiedConfig = GameConfiguration(
                player: config.player,
                obstacle: config.obstacle,
                difficulty: config.difficulty,
                audio: config.audio,
                accessibility: modifiedAccessibility,
                visual: config.visual
            )
            
            XCTAssertEqual(modifiedConfig.accessibility.colorBlindMode, mode)
        }
    }
    
    // MARK: - Difficulty Tests
    
    func testDifficultyLevels() {
        let config = GameConfiguration.default
        
        // Verify we have multiple difficulty levels
        XCTAssertGreaterThan(config.difficulty.levels.count, 1)
        
        // Verify difficulty progression
        for i in 0..<config.difficulty.levels.count - 1 {
            let current = config.difficulty.levels[i]
            let next = config.difficulty.levels[i + 1]
            
            // Score threshold should increase
            XCTAssertLessThan(current.scoreThreshold, next.scoreThreshold)
            
            // Spawn interval should decrease (faster spawning)
            XCTAssertGreaterThan(current.spawnInterval, next.spawnInterval)
            
            // Score multiplier should increase
            XCTAssertLessThan(current.scoreMultiplier, next.scoreMultiplier)
        }
    }
    
    // MARK: - Color Utility Tests
    
    func testHexColorConversion() {
        let config = GameConfiguration.default
        
        // Test valid hex color
        let blue = config.color(from: "#007AFF")
        XCTAssertNotNil(blue)
        
        // Test without hash
        let red = config.color(from: "FF0000")
        XCTAssertNotNil(red)
        
        // Colors should not be equal
        XCTAssertNotEqual(blue, red)
    }
    
    // MARK: - Performance Tests
    
    func testLoadPerformance() {
        measure {
            _ = GameConfiguration.load()
        }
    }
    
    func testSavePerformance() {
        let config = GameConfiguration.default
        
        measure {
            config.save()
        }
    }
}
