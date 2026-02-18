//
// InputManager.swift
// AvoidObstaclesGame
//

import SpriteKit

#if canImport(CoreMotion)
    import CoreMotion
#endif

#if canImport(AppKit)
    import AppKit
#endif

class InputManager {
    @MainActor static let shared = InputManager()

    enum ControlMode {
        case tap
        case drag
        case tilt
        case gesture
    }

    private var mode: ControlMode = .drag

    #if os(iOS)
        private let motionManager = CMMotionManager()
    #endif

    var onMove: ((CGFloat) -> Void)?

    func setMode(_ mode: ControlMode) {
        self.mode = mode

        #if os(iOS)
            if mode == .tilt {
                startTiltMonitoring()
            } else {
                stopTiltMonitoring()
            }
        #elseif os(macOS)
            if mode == .tilt {
                startTiltMonitoring()
            } else {
                stopTiltMonitoring()
            }
        #endif
    }

    @MainActor
    func handleTouch(_ location: CGPoint, in scene: SKScene) {
        switch mode {
        case .tap, .drag:
            let normalizedX = location.x / scene.size.width
            onMove?(normalizedX)

        case .gesture:
            // Gesture handled separately
            break

        case .tilt:
            // Tilt handled by motion manager or keyboard fallback
            break
        }
    }

    #if os(iOS)
        private func startTiltMonitoring() {
            guard motionManager.isAccelerometerAvailable else { return }

            motionManager.accelerometerUpdateInterval = 0.02
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
                guard let data else { return }
                let sensitivity = GameConfiguration.load().player.tiltSensitivity
                let tilt = CGFloat(data.acceleration.x) * sensitivity
                self?.onMove?(0.5 + tilt)
            }
        }

        private func stopTiltMonitoring() {
            motionManager.stopAccelerometerUpdates()
        }
    #elseif os(macOS)
        private var currentTilt: CGFloat = 0.5
        private let keyboardSensitivity: CGFloat = 0.05

        private func startTiltMonitoring() {
            NSLog("[InputManager] LOG: Tilt mode fallback active for macOS (Keyboard).")
        }

        private func stopTiltMonitoring() {
            currentTilt = 0.5
            onMove?(currentTilt)
        }

        @MainActor
        func handleKeyboard(event: NSEvent) {
            guard mode == .tilt else { return }

            // Simulating tilt with arrow keys or A/D
            // Key codes: 123 (Left), 124 (Right), 0 (A), 2 (D)
            if event.keyCode == 123 || event.keyCode == 0 {
                currentTilt = max(0, currentTilt - keyboardSensitivity)
                onMove?(currentTilt)
            } else if event.keyCode == 124 || event.keyCode == 2 {
                currentTilt = min(1, currentTilt + keyboardSensitivity)
                onMove?(currentTilt)
            }
        }
    #else
        private func startTiltMonitoring() {}
        private func stopTiltMonitoring() {}
    #endif
}
