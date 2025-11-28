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
        
        public func application(
            _: UIApplication,
            didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
            // Scene-based lifecycle - window is managed by SceneDelegate
            return true
        }
        
        // MARK: UISceneSession Lifecycle
        
        public func application(
            _ application: UIApplication,
            configurationForConnecting connectingSceneSession: UISceneSession,
            options: UIScene.ConnectionOptions
        ) -> UISceneConfiguration {
            // Called when a new scene session is being created.
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        }
    }
    
    // MARK: - Scene Delegate
    
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

    @main
    public class AppDelegate: NSObject, NSApplicationDelegate {
        public var window: NSWindow?

        public func applicationDidFinishLaunching(_ notification: Notification) {
            print("🪟 AppDelegate.applicationDidFinishLaunching called")
            
            // Create the main window
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.center()
            window.title = "Avoid Obstacles Game"
            print("🪟 Window created - frame: \(window.frame)")

            // Create GameViewController
            let gameVC = GameViewController()
            window.contentViewController = gameVC
            print("🪟 GameViewController set as contentViewController")

            // Make window visible and activate app
            window.makeKeyAndOrderFront(nil)
            print("🪟 makeKeyAndOrderFront called")
            NSApp.activate(ignoringOtherApps: true)
            print("🪟 NSApp activated")
            
            self.window = window
            print("🪟 Window assigned to self.window")
        }

        public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
            return true
        }

        public func applicationWillTerminate(_: Notification) {
            // Insert code here to tear down your application
        }
    }
#endif
