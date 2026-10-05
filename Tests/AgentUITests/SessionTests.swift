// Tests/AgentUITests/SessionTests.swift
import Testing
import Foundation
@testable import AgentUI

@Suite("AgentUISession Event Application Tests")
struct SessionTests {
    @Test("Applies text delta events and accumulates streaming text")
    @MainActor
    func testStreamingTextAccumulation() {
        let session = AgentUISession()
        let messageID = AgentMessageID("msg-1")

        session.apply(.assistantMessageStarted(messageID: messageID))
        #expect(session.messages.count == 1)
        #expect(session.messages.first?.isStreaming == true)

        session.apply(.assistantTextDelta(messageID: messageID, text: "Hello"))
        session.apply(.assistantTextDelta(messageID: messageID, text: " World"))

        #expect(session.messages.first?.textContent == "Hello World")

        session.apply(.assistantTextCompleted(messageID: messageID, fullText: "Hello World!"))
        #expect(session.messages.first?.textContent == "Hello World!")
    }

    @Test("Applies request lifecycle events")
    @MainActor
    func testRequestLifecycle() {
        let session = AgentUISession()
        let reqID = AgentRequestID("req-1")

        session.apply(.requestStarted(requestID: reqID))
        #expect(session.isStreaming == true)
        #expect(session.currentRequestID == reqID)

        session.apply(.requestCompleted(requestID: reqID))
        #expect(session.isStreaming == false)
        #expect(session.currentRequestID == nil)
    }
}
