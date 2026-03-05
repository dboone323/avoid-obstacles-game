# AvoidObstaclesGame: Agentic Grounding (Feb 2026)

## Purpose

AvoidObstaclesGame is a real-time reactive game featuring autonomous difficulty adjustment and performance-based balancing.

## Core Objectives

1. **Dynamic Balancing**: Adjust game difficulty (speed, spawn rate) in real-time based on player skill.
2. **Performance Monitoring**: Use `PerformanceManager` to maintain high frame rates while running AI agents.
3. **Safety Isolation**: Ensure AI agents run on background actors to prevent main-thread stutter.

## Agent Instructions

- **Subtle Adjustments**: Focus on incremental difficulty changes that feel natural to the player.
- **Resource Management**: Prioritize low latency in logic execution.

## Constraints

- Max 5% CPU overhead for balancing agents.
- Must coordinate with `GameBalanceAgent` for all state changes.

## March 2026 Code Standards

- **No Stubs/Mocks**: Do not use placeholders, mocks, or stubs in implementation or testing.
- **Production Ready**: Every new line of code must be real, working, and production-ready.
- **End-to-End Testing**: Use real working and tested code to verify behavior natively to avoid down-the-line problems.
- **Modern Standards**: Adhere strictly to the latest ecosystem standards (Swift 6.2 concurrency, Python 3.13).
