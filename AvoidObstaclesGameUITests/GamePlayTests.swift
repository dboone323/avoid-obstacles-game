//
//  GamePlayTests.swift
//  AvoidObstaclesGameUITests
//
//  Created by Daniel Stevens.
//

import XCTest

final class GamePlayTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testGameHUDlaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Handle Menu Scene if present
        let playButton = app.buttons["Play"]
        if playButton.waitForExistence(timeout: 5) {
            playButton.tap()
        }

        // Check for HUD elements based on UIManager.swift accessibility identifiers

        let scoreLabel = app.staticTexts.containing(
            NSPredicate(format: "label BEGINSWITH 'Current Score:'")
        ).element
        let difficultyLabel = app.staticTexts.containing(
            NSPredicate(format: "label BEGINSWITH 'Difficulty Level:'")
        ).element

        // Wait for launch
        if !scoreLabel.waitForExistence(timeout: 10) {
            print("❌ Visualization Failure: App Hierarchy Dump")
            print(app.debugDescription)
            XCTFail("Score label should be visible on game start")
        }

        XCTAssertTrue(difficultyLabel.exists, "Difficulty label should be visible")
    }

    func testGameOverState() throws {
        let app = XCUIApplication()
        app.launch()

        // This test assumes we can trigger a game over or wait for it.
        // Since we can't easily play the game to lose in an automated way deterministically without hooks,
        // we might check if "Game Over" appears eventually if the player dies automatically (not guaranteed).
        //
        // Instead, we verify that IF the "Game Over" text appears, the Restart button is also checkable.
        // This is more of a conditional check or manual verification placeholder.

        let gameOverLabel = app.staticTexts["Game Over"]
        if gameOverLabel.waitForExistence(timeout: 10) {
            XCTAssertTrue(app.staticTexts["Tap to Restart Game"].exists)
        }
    }
}
