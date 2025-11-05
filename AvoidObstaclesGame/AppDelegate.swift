//
//  AppDelegate.swift
//  AvoidObstaclesGame
//
//  Created by Daniel Stevens on 5/16/25.
//

#if os(iOS)
import UIKit

@main
public class AppDelegate: UIResponder, UIApplicationDelegate {
    public var window: UIWindow?

    public func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Create the main window
        let window = UIWindow()
        window.rootViewController = GameViewController()
        window.makeKeyAndVisible()
        self.window = window

        // Override point for customization after application launch.
        return true
    }

    public func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state.
        // This can occur for certain types of temporary interruptions (such as an
        // incoming phone call or SMS message) or when the user quits the application
        // and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate
        // graphics rendering callbacks. Games should use this method to pause the game.
    }

    public func applicationDidEnterBackground(_: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough application state information to restore your application to its
        // current state in case it is terminated later.
    }

    public func applicationWillEnterForeground(_: UIApplication) {
        // Called as part of the transition from the background to the active state;
        // here you can undo many of the changes made on entering the background.
    }

    public func applicationDidBecomeActive(_: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application
        // was inactive. If the application was previously in the background, optionally
        // refresh the user interface.
    }
}
#elseif os(macOS)
import Cocoa
import SpriteKit

@main
public class AppDelegate: NSObject, NSApplicationDelegate {
    public var window: NSWindow?

    public func applicationDidFinishLaunching(_: Notification) {
        // Create the main window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Avoid Obstacles Game"

        // Create GameViewController
        let gameVC = GameViewController()
        window.contentViewController = gameVC

        window.makeKeyAndOrderFront(nil)
        self.window = window
    }

    public func applicationWillTerminate(_: Notification) {
        // Insert code here to tear down your application
    }
}
#endif
