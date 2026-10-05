// Tests/AgentUITests/SensitiveDataRedactionTests.swift
import Testing
import Foundation
@testable import AgentUI

@Suite("Sensitive Data Redaction Tests")
struct SensitiveDataRedactionTests {
    @Test("Redacts API keys and secrets from tool arguments")
    func testRedaction() {
        let rawJSON = """
        {
            "api_key": "raw_api_key_value",
            "Authorization": "secret_auth_token",
            "bearer_field": "Bearer my_secret_bearer_token",
            "password": "super_secret_password_123",
            "secret": "stripe_secret_key_987",
            "nested": "sk-proj-1234567890abcdefABCDEF1234",
            "normal_field": "hello world"
        }
        """
        let sanitized = ToolCallInspection.sanitize(arguments: rawJSON)

        #expect(!sanitized.contains("raw_api_key_value"))
        #expect(!sanitized.contains("secret_auth_token"))
        #expect(!sanitized.contains("my_secret_bearer_token"))
        #expect(!sanitized.contains("super_secret_password_123"))
        #expect(!sanitized.contains("stripe_secret_key_987"))
        #expect(!sanitized.contains("sk-proj-1234567890abcdefABCDEF1234"))
        #expect(sanitized.contains("\"api_key\": \"[REDACTED]\""))
        #expect(sanitized.contains("\"Authorization\": \"[REDACTED]\""))
        #expect(sanitized.contains("Bearer [REDACTED]"))
        #expect(sanitized.contains("\"password\": \"[REDACTED]\""))
        #expect(sanitized.contains("\"secret\": \"[REDACTED]\""))
        #expect(sanitized.contains("sk-[REDACTED]"))
        #expect(sanitized.contains("hello world"))
    }
}
