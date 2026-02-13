#if canImport(AppIntents)
import AppIntents

@available(iOS 16.0, macOS 13.0, *)
struct LaunchAvoidObstaclesIntent: AppIntent {
    static let title: LocalizedStringResource = "Launch Avoid Obstacles"
    static let description = IntentDescription("Open the game and jump into a quick run.")

    func perform() async throws -> some IntentResult {
        .result()
    }
}
#endif
