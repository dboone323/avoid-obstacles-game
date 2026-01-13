//
// CrashReportingManager.swift
// AvoidObstaclesGame
//
// Lightweight crash reporting wrapper. Defaults to local logging if
// Firebase Crashlytics is not configured. Free tier compatible.
//

import Foundation

/// Crash reporting manager - logs errors and crashes
/// Configure with Firebase Crashlytics by adding GoogleService-Info.plist
class CrashReportingManager {
    
    // MARK: - Singleton
    
    static let shared = CrashReportingManager()
    
    // MARK: - Properties
    
    private var isEnabled = false
    private var crashLogPath: URL?
    
    // MARK: - Initialization
    
    private init() {
        setupLocalCrashLog()
        setupExceptionHandling()
    }
    
    // MARK: - Configuration
    
    /// Call this in AppDelegate or App init to enable crash reporting
    func configure() {
        #if DEBUG
        GameLogger.shared.debug("💥 CrashReportingManager: Configured (Debug mode - local logging only)")
        #else
        GameLogger.shared.debug("💥 CrashReportingManager: Configured")
        #endif
        
        isEnabled = true
        
        // Log app launch
        log(event: "app_launch", parameters: [
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "system_version": ProcessInfo.processInfo.operatingSystemVersionString
        ])
    }
    
    // MARK: - Logging
    
    /// Log a non-fatal error
    func recordError(_ error: Error, additionalInfo: [String: Any]? = nil) {
        guard isEnabled else { return }
        
        let errorInfo: [String: Any] = [
            "error": error.localizedDescription,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "additional_info": additionalInfo ?? [:]
        ]
        
        log(event: "error", parameters: errorInfo)
        
        #if DEBUG
        GameLogger.shared.debug("💥 Error recorded: \(error.localizedDescription)")
        #endif
    }
    
    /// Log a custom event
    func log(event: String, parameters: [String: Any]? = nil) {
        guard isEnabled else { return }
        
        let entry = CrashLogEntry(
            event: event,
            timestamp: Date(),
            parameters: parameters
        )
        
        writeToLog(entry)
    }
    
    /// Set user identifier for crash reports
    func setUserID(_ userID: String?) {
        if let userID = userID {
            log(event: "user_identified", parameters: ["user_id": userID])
        }
    }
    
    /// Log breadcrumb for debugging
    func logBreadcrumb(_ message: String) {
        log(event: "breadcrumb", parameters: ["message": message])
    }
    
    // MARK: - Game-specific logging
    
    /// Log game session start
    func logGameStart() {
        log(event: "game_start", parameters: [
            "session_id": UUID().uuidString
        ])
    }
    
    /// Log game over with context
    func logGameOver(score: Int, survivalTime: TimeInterval, level: Int) {
        log(event: "game_over", parameters: [
            "score": score,
            "survival_time": survivalTime,
            "level": level
        ])
    }
    
    /// Log crash-worthy scenarios that didn't crash
    func logPotentialCrash(_ scenario: String, context: [String: Any]? = nil) {
        var params: [String: Any] = ["scenario": scenario]
        if let context = context {
            params["context"] = context
        }
        log(event: "potential_crash_avoided", parameters: params)
    }
    
    // MARK: - Private Methods
    
    private func setupLocalCrashLog() {
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            crashLogPath = documentsPath.appendingPathComponent("crash_log.json")
        }
    }
    
    private func setupExceptionHandling() {
        NSSetUncaughtExceptionHandler { exception in
            let info: [String: Any] = [
                "name": exception.name.rawValue,
                "reason": exception.reason ?? "Unknown",
                "stack": exception.callStackSymbols.prefix(10).joined(separator: "\n"),
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
            
            CrashReportingManager.shared.log(event: "uncaught_exception", parameters: info)
            
            #if DEBUG
            GameLogger.shared.debug("💥 CRASH: \(exception.name.rawValue) - \(exception.reason ?? "Unknown")")
            #endif
        }
    }
    
    private func writeToLog(_ entry: CrashLogEntry) {
        guard let logPath = crashLogPath else { return }
        
        var entries: [CrashLogEntry] = []
        
        // Read existing entries
        if let data = try? Data(contentsOf: logPath),
           let existing = try? JSONDecoder().decode([CrashLogEntry].self, from: data) {
            entries = existing.suffix(99) // Keep last 99 entries
        }
        
        entries.append(entry)
        
        // Write back
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: logPath)
        }
    }
    
    /// Get crash log for debugging
    func getCrashLog() -> [CrashLogEntry] {
        guard let logPath = crashLogPath,
              let data = try? Data(contentsOf: logPath),
              let entries = try? JSONDecoder().decode([CrashLogEntry].self, from: data) else {
            return []
        }
        return entries
    }
    
    /// Clear crash log
    func clearCrashLog() {
        guard let logPath = crashLogPath else { return }
        try? FileManager.default.removeItem(at: logPath)
    }
}

// MARK: - Models

struct CrashLogEntry: Codable {
    let event: String
    let timestamp: Date
    let parameters: [String: AnyCodable]?
    
    init(event: String, timestamp: Date, parameters: [String: Any]?) {
        self.event = event
        self.timestamp = timestamp
        self.parameters = parameters?.mapValues { AnyCodable($0) }
    }
}

/// Type-erased Codable wrapper
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            value = arrayValue.map { $0.value }
        } else if let dictValue = try? container.decode([String: AnyCodable].self) {
            value = dictValue.mapValues { $0.value }
        } else {
            value = ""
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let intValue as Int:
            try container.encode(intValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        default:
            try container.encode(String(describing: value))
        }
    }
}
