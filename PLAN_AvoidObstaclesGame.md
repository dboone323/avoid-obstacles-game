## Plan: Audit AvoidObstaclesGame (iOS/macOS)

Comprehensive review and test run for AvoidObstaclesGame covering iPhone 17 simulator and macOS build, with UX/dev improvements. Inspect architecture docs, run XCTests, evaluate code quality (SpriteKit managers, data flow, lint), and propose front/back-end enhancements.

**Steps**
1. Skim docs for intended behavior and constraints: AvoidObstaclesGame/README.md, AvoidObstaclesGame/ARCHITECTURE.md, AvoidObstaclesGame/TEST_PLAN.md, AvoidObstaclesGame/TESTING_RESULTS.md.
2. Review CI and tooling expectations (sim targets, signing off, lint/format): AvoidObstaclesGame/.github/workflows/ci.yml, AvoidObstaclesGame/.swiftlint.yml, AvoidObstaclesGame/.swiftformat.yml, AvoidObstaclesGame/.ci/run_validation.sh.
3. Open the project to confirm schemes/targets and destinations: AvoidObstaclesGame/AvoidObstaclesGame.xcodeproj, AvoidObstaclesGame/AvoidObstaclesGame.xctestplan.
4. Run local tests on iPhone 17 simulator (unit + UI) and macOS target; capture failures, logs, and coverage hotspots.
5. Spot-check key code areas for quality and UX: SpriteKit scene flow (AvoidObstaclesGame/AvoidObstaclesGame/GameScene.swift), obstacle spawning (AvoidObstaclesGame/AvoidObstaclesGame/ObstacleManager.swift), scoring/persistence (AvoidObstaclesGame/AvoidObstaclesGame/HighScoreManager.swift), state/lifecycle (AvoidObstaclesGame/AvoidObstaclesGame/GameStateManager.swift), performance/smoothing (AvoidObstaclesGame/AvoidObstaclesGame/PerformanceTracker.swift).
6. Audit tests for coverage gaps and brittleness: AvoidObstaclesGame/AvoidObstaclesGameTests, AvoidObstaclesGame/AvoidObstaclesGameUITests; note untested managers or edge cases; check placeholder Python check AvoidObstaclesGame/Tests/test_avoidobstacles_wqc.py.
7. Identify UX/front-end opportunities: input responsiveness, difficulty curve, feedback (audio/haptics), accessibility (Dynamic Type/VoiceOver), pause/resume behavior, menu polish; propose concrete SpriteKit/UI tweaks with feasibility.
8. Identify back-end/engine opportunities: decouple singletons, physics tuning, determinism/testing hooks, data persistence hardening, metrics/logging, lint/format tightening, CI reliability.
9. Summarize findings with prioritized recommendations (quick wins vs larger refactors) and suggested changes to tests/CI/tooling.

**Verification**
- xcodebuild test -project AvoidObstaclesGame/AvoidObstaclesGame.xcodeproj -scheme AvoidObstaclesGame -destination "platform=iOS Simulator,name=iPhone 17" passes.
- macOS target builds/tests cleanly via scheme (or XCTest plan) with signing disabled.
- SwiftLint/SwiftFormat dry runs clean (or noted deviations).
- Documented list of failing tests (if any) with proposed fixes and coverage deltas.
