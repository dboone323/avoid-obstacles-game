//
// ShareManager.swift
// AvoidObstaclesGame
//

#if os(iOS)
    import Social
    import SpriteKit
    import UIKit

    @MainActor
    class ShareManager {
        static let shared = ShareManager()

        private init() {}

        func shareScore(_ score: Int, from viewController: UIViewController) {
            let text = "I just scored \(score) points in Avoid Obstacles! Can you beat my score?"

            let activityVC = UIActivityViewController(
                activityItems: [text],
                applicationActivities: nil
            )

            activityVC.excludedActivityTypes = [.addToReadingList, .assignToContact]

            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = viewController.view
                popover.sourceRect = CGRect(
                    x: viewController.view.bounds.midX,
                    y: viewController.view.bounds.midY,
                    width: 0,
                    height: 0
                )
            }

            viewController.present(activityVC, animated: true) {
                AnalyticsManager.shared.trackEvent("score_shared", parameters: ["score": score])
            }
        }

        func shareScreenshot(_ image: UIImage, score: Int, from viewController: UIViewController) {
            let text = "Check out my score of \(score) in Avoid Obstacles!"

            let activityVC = UIActivityViewController(
                activityItems: [text, image],
                applicationActivities: nil
            )

            viewController.present(activityVC, animated: true)
        }

        @MainActor
        func captureScreenshot(from scene: SKScene) -> UIImage? {
            guard let view = scene.view else { return nil }

            UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, view.traitCollection.displayScale)
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return image
        }
    }
#endif
