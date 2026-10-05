// Tests/AgentUITests/HostActionsAndRegistryTests.swift
import Testing
import Foundation
@testable import AgentUI
@testable import AgentUIShowcaseSupport

@Suite("Host Actions and Surface Registry Tests")
struct HostActionsAndRegistryTests {
    @Test("ShowcaseHostActions captures dispatched actions deterministically")
    @MainActor
    func testHostActionsDispatch() {
        let hostActions = ShowcaseHostActions()

        let testURL = URL(string: "https://example.com/test")!
        hostActions.openURL(testURL)
        #expect(hostActions.lastOpenedURL == testURL)
        #expect(hostActions.lastActionMessage?.contains("https://example.com/test") == true)

        let sheetReq = AgentPresentationRequest(title: "Sheet Title", targetIdentifier: "view.detail")
        hostActions.requestSheet(sheetReq)
        #expect(hostActions.lastRequestedSheet?.targetIdentifier == "view.detail")

        let fsReq = AgentPresentationRequest(title: "FS Title", targetIdentifier: "view.fullscreen")
        hostActions.requestFullScreen(fsReq)
        #expect(hostActions.lastRequestedFullScreen?.targetIdentifier == "view.fullscreen")

        let winReq = AgentPresentationRequest(title: "Win Title", targetIdentifier: "view.window")
        hostActions.requestWindow(winReq)
        #expect(hostActions.lastRequestedWindow?.targetIdentifier == "view.window")

        let act = AgentHostAction(actionID: "custom.action", payload: "payload_123")
        hostActions.performAction(act)
        #expect(hostActions.lastPerformedAction?.actionID == "custom.action")
        #expect(hostActions.lastPerformedAction?.payload == "payload_123")
    }

    @Test("AgentUISession supports cancelled status for activities and requests")
    @MainActor
    func testCancelledStatusApplication() {
        let session = AgentUISession()
        let msgID = AgentMessageID("msg-cancel")
        let toolCallID = AgentToolCallID("call-1")

        session.apply(.assistantMessageStarted(messageID: msgID))
        session.apply(.toolStarted(
            messageID: msgID,
            execution: AgentToolExecution(
                id: toolCallID,
                handlerID: "test.tool",
                inspection: ToolCallInspection(toolName: "test_tool", arguments: "{}"),
                status: .running
            )
        ))

        let toolExec = session.messages.first?.blocks.compactMap { block -> AgentToolExecution? in
            if case .toolExecution(_, let exec) = block { return exec }
            return nil
        }.first
        #expect(toolExec?.status == .running)

        session.apply(.toolCancelled(messageID: msgID, toolCallID: toolCallID))

        let cancelledTool = session.messages.first?.blocks.compactMap { block -> AgentToolExecution? in
            if case .toolExecution(_, let exec) = block { return exec }
            return nil
        }.first
        #expect(cancelledTool?.status == .cancelled)

        let actItem = session.activitySessions[msgID]?.items.first(where: { $0.id.rawValue == toolCallID.rawValue })
        #expect(actItem?.status == .cancelled)
    }
}
