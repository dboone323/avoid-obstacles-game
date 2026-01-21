//
//  AppDelegate.swift
//  AvoidObstaclesGame
//
//  Created by Daniel Stevens on 5/16/25.
//

#if os(iOS)
    import UIKit

    public class AppDelegate: UIResponder, UIApplicationDelegate {
        public var window: UIWindow?

        public func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
            // Window creation is handled by SceneDelegate
            // (configured via configurationForConnecting with delegateClass = SceneDelegate.self)
            true
        }

        // MARK: UISceneSession Lifecycle

        public func application(
            _ application: UIApplication,
            configurationForConnecting connectingSceneSession: UISceneSession,
            options: UIScene.ConnectionOptions
        ) -> UISceneConfiguration {
            // Create scene configuration and specify our SceneDelegate
            let config = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
            config.delegateClass = SceneDelegate.self
            return config
        }
    }

    // MARK: - Scene Delegate (kept for future use if scene manifest is configured)

    public class SceneDelegate: UIResponder, UIWindowSceneDelegate {
        public var window: UIWindow?

        public func scene(
            _ scene: UIScene,
            willConnectTo session: UISceneSession,
            options connectionOptions: UIScene.ConnectionOptions
        ) {
            guard let windowScene = (scene as? UIWindowScene) else { return }

            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = GameViewController()
            window.makeKeyAndVisible()
            self.window = window
        }

        public func sceneWillResignActive(_ scene: UIScene) {
            // Pause the game when scene becomes inactive
        }

        public func sceneDidBecomeActive(_ scene: UIScene) {
            // Restart any paused tasks
        }
    }

#elseif os(macOS)
    import Cocoa
    import SpriteKit

    public class AppDelegate: NSObject, NSApplicationDelegate {
        public var window: NSWindow?

        public func applicationDidFinishLaunching(_ notification: Notification) {
            GameLogger.shared.debug("🪟 AppDelegate.applicationDidFinishLaunching called")

            // Create the main window
            let window = NSWindow(
                contentRect: NSRect(x: 100, y: 100, width: 800, height: 600),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.isReleasedWhenClosed = false
            window.title = "Avoid Obstacles Game"
            GameLogger.shared.debug("🪟 Window created")

            // Create GameViewController
            let gameVC = GameViewController()
            gameVC.view.wantsLayer = true // Required for proper rendering
            window.contentViewController = gameVC
            GameLogger.shared.debug("🪟 GameViewController set")

            // Store window reference BEFORE making visible
            self.window = window

            // Make window visible
            window.center()
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
            NSApp.activate(ignoringOtherApps: true)
            GameLogger.shared.debug("🪟 Window should now be visible - frame: \(window.frame)")
        }

        public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
            true
        }

        public func applicationWillTerminate(_: Notification) {
            // Insert code here to tear down your application
        }
    }
#endif
