// Tests/AgentUITests/SensitiveDataRedactionTests.swift
import Testing
import Foundation
@testable import AgentUI

@Suite("Sensitive Data Redaction Tests")
struct SensitiveDataRedactionTests {
    @Test("Redacts API keys and secrets from tool arguments")
    func testRedaction() {
        let rawJSON = "{\"api_key\": \"sk-secret123456\", \"token\": \"ghp_abcdef123\", \"query\": \"test\"}"
        let sanitized = ToolCallInspection.sanitize(arguments: rawJSON)

        #expect(!sanitized.contains("sk-secret123456"))
        #expect(!sanitized.contains("ghp_abcdef123"))
        #expect(sanitized.contains("\"api_key\": \"[REDACTED]\""))
        #expect(sanitized.contains("\"token\": \"[REDACTED]\""))
        #expect(sanitized.contains("\"query\": \"test\""))
    }
}
