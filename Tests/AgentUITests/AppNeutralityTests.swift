// Tests/AgentUITests/AppNeutralityTests.swift
import Testing
import Foundation
@testable import AgentUI

// Second independent non-Hanlin runtime proving provider/host neutrality
private final class TinyFakeAppRuntime: AgentUIRuntimeAdapter, @unchecked Sendable {
    func send(_ request: AgentSendRequest) -> AsyncThrowingStream<AgentUIEvent, Error> {
        AsyncThrowingStream { continuation in
            let messageID = AgentMessageID("fake-msg-01")
            continuation.yield(.requestStarted(requestID: request.requestID))
            continuation.yield(.assistantMessageStarted(messageID: messageID))
            continuation.yield(.assistantTextDelta(messageID: messageID, text: "Fake app responded."))
            continuation.yield(.requestCompleted(requestID: request.requestID))
            continuation.finish()
        }
    }

    func cancel(requestID: AgentRequestID) async {}
}

@Suite("App Neutrality Tests")
struct AppNeutralityTests {
    @Test("Verify AgentUI integrates with arbitrary independent third-party runtime")
    @MainActor
    func testThirdPartyAppIntegration() async {
        let fakeRuntime = TinyFakeAppRuntime()
        let session = AgentUISession(
            runtime: fakeRuntime,
            models: [AgentModelDescriptor(id: "fake-model", displayName: "Fake Model")]
        )

        session.send(prompt: "Hello from third-party app")

        // Wait a brief moment for the fake runtime to yield
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(session.messages.count >= 2)
        #expect(session.messages.last?.textContent == "Fake app responded.")
    }
}
