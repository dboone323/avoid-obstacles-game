# Xcode 26.3 Intelligence: AvoidObstaclesGame Hints

## Architecture Oversight

This is a mixed SwiftUI/Metal project. Agents should focus on `AvoidObstaclesGame/` for logic and `AvoidObstaclesGame/Views` for UI.

## Intelligence Integration

- **Index Priority**: `GameBalanceAgent.swift` is the entry point for difficulty logic.
- **Performance Root**: `PerformanceManager.swift` handles the resource budget for agents.

## Optimization Hints

- Strict concurrency is enforced via `Base.xcconfig`.
- Avoid main-thread blocking; all AI calculations must be async.
