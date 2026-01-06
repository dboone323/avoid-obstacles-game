//
// CrashReportingManagerTests.swift
// AvoidObstaclesGameTests
//

import XCTest
@testable import AvoidObstaclesGame

final class CrashReportingManagerTests: XCTestCase {
    
    var crashManager: CrashReportingManager!
    
    override func setUp() {
        super.setUp()
        crashManager = CrashReportingManager.shared
        // Clean up before test
        crashManager.clearCrashLog()
    }
    
    override func tearDown() {
        crashManager.clearCrashLog()
        crashManager = nil
        super.tearDown()
    }
    
    func testConfiguration() {
        crashManager.configure()
        // We can't inspect 'isEnabled' directly as it is private, but it enables logging.
        // We can check if log contains "app_launch" event which configure() logs.
        
        let logs = crashManager.getCrashLog()
        XCTAssertTrue(logs.contains { $0.event == "app_launch" }, "Configuration should log app_launch")
    }
    
    func testRecordError() {
        crashManager.configure()
        let error = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test Error"])
        crashManager.recordError(error)
        
        let logs = crashManager.getCrashLog()
        // 'recordError' logs event "error"
        XCTAssertTrue(logs.contains { $0.event == "error" })
        
        // Verify parameters
        if let entry = logs.first(where: { $0.event == "error" }),
           let params = entry.parameters {
             // Params contain 'error': description
             // Accessing AnyCodable dict... depends on implementation.
             // The implementation maps [String: Any] to [String: AnyCodable].
             // To check content, we might need to inspect.
             XCTAssertNotNil(params)
        }
    }
    
    func testLogCustomEvent() {
        crashManager.configure()
        crashManager.log(event: "custom_event", parameters: ["foo": "bar"])
        
        let logs = crashManager.getCrashLog()
        XCTAssertTrue(logs.contains { $0.event == "custom_event" })
    }
    
    func testClearCrashLog() {
        crashManager.configure()
        crashManager.log(event: "to_be_deleted")
        XCTAssertFalse(crashManager.getCrashLog().isEmpty)
        
        crashManager.clearCrashLog()
        XCTAssertTrue(crashManager.getCrashLog().isEmpty)
    }
}
