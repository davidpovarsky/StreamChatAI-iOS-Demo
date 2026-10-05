// Tests/AgentUITests/ActivityTimelineTests.swift
import Testing
import Foundation
@testable import AgentUI

@Suite("AgentActivity Timeline Tests")
struct ActivityTimelineTests {
    @Test("Timeline items transition from running to completed")
    @MainActor
    func testActivityTransitions() {
        let session = AgentUISession()
        let msgID = AgentMessageID("msg-1")
        let actID = AgentActivityID("act-1")

        session.apply(.assistantMessageStarted(messageID: msgID))
        session.apply(.activityStarted(messageID: msgID, item: AgentActivityItem(id: actID, kind: .reasoning, status: .running, title: "Thinking...")))

        let initialSession = session.activitySessions[msgID]
        #expect(initialSession != nil)
        #expect(initialSession?.items.first?.status == .running)

        session.apply(.activityCompleted(messageID: msgID, itemID: actID))
        let completedSession = session.activitySessions[msgID]
        #expect(completedSession?.items.first?.status == .completed)
    }

    @Test("One-time auto-collapse on first final-answer token")
    @MainActor
    func testOneTimeAutoCollapse() {
        let session = AgentUISession()
        let msgID = AgentMessageID("msg-1")
        let actID = AgentActivityID("act-1")

        session.apply(.assistantMessageStarted(messageID: msgID))
        session.apply(.activityStarted(messageID: msgID, item: AgentActivityItem(id: actID, kind: .reasoning, status: .running, title: "Thinking...")))

        // Prior to answer text, activity is expanded
        #expect(session.activitySessions[msgID]?.isExpanded == true)
        #expect(session.activitySessions[msgID]?.hasAutoCollapsed == false)

        // First answer token delta arrives -> auto-collapses
        session.apply(.assistantTextDelta(messageID: msgID, text: "First token"))
        #expect(session.activitySessions[msgID]?.isExpanded == false)
        #expect(session.activitySessions[msgID]?.hasAutoCollapsed == true)

        // User manually expands the activity timeline
        var updated = session.activitySessions[msgID]!
        updated.isExpanded = true
        session.activitySessions[msgID] = updated

        // Subsequent answer token delta arrives -> does NOT force collapse again!
        session.apply(.assistantTextDelta(messageID: msgID, text: " Second token"))
        #expect(session.activitySessions[msgID]?.isExpanded == true)
    }
}
