// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "AvoidObstaclesGame",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "AvoidObstaclesGameCore",
            targets: ["AvoidObstaclesGameCore"]
        )
    ],
    dependencies: [
        .package(path: "../shared-kit")
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
    ]
)
