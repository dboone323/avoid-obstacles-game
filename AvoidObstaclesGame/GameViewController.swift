//
// GameViewController.swift
// AvoidObstaclesGame
//
// Standard ViewController to load and present the GameScene.
//

import GameplayKit
import SpriteKit
#if os(iOS)
    import UIKit

    /// The main view controller for AvoidObstaclesGame.
    /// Responsible for loading and presenting the SpriteKit game scene.
    public class GameViewController: UIViewController {
        private var hasSetupScene = false
        
        /// Called to load the view.
        /// Sets up the SKView.
        override public func loadView() {
            let skView = SKView(frame: .zero)
            self.view = skView
        }

        /// Called after the controller's view is loaded into memory.
        override public func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemCyan
        }
        
        /// Called after the view's bounds change. Present scene here to ensure valid size.
        override public func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            // Only setup scene once after bounds are valid
            guard !hasSetupScene, view.bounds.size.width > 0, view.bounds.size.height > 0 else { return }
            hasSetupScene = true
            
            // Configure the view as an SKView and present the game scene.
            if let skView = view as? SKView {
                // Create and configure the scene to fill the screen.
                let scene = GameScene(size: view.bounds.size)
                scene.scaleMode = .aspectFill
                
                GameLogger.shared.debug("🎮 Presenting scene with size: \(view.bounds.size)")

                // Present the scene.
                skView.presentScene(scene)

                // Optional: For performance tuning
                skView.ignoresSiblingOrder = true
                
                // Debug helpers
                #if DEBUG
                skView.showsFPS = true
                skView.showsNodeCount = true
                #endif
            }
        }

        /// Specifies the supported interface orientations for the game.
        /// - Returns: The allowed interface orientations depending on device type.
        override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            if UIDevice.current.userInterfaceIdiom == .phone {
                .allButUpsideDown
            } else {
                .all
            }
        }

        /// Hides the status bar for a more immersive game experience.
        override public var prefersStatusBarHidden: Bool {
            true
        }
    }

#elseif os(macOS)
    import Cocoa

    /// The main view controller for AvoidObstaclesGame.
    /// Responsible for loading and presenting the SpriteKit game scene.
    public class GameViewController: NSViewController {
        /// Called to load the view.
        /// Sets up the SKView.
        override public func loadView() {
            let skView = SKView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
            self.view = skView
        }

        /// Called after the controller's view is loaded into memory.
        /// Sets up and presents the main game scene.
        override public func viewDidLoad() {
            super.viewDidLoad()

            GameLogger.shared.debug("🎮 GameViewController.viewDidLoad() called")

            // Configure the view as an SKView and present the game scene.
            if let view = view as? SKView {
                GameLogger.shared.debug("🎮 View bounds: \\(view.bounds)")

                // Use the frame size set in loadView (800x600) instead of bounds
                let sceneSize = CGSize(width: 800, height: 600)
                GameLogger.shared.debug("🎮 Creating GameScene with size: \\(sceneSize)")

                // Create and configure the scene
                let scene = GameScene(size: sceneSize)
                scene.scaleMode = .aspectFill

                // Present the scene
                view.presentScene(scene)
                GameLogger.shared.debug("🎮 GameScene presented to view")

                // Optional: For performance tuning
                view.ignoresSiblingOrder = true

                // Optional: To see physics bodies and frame rate (uncomment to use)
                // view.showsPhysics = true
                // view.showsFPS = true
                // view.showsNodeCount = true
            }
        }
    }
#endif
