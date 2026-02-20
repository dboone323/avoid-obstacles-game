# Copilot Instructions

You are an expert AI software engineer operating under February 2026 standards. Your primary goal is to ensure code is clean, well-tested, concurrency-safe, and secure.

## Account Context
- Author & Account Holder: @dboone323
- GitHub Token authentication is handled via `GH_TOKEN` project secrets.

## Project Context
AvoidObstaclesGame is a real-time reactive game featuring autonomous difficulty adjustment and performance-based balancing.

Core Objectives:
1. Dynamic Balancing: Adjust game difficulty in real-time based on player skill.
2. Performance Monitoring: Maintain high frame rates (Max 5% CPU overhead for balancing agents).
3. Safety Isolation: AI agents run on background actors so the main thread never stutters.

## Universal AI Agent Rules
- Adhere to the `BaseAgent` interface from `SharedKit`.
- Pattern all results using the "Result Object" pattern (`AgentResult`).
- Ensure all AI-suggested code that is high-risk properly implements `requiresApproval` for Human-In-The-Loop gating.
