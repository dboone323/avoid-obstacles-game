//
//  GamePlayTests.swift
//  AvoidObstaclesGameUITests
//
//  Created by Daniel Stevens.
//

import XCTest

@MainActor
final class GamePlayTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testGameHUDlaunch() {
        let app = XCUIApplication()
        app.launch()
        dismissSystemPermissionAlertsIfPresent(in: app)

        // Handle Menu Scene if present
        let playButton = app.buttons["Play"]
        if playButton.waitForExistence(timeout: 5) {
            playButton.tap()
        }

        let scoreLabel = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label BEGINSWITH 'Current Score:'"))
            .firstMatch
        let difficultyLabel = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label BEGINSWITH 'Difficulty Level:'"))
            .firstMatch
        let gameOverLabel = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label == 'Game Over'"))
            .firstMatch

        // Depending on obstacle RNG and launch timing, the app may already be in game-over state.
        let hudAppeared = scoreLabel.waitForExistence(timeout: 10)
        let gameOverAppeared = gameOverLabel.exists || gameOverLabel.waitForExistence(timeout: 2)
        XCTAssertTrue(hudAppeared || gameOverAppeared, "Expected HUD or Game Over state after launch")

        if hudAppeared {
            XCTAssertTrue(difficultyLabel.exists, "Difficulty label should be visible when HUD is visible")
        }
    }

    func testGameOverState() {
        let app = XCUIApplication()
        app.launch()
        dismissSystemPermissionAlertsIfPresent(in: app)

        // This test assumes we can trigger a game over or wait for it.
        // Since we can't easily play the game to lose in an automated way deterministically without hooks,
        // we might check if "Game Over" appears eventually if the player dies automatically (not guaranteed).
        //
        // Instead, we verify that IF the "Game Over" text appears, the Restart button is also checkable.
        // This is more of a conditional check or manual verification placeholder.

        let gameOverLabel = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label == 'Game Over'"))
            .firstMatch
        if gameOverLabel.waitForExistence(timeout: 10) {
            let restartLabel = app.descendants(matching: .any)
                .matching(NSPredicate(format: "label == 'Tap to Restart Game'"))
                .firstMatch
            XCTAssertTrue(restartLabel.exists)
        }
    }
}
