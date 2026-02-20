//
// SkinManagerTests.swift
// AvoidObstaclesGameTests
//
// Tests for player skin management and unlocking
//

import XCTest
@testable import AvoidObstaclesGame

@MainActor

final class SkinManagerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Reset to default state
        UserDefaults.standard.removeObject(forKey: "unlockedSkins")
        UserDefaults.standard.removeObject(forKey: "selectedSkin")
    }

    // MARK: - PlayerSkin Tests

    func testDefaultSkinExists() {
        XCTAssertNotNil(PlayerSkin.default)
        XCTAssertEqual(PlayerSkin.default.id, "default")
        XCTAssertEqual(PlayerSkin.default.name, "Default")
    }

    func testAllSkinsCount() {
        XCTAssertEqual(PlayerSkin.allSkins.count, 6)
    }

    func testSkinFromId() {
        let blue = PlayerSkin.fromId("blue")
        XCTAssertNotNil(blue)
        XCTAssertEqual(blue?.name, "Ocean Blue")
    }

    func testSkinFromInvalidId() {
        let invalid = PlayerSkin.fromId("nonexistent")
        XCTAssertNil(invalid)
    }

    func testBlueSkinProperties() {
        XCTAssertEqual(PlayerSkin.blue.id, "blue")
        XCTAssertNotNil(PlayerSkin.blue.trailColor)
        XCTAssertFalse(PlayerSkin.blue.hasGlow)
    }

    func testGoldSkinHasGlow() {
        XCTAssertTrue(PlayerSkin.gold.hasGlow)
    }

    func testCosmicSkinProperties() {
        XCTAssertEqual(PlayerSkin.cosmic.id, "cosmic")
        XCTAssertEqual(PlayerSkin.cosmic.name, "Cosmic")
        XCTAssertTrue(PlayerSkin.cosmic.hasGlow)
    }

    // MARK: - SkinManager Tests

    func testDefaultSkinIsUnlocked() {
        let manager = SkinManager.shared
        XCTAssertTrue(manager.isUnlocked(.default))
    }

    func testGetAvailableSkins() {
        let manager = SkinManager.shared
        let available = manager.getAvailableSkins()
        XCTAssertEqual(available.count, 6)
    }

    func testUnlockProgressForDefault() {
        let manager = SkinManager.shared
        let progress = manager.unlockProgress(for: .default)
        // Default requires 0 score, so always complete
        XCTAssertEqual(progress, 1.0)
    }

    func testGetUnlockedSkinsIncludesDefault() {
        let manager = SkinManager.shared
        let unlocked = manager.getUnlockedSkins()
        XCTAssertTrue(unlocked.contains(.default))
    }

    // MARK: - Skin Hashable Conformance

    func testSkinEquality() throws {
        let skin1 = PlayerSkin.blue
        let skin2 = try XCTUnwrap(PlayerSkin.fromId("blue"))
        XCTAssertEqual(skin1, skin2)
    }

    func testSkinInSet() {
        var skinSet = Set<PlayerSkin>()
        skinSet.insert(.blue)
        skinSet.insert(.red)
        XCTAssertEqual(skinSet.count, 2)
        XCTAssertTrue(skinSet.contains(.blue))
    }
}
