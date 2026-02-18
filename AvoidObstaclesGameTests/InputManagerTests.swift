//
// InputManagerTests.swift
// AvoidObstaclesGameTests
//

import SpriteKit
import XCTest

@testable import AvoidObstaclesGame

@MainActor
final class InputManagerTests: XCTestCase {
    func testInputInit() {
        let manager = InputManager.shared
        XCTAssertNotNil(manager)
    }

    func testTouchInput() {
        let manager = InputManager.shared
        let scene = SKScene(size: CGSize(width: 100, height: 100))

        var movedValue: CGFloat?
        manager.onMove = { movedValue = $0 }

        manager.setMode(.tap)
        manager.handleTouch(CGPoint(x: 50, y: 50), in: scene)

        XCTAssertEqual(movedValue, 0.5, "Touch at center should result in 0.5 normalized X")
    }

    func testControlModeSwitching() {
        let manager = InputManager.shared
        manager.setMode(.tilt)
        // Verify no crash on mode switch
        XCTAssertNotNil(manager)
    }

    #if os(macOS)
        func testKeyboardInputFallback() {
            let manager = InputManager.shared
            manager.setMode(.tilt)

            var movedValue: CGFloat?
            manager.onMove = { movedValue = $0 }

            // Mock keyboard event for Left Arrow (keyCode 123)
            let event = NSEvent.keyEvent(
                with: .keyDown,
                location: .zero,
                modifierFlags: [],
                timestamp: 0,
                windowNumber: 0,
                context: nil,
                characters: "",
                charactersIgnoringModifiers: "",
                isARepeat: false,
                keyCode: 123
            )!

            manager.handleKeyboard(event: event)
            XCTAssertLessThan(movedValue ?? 0.5, 0.5, "Left arrow should decrease tilt value")
        }
    #endif
}
