//
//  main.swift
//  AvoidObstaclesGame
//
//  Explicit entry point for the application.
//  Using explicit main instead of @main to ensure proper app lifecycle.
//

import Foundation

#if os(iOS)
    import UIKit

    // iOS entry point
    _ = UIApplicationMain(
        CommandLine.argc,
        CommandLine.unsafeArgv,
        nil,
        NSStringFromClass(AppDelegate.self)
    )

#elseif os(macOS)
    import AppKit

    // macOS entry point - manually set up the app delegate
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate

    // Activate the app
    app.setActivationPolicy(.regular)
    app.activate(ignoringOtherApps: true)

    // Run the app
    app.run()

#endif
