// swift-tools-version: 6.0
// AvoidObstaclesGame - Mobile Game
// Copyright © 2025 AvoidObstaclesGame. All rights reserved.

import PackageDescription

let package = Package(
    name: "AvoidObstaclesGame",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "AvoidObstaclesGame",
            targets: ["AvoidObstaclesGameCore"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AvoidObstaclesGameCore",
            dependencies: [],
            path: "AvoidObstaclesGame",
            exclude: ["Info.plist", "Preview Content", "Assets.xcassets"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "AvoidObstaclesGameTests",
            dependencies: ["AvoidObstaclesGameCore"],
            path: "AvoidObstaclesGameTests"
        )
    ]
)
