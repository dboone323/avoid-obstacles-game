//
// InputManager.swift
// AvoidObstaclesGame
//

import SpriteKit

#if canImport(CoreMotion)
    import CoreMotion
#endif

class InputManager {
    static let shared = InputManager()

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
        #endif
    }

    func handleTouch(_ location: CGPoint, in scene: SKScene) {
        switch mode {
        case .tap, .drag:
            let normalizedX = location.x / scene.size.width
            onMove?(normalizedX)

        case .gesture:
            // Gesture handled separately
            break

        case .tilt:
            // Tilt handled by motion manager
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
    #else
        private func startTiltMonitoring() {}
        private func stopTiltMonitoring() {}
    #endif
}
