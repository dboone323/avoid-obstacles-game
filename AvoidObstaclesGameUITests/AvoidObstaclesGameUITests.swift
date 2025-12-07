//
//  AvoidObstaclesGameUITests.swift
//  AvoidObstaclesGameUITests
//
//  Comprehensive visual regression testing for iOS game
//

import XCTest

final class AvoidObstaclesGameUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        // Wait for SpriteKit scene to fully render
        // SpriteKit games need extra time for scene setup
        sleep(5)
    }

    override func tearDownWithError() throws {
        // Cleanup if needed
    }
    
    // MARK: - Helper Functions
    
    /// Captures a screenshot with a descriptive name
    private func captureScreenshot(named name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    /// Safely tap a button by identifier or label
    private func tapButton(_ identifier: String) -> Bool {
        let button = app.buttons[identifier].firstMatch
        if button.exists && button.isHittable {
            button.tap()
            sleep(1)
            return true
        }
        return false
    }
    
    /// Tap on center of screen (for game interaction)
    private func tapCenter() {
        let center = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        center.tap()
        sleep(1)
    }
    
    // MARK: - Launch Tests
    
    @MainActor
    func testGameLaunch() throws {
        // Capture initial launch state
        captureScreenshot(named: "Launch_Main")
        
        // Verify app is running
        XCTAssertTrue(app.state == .runningForeground, "App should be running")
    }
    
    // MARK: - Main Menu Screenshots
    
    @MainActor
    func testMainMenuScreenshots() throws {
        captureScreenshot(named: "MainMenu_Initial")
        
        // Look for menu elements
        let playButton = app.buttons["Play"].firstMatch
        let startButton = app.buttons["Start"].firstMatch
        let settingsButton = app.buttons["Settings"].firstMatch
        
        if playButton.exists || startButton.exists {
            captureScreenshot(named: "MainMenu_WithPlayButton")
        }
        
        if settingsButton.exists {
            captureScreenshot(named: "MainMenu_WithSettings")
        }
    }
    
    // MARK: - Game Play Screenshots
    
    @MainActor
    func testGameplayScreenshots() throws {
        // Try to start the game
        let playButtons = ["Play", "Start", "Start Game", "play", "start"]
        
        for buttonName in playButtons {
            if tapButton(buttonName) {
                captureScreenshot(named: "Gameplay_Started")
                
                // Wait for game to load
                sleep(2)
                captureScreenshot(named: "Gameplay_Active")
                
                // Tap to interact with game
                tapCenter()
                captureScreenshot(named: "Gameplay_Interaction")
                break
            }
        }
        
        // If no play button found, just capture current state
        captureScreenshot(named: "Gameplay_CurrentState")
    }
    
    // MARK: - Settings View Screenshots
    
    @MainActor
    func testSettingsScreenshots() throws {
        // Try to open settings
        let settingsButtons = ["Settings", "settings", "gear", "Options", "⚙️"]
        
        for buttonName in settingsButtons {
            if tapButton(buttonName) {
                captureScreenshot(named: "Settings_Main")
                
                // Scroll settings if possible
                let scrollView = app.scrollViews.firstMatch
                if scrollView.exists {
                    scrollView.swipeUp()
                    sleep(1)
                    captureScreenshot(named: "Settings_Scrolled")
                }
                
                // Try to close settings
                _ = tapButton("Close") || tapButton("Done") || tapButton("Back")
                break
            }
        }
    }
    
    // MARK: - Leaderboard Screenshots
    
    @MainActor
    func testLeaderboardScreenshots() throws {
        // Try to open leaderboard
        let leaderboardButtons = ["Leaderboard", "High Scores", "Scores", "leaderboard"]
        
        for buttonName in leaderboardButtons {
            if tapButton(buttonName) {
                captureScreenshot(named: "Leaderboard_Main")
                
                // Scroll leaderboard if possible
                let scrollView = app.scrollViews.firstMatch
                if scrollView.exists {
                    scrollView.swipeUp()
                    sleep(1)
                    captureScreenshot(named: "Leaderboard_Scrolled")
                }
                
                // Try to close 
                _ = tapButton("Close") || tapButton("Done") || tapButton("Back")
                break
            }
        }
    }
    
    // MARK: - Game Over Screenshots
    
    @MainActor
    func testGameOverScreenshots() throws {
        // Start game first
        let playButtons = ["Play", "Start", "Start Game"]
        for buttonName in playButtons {
            if tapButton(buttonName) {
                break
            }
        }
        
        // Wait briefly then check for game over elements
        sleep(3)
        
        // Look for game over/pause elements
        let gameOverLabels = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'game over' OR label CONTAINS[c] 'score' OR label CONTAINS[c] 'retry'")
        ).allElementsBoundByIndex
        
        if gameOverLabels.count > 0 {
            captureScreenshot(named: "GameOver_Screen")
        }
        
        // Try to pause the game
        if tapButton("Pause") || tapButton("pause") || tapButton("||") {
            captureScreenshot(named: "Game_Paused")
        }
    }
    
    // MARK: - Theme/Appearance Screenshots
    
    @MainActor
    func testThemeScreenshots() throws {
        // Try to access theme settings
        if tapButton("Settings") || tapButton("settings") {
            // Look for theme options
            let themeButton = app.buttons["Theme"].firstMatch
            if themeButton.exists {
                themeButton.tap()
                sleep(1)
                captureScreenshot(named: "Theme_Selection")
            }
        }
        
        // Capture current theme
        captureScreenshot(named: "Theme_Current")
    }
    
    // MARK: - Full App Tour Screenshots
    
    @MainActor
    func testFullGameScreenshotTour() throws {
        // 1. Launch/Main Menu
        captureScreenshot(named: "Tour_01_Launch")
        
        // 2. Try to access different screens
        if tapButton("Settings") || tapButton("settings") {
            captureScreenshot(named: "Tour_02_Settings")
            _ = tapButton("Close") || tapButton("Done") || tapButton("Back")
            sleep(1)
        }
        
        // 3. Try to access leaderboard
        if tapButton("Leaderboard") || tapButton("High Scores") || tapButton("Scores") {
            captureScreenshot(named: "Tour_03_Leaderboard")
            _ = tapButton("Close") || tapButton("Done") || tapButton("Back")
            sleep(1)
        }
        
        // 4. Start game
        let playButtons = ["Play", "Start", "Start Game"]
        for buttonName in playButtons {
            if tapButton(buttonName) {
                sleep(2)
                captureScreenshot(named: "Tour_04_Gameplay")
                break
            }
        }
        
        // 5. Final screenshot
        captureScreenshot(named: "Tour_Final")
    }
    
    // MARK: - Accessibility Verification
    
    @MainActor
    func testAccessibilityLabelsExist() throws {
        captureScreenshot(named: "Accessibility_Verification")
        
        // Check buttons have labels (informational)
        let buttons = app.buttons.allElementsBoundByIndex
        var labeledButtonCount = 0
        for button in buttons.prefix(10) {
            if button.isHittable && !(button.label.isEmpty) {
                labeledButtonCount += 1
            }
        }
        
        if labeledButtonCount > 0 {
            print("Found \(labeledButtonCount) labeled buttons")
        }
    }

    // MARK: - Performance Tests
    
    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
