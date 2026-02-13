//
// TutorialScene.swift
// AvoidObstaclesGame
//
// Interactive tutorial for first-time players
//

import SpriteKit

#if canImport(UIKit)
    import UIKit

    /// Interactive tutorial scene for onboarding new players
    class TutorialScene: SKScene {
        // MARK: - Tutorial Steps

        enum TutorialStep: Int, CaseIterable {
            case welcome = 0
            case movement
            case obstacles
            case powerUps
            case scoring
            case complete

            func getTitle() -> String {
                switch self {
                case .welcome:
                    "Welcome to Avoid Obstacles!"
                case .movement:
                    "Movement Controls"
                case .obstacles:
                    "Avoid Obstacles"
                case .powerUps:
                    "Collect Power-Ups"
                case .scoring:
                    "Score Points"
                case .complete:
                    "You're Ready!"
                }
            }

            var instruction: String {
                switch self {
                case .welcome:
                    "Welcome to Avoid Obstacles! Let's learn how to play."
                case .movement:
                    "Tap or drag to move your ship. Try moving left and right."
                case .obstacles:
                    "Red blocks are obstacles. Avoid them! Try dodging this one."
                case .powerUps:
                    "Blue items are power-ups. Collect them for bonuses!"
                case .scoring:
                    "Dodge obstacles and collect power-ups to score points."
                case .complete:
                    "Great job! You're ready to play. Tap to start!"
                }
            }
        }

        // MARK: - Properties

        private var currentStep: TutorialStep = .welcome
        private var titleLabel: SKLabelNode!
        private var instructionLabel: SKLabelNode!
        private var progressBar: SKShapeNode!
        private var skipButton: SKLabelNode!
        private var nextButton: SKLabelNode!

        private var player: SKSpriteNode?
        private var testObstacle: SKSpriteNode?
        private var testPowerUp: SKSpriteNode?

        private var movementDetected = false
        private var obstacleAvoided = false
        private var powerUpCollected = false

        private let config = GameConfiguration.load()
        private let haptics = HapticFeedbackManager.shared
        private let accessibility = AccessibilityManager.shared

        // Completion handler
        var onComplete: (() -> Void)?
        var onSkip: (() -> Void)?

        // MARK: - Scene Lifecycle

        override func didMove(to view: SKView) {
            super.didMove(to: view)

            setupBackground()
            setupUI()
            setupPlayer()

            startStep(currentStep)

            // Haptic feedback for tutorial start
            haptics.gameStart()
        }

        // MARK: - Setup

        private func setupBackground() {
            // Gradient background
            let isDark = config.isDarkMode
            backgroundColor = isDark ? .black : UIColor(white: 0.95, alpha: 1.0)

            // Add subtle pattern
            for i in 0..<5 {
                let line = SKShapeNode(rectOf: CGSize(width: size.width, height: 1))
                line.fillColor = isDark ? UIColor(white: 0.2, alpha: 0.3) : UIColor(white: 0.8, alpha: 0.3)
                line.position = CGPoint(x: size.width / 2, y: CGFloat(i) * size.height / 5)
                line.zPosition = -1
                addChild(line)
            }
        }

        private func setupUI() {
            let isDark = config.isDarkMode
            let textColor: UIColor = isDark ? .white : .black

            // Title label
            titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            titleLabel.fontSize = 32
            titleLabel.fontColor = textColor
            titleLabel.position = CGPoint(x: size.width / 2, y: size.height - 80)
            titleLabel.zPosition = 100
            addChild(titleLabel)

            // Instruction label
            instructionLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
            instructionLabel.fontSize = 18
            instructionLabel.fontColor = textColor
            instructionLabel.position = CGPoint(x: size.width / 2, y: size.height - 140)
            instructionLabel.preferredMaxLayoutWidth = size.width - 60
            instructionLabel.numberOfLines = 0
            instructionLabel.zPosition = 100
            addChild(instructionLabel)

            // Progress bar
            let progressWidth: CGFloat = size.width - 80
            let progressHeight: CGFloat = 8
            let progressRect = CGRect(x: 40, y: 60, width: progressWidth, height: progressHeight)
            progressBar = SKShapeNode(rect: progressRect, cornerRadius: 4)
            progressBar.fillColor = isDark ? UIColor(white: 0.3, alpha: 1.0) : UIColor(white: 0.8, alpha: 1.0)
            progressBar.strokeColor = .clear
            progressBar.zPosition = 100
            addChild(progressBar)

            // Skip button
            skipButton = SKLabelNode(fontNamed: "AvenirNext-Medium")
            skipButton.text = "Skip Tutorial"
            skipButton.fontSize = 16
            skipButton.fontColor = .systemBlue
            skipButton.position = CGPoint(x: 80, y: 40)
            skipButton.name = "skipButton"
            skipButton.zPosition = 100
            addChild(skipButton)

            // Next button
            nextButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
            nextButton.text = "Next >"
            nextButton.fontSize = 20
            nextButton.fontColor = .systemGreen
            nextButton.position = CGPoint(x: size.width - 60, y: 100)
            nextButton.name = "nextButton"
            nextButton.zPosition = 100
            nextButton.alpha = 0.3 // Disabled initially
            addChild(nextButton)

            // Accessibility
            accessibility.configureScoreLabel(titleLabel, score: 0)
            titleLabel.accessibilityLabel = "Tutorial title"
            instructionLabel.accessibilityLabel = "Tutorial instructions"
        }

        private func setupPlayer() {
            player = SKSpriteNode(
                color: config.color(from: config.player.color),
                size: config.player.size
            )
            player?.position = CGPoint(x: size.width / 2, y: 200)
            player?.zPosition = 50

            if let player {
                accessibility.configurePlayer(player)
                addChild(player)
            }
        }

        // MARK: - Tutorial Steps

        private func startStep(_ step: TutorialStep) {
            currentStep = step

            // Update UI
            titleLabel.text = step.getTitle()
            instructionLabel.text = step.instruction
            updateProgressBar()

            // Reset step flags
            movementDetected = false
            obstacleAvoided = false
            powerUpCollected = false
            nextButton.alpha = 0.3

            // Remove previous test elements
            testObstacle?.removeFromParent()
            testPowerUp?.removeFromParent()

            // Setup step-specific elements
            switch step {
            case .welcome:
                // No special setup, just show message
                enableNextButton() // Can proceed immediately

            case .movement:
                // Player needs to move
                break

            case .obstacles:
                // Spawn a test obstacle
                spawnTestObstacle()

            case .powerUps:
                // Spawn a test power-up
                spawnTestPowerUp()

            case .scoring:
                // Show scoring example
                enableNextButton()

            case .complete:
                // Tutorial complete
                enableNextButton()
            }

            // Announce to VoiceOver
            accessibility.announce("\(step.getTitle()). \(step.instruction)")
        }

        private func updateProgressBar() {
            let progress = CGFloat(currentStep.rawValue) / CGFloat(TutorialStep.allCases.count - 1)
            let progressWidth: CGFloat = (size.width - 80) * progress

            let progressFill = SKShapeNode(
                rect: CGRect(x: 40, y: 60, width: progressWidth, height: 8),
                cornerRadius: 4
            )
            progressFill.fillColor = .systemGreen
            progressFill.strokeColor = .clear
            progressFill.zPosition = 101

            // Remove old fill
            childNode(withName: "progressFill")?.removeFromParent()
            progressFill.name = "progressFill"
            addChild(progressFill)
        }

        private func spawnTestObstacle() {
            testObstacle = SKSpriteNode(color: .systemRed, size: CGSize(width: 50, height: 50))
            testObstacle?.position = CGPoint(x: size.width / 2 + 80, y: size.height / 2)
            testObstacle?.zPosition = 50

            if let obstacle = testObstacle {
                accessibility.configureObstacle(obstacle, index: 1)
                addChild(obstacle)

                // Animate slowly
                let move = SKAction.moveBy(x: 0, y: -300, duration: 3.0)
                let remove = SKAction.removeFromParent()
                obstacle.run(SKAction.sequence([move, remove]))
            }
        }

        private func spawnTestPowerUp() {
            testPowerUp = SKSpriteNode(color: .systemBlue, size: CGSize(width: 30, height: 30))
            testPowerUp?.position = CGPoint(x: size.width / 2, y: size.height / 2 + 100)
            testPowerUp?.zPosition = 50

            if let powerUp = testPowerUp {
                accessibility.configurePowerUp(powerUp, type: .shield)
                addChild(powerUp)

                // Pulse animation
                let scaleUp = SKAction.scale(to: 1.2, duration: 0.5)
                let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
                let pulse = SKAction.sequence([scaleUp, scaleDown])
                powerUp.run(SKAction.repeatForever(pulse))
            }
        }

        private func enableNextButton() {
            nextButton.alpha = 1.0
            haptics.success()
        }

        private func advanceToNextStep() {
            guard let nextStep = TutorialStep(rawValue: currentStep.rawValue + 1) else {
                completeTutorial()
                return
            }

            haptics.selection()
            startStep(nextStep)
        }

        private func completeTutorial() {
            // Mark tutorial as completed
            UserDefaults.standard.set(true, forKey: "TutorialCompleted")
            UserDefaults.standard.synchronize()

            haptics.playPattern(.achievement)
            onComplete?()
        }

        // MARK: - Touch Handling

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            let tappedNode = atPoint(location)

            // Handle button taps
            if tappedNode.name == "skipButton" {
                haptics.selection()
                onSkip?()
                return
            }

            if tappedNode.name == "nextButton", nextButton.alpha > 0.9 {
                advanceToNextStep()
                return
            }

            // Handle player movement for tutorial
            if currentStep == .movement {
                handlePlayerMovement(to: location)
            }
        }

        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)

            if currentStep == .movement {
                handlePlayerMovement(to: location)
            }
        }

        private func handlePlayerMovement(to location: CGPoint) {
            guard let player else { return }

            // Move player to touch location (x only)
            let targetX = max(player.size.width / 2, min(location.x, size.width - player.size.width / 2))
            let moveAction = SKAction.moveTo(x: targetX, duration: 0.1)
            player.run(moveAction)

            // Mark movement detected
            if !movementDetected {
                movementDetected = true
                enableNextButton()
                haptics.light()
            }
        }

        // MARK: - Update

        override func update(_ currentTime: TimeInterval) {
            // Check for obstacle avoidance
            if currentStep == .obstacles, let player, let obstacle = testObstacle {
                let distance = hypot(
                    player.position.x - obstacle.position.x,
                    player.position.y - obstacle.position.y
                )

                if obstacle.position.y < 0, distance > player.size.width / 2, !obstacleAvoided {
                    obstacleAvoided = true
                    enableNextButton()
                }
            }

            // Check for power-up collection
            if currentStep == .powerUps, let player, let powerUp = testPowerUp {
                let distance = hypot(
                    player.position.x - powerUp.position.x,
                    player.position.y - powerUp.position.y
                )

                if distance < 40 && !powerUpCollected {
                    powerUpCollected = true
                    testPowerUp?.removeFromParent()
                    enableNextButton()

                    // Visual feedback
                    let flash = SKSpriteNode(
                        color: .systemBlue,
                        size: CGSize(width: player.size.width * 2, height: player.size.height * 2)
                    )
                    flash.position = player.position
                    flash.zPosition = 49
                    flash.alpha = 0.5
                    addChild(flash)
                    flash.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: 0.3),
                        SKAction.removeFromParent(),
                    ]))
                }
            }
        }
    }

#endif
