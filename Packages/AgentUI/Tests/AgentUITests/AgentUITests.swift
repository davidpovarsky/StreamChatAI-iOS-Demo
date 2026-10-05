//
//  AgentUITests.swift
//  AgentUITests
//

import XCTest
@testable import AgentUI
@testable import MinimalConsumer

final class AgentUITests: XCTestCase {
    func testAgentUIVersion() {
        XCTAssertEqual(AgentUIMetadata.version, "1.0.0")
    }

    func testModelDescriptors() {
        let model = AgentModelDescriptor(
            id: "gpt-4.1",
            displayName: "GPT-4.1",
            fullName: "GPT-4.1 High Fidelity",
            iconName: "cpu",
            isMultimodal: true
        )
        XCTAssertEqual(model.id, "gpt-4.1")
        XCTAssertEqual(model.displayName, "GPT-4.1")
        XCTAssertTrue(model.isMultimodal)
    }

    func testChatSessionDescriptors() {
        let session = AgentChatSessionDescriptor(
            id: "session-1",
            title: "Test Chat",
            createdAt: Date(),
            isBlankChat: false
        )
        XCTAssertEqual(session.id, "session-1")
        XCTAssertEqual(session.title, "Test Chat")
        XCTAssertFalse(session.isBlankChat)
    }

    func testToolExecutionStatus() {
        XCTAssertEqual(ToolExecutionStatus.running.label, "Running")
        XCTAssertEqual(ToolExecutionStatus.succeeded.label, "Completed")
        XCTAssertEqual(ToolExecutionStatus.failed.label, "Failed")
    }

    func testToolCallInspection() {
        let inspection = ToolCallInspection(
            serviceName: "GitHub API",
            functionName: "fetch_pull_request",
            rawArguments: "{\"pr\": 999}",
            rawResult: nil,
            errorMessage: "Not found",
            duration: 1.25
        )
        XCTAssertEqual(inspection.serviceName, "GitHub API")
        XCTAssertEqual(inspection.functionName, "fetch_pull_request")
        XCTAssertEqual(inspection.errorMessage, "Not found")
        XCTAssertEqual(inspection.duration, 1.25)
    }

    func testActivityStore() {
        let store = AgentActivityStore()
        XCTAssertTrue(store.sessions.isEmpty)

        store.record(
            messageID: "msg-1",
            type: .search,
            title: "Searching documentation",
            detail: "Query: swiftui"
        )

        let session = store.session(for: "msg-1")
        XCTAssertNotNil(session)
        XCTAssertEqual(session?.steps.count, 1)
        XCTAssertEqual(session?.steps.first?.title, "Searching documentation")
    }

    @MainActor
    func testMockRuntimeController() {
        let controller = MockAgentRuntimeController()
        XCTAssertEqual(controller.sessions.count, 1)
        XCTAssertEqual(controller.currentSession?.title, "Welcome to AgentUI")

        // Create new session
        controller.createNewSession()
        XCTAssertEqual(controller.sessions.count, 2)
        XCTAssertEqual(controller.currentSession?.title, "New Chat")

        // Rename session
        if let id = controller.currentSession?.id {
            controller.renameSession(id: id, newTitle: "Renamed Chat")
            XCTAssertEqual(controller.currentSession?.title, "Renamed Chat")
        }

        // Attachments
        controller.addDocumentAttachment(url: URL(fileURLWithPath: "/tmp/doc.txt"), fileName: "doc.txt")
        XCTAssertEqual(controller.pendingAttachments.count, 1)
        XCTAssertEqual(controller.pendingAttachments.first?.fileName, "doc.txt")

        if let attId = controller.pendingAttachments.first?.id {
            controller.removePendingAttachment(id: attId)
            XCTAssertEqual(controller.pendingAttachments.count, 0)
        }
    }

    @MainActor
    func testMinimalConsumerInstantiates() {
        let view = MinimalConsumerView()
        XCTAssertNotNil(view.body)
    }

    @MainActor
    func testAgentMessageViewInstantiates() {
        let view = AgentMessageView(
            id: "msg-123",
            role: .assistant,
            content: "Hello from **AgentUI**",
            isDarkMode: false
        )
        XCTAssertNotNil(view.body)
    }
}
