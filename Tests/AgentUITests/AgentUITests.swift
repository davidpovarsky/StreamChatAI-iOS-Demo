// Tests/AgentUITests/AgentUITests.swift
import Testing
@testable import AgentUI

@Suite("AgentUI Package Sanity")
struct AgentUISanityTests {
    @Test("Verify package version")
    func verifyVersion() {
        #expect(AgentUIModule.version == "0.1.0")
    }
}
