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
