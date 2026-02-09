# AvoidObstaclesGame - Master Plan & Next Steps

This document serves as the **Single Source of Truth** for all planned enhancements, stability improvements, and technical debt resolution for the AvoidObstaclesGame project.

---

## 🚀 Current Status: Stability & Audit (Phase 1.5)

**Current Objective:** Resolve failing unit tests, fix API mismatches from recent refactorings, and establish a baseline for 100% test coverage.

### 🔄 In-Progress

- [ ] Fix unit tests in `AvoidObstaclesGameTests` (LeaderboardManager, PowerUpManager, InputController).
- [ ] Run test suite on iPhone 17 Simulator and macOS.
- [ ] Generate and analyze code coverage reports to find gaps.
- [ ] SwiftLint/SwiftFormat compliance (0 violations).

### 🔜 Immediate Next Steps (Audit & Stabilization)

1. **Architecture Reconciliation**: Decide on ECS (Entity-Component-System) vs. Manager-based architecture. Currently, both exist but only managers are used in `GameScene.swift`.
2. **Leaderboard API Fixes**: Update `LeaderboardManagerTests.swift` to match the actual implementation in `LeaderboardManager.swift`.
3. **PowerUp/Input Initializer Fixes**: Ensure all test initializers provide the required `SKScene` or `SKNode` parameters.
4. **Coverage Expansion**: Create new tests for previously untested managers (PhysicsManager, UIManager, etc.).

---

## 🗺️ Long-Term Roadmap (Consolidated from Tasks 2.1-2.50)

### Phase 1: Core Enhancements (High Priority)

- **Architecture**:
    - [ ] Optimize game loop with delta time normalization.
    - [ ] Implement memory pressure handling.
    - [ ] Add asset preloading and caching.
    - [ ] Proper scene cleanup and deallocation.
- **Gameplay**:
    - [ ] Procedural obstacle variety (5+ types).
    - [ ] Pixel-perfect collision option.
    - [ ] Adaptive difficulty AI.
- **Testing**:
    - [ ] Platform-specific test suites (iOS vs macOS).
    - [ ] Performance benchmarks.

### Phase 2: User Experience (Medium Priority)

- **UI/UX**:
    - [ ] Redesign UI with modern SwiftUI components.
    - [ ] Build comprehensive settings screen.
    - [ ] Spatial audio system implementation.
- **Social/Integrations**:
    - [ ] Fully verify Game Center leaderboard & achievements.
    - [ ] Social sharing functionality.
    - [ ] Expand localization strings (6+ languages foundation exists).

### Phase 3: Advanced Features (Lower Priority)

- **Mechanics**:
    - [ ] Combo system for scoring.
    - [ ] Power-up system expansion (5+ types).
    - [ ] Physics refinements (gravity modes).
- **Visuals**:
    - [ ] Advanced animation system (AnimationController.swift).
    - [ ] Custom shader effects.
    - [ ] Texture streaming for large assets.

### Phase 4: Production & CI/CD

- **Automation**:
    - [ ] Implement robust CI/CD pipeline (Fastlane/GitHub Actions).
    - [ ] Regression test automation.
- **Analytics**:
    - [ ] Analytics and crash reporting integration.

---

## 🛠️ Tech Debt & Audit Findings

### ECS vs Manager Architecture

> [!IMPORTANT]
> The project contains an ECS framework (`EntityManager.swift`, `Components/`, `Entities/`), but `GameScene.swift` uses a direct manager-based approach (`ObstacleManager`, `PlayerManager`). This inconsistency should be resolved: either migrate to ECS or prune the unused code.

### Test Coverage Baseline

- **Goal**: 100% Coverage for all service managers.
- **Status**: Currently resolving build-breaking API mismatches in existing tests.

---

## 📑 Superseded Documents

The following documents are now considered historical and are consolidated into this `PLAN.md`:

- `COMPLETE_ROADMAP_2.1-2.50.md`
- `FULL_IMPLEMENTATION_PROGRESS.md`
- `AVOID_OBSTACLES_ENHANCEMENTS_SUMMARY.md`
- `TEST_PLAN.md`

---

**Last Updated:** 2026-02-08  
**Owner:** Antigravity (AI Assistant)
