// swift-tools-version: 6.2
import Foundation
import PackageDescription

private let localSharedKitPath = "../shared-kit"
private let sharedKitDependency: Package.Dependency = FileManager.default.fileExists(atPath: localSharedKitPath)
    ? .package(path: localSharedKitPath)
    : .package(url: "https://github.com/dboone323/shared-kit.git", branch: "main")

let package = Package(
    name: "AvoidObstaclesGame",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "AvoidObstaclesGameCore",
            targets: ["AvoidObstaclesGameCore"]
        ),
        .executable(
            name: "GameBalanceAudit",
            targets: ["GameBalanceAudit"]
        )
    ],
    dependencies: [
        sharedKitDependency
    ],
    targets: [
        .target(
            name: "AvoidObstaclesGameCore",
            dependencies: [
                .product(name: "SharedKit", package: "shared-kit")
            ],
            path: "AvoidObstaclesGame",
            exclude: [
                "Assets.xcassets",
                "en.lproj",
                "es.lproj",
                "fr.lproj",
                "GameScene.sks",
                "Actions.sks",
                "Info.plist.unused",
                "AvoidObstaclesGame.entitlements",
                "server.cer",
                "main.swift",
            ]
        ),
        .testTarget(
            name: "AvoidObstaclesGameTests",
            dependencies: ["AvoidObstaclesGameCore"],
            path: "AvoidObstaclesGameTests"
        ),
        .executableTarget(
            name: "GameBalanceAudit",
            dependencies: ["AvoidObstaclesGameCore"],
            path: "Tools",
            sources: ["GameBalanceAudit.swift"]
        ),
    ]
)
