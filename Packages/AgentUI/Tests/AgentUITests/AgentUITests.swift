//
//  AgentUITests.swift
//  AgentUITests
//

import XCTest
import SwiftUI
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
        XCTAssertEqual(ToolExecutionStatus.completed.label, "Completed")
        XCTAssertEqual(ToolExecutionStatus.failed.label, "Failed")
    }

    func testToolCallInspection() {
        let inspection = ToolCallInspection(
            service: "GitHub API",
            toolName: "fetch_pull_request",
            arguments: .json("{\"pr\": 999}"),
            resultSummary: nil,
            errorMessage: "Not found"
        )
        XCTAssertEqual(inspection.service, "GitHub API")
        XCTAssertEqual(inspection.toolName, "fetch_pull_request")
        XCTAssertEqual(inspection.errorMessage, "Not found")
    }

    @MainActor
    func testActivityStore() {
        let store = AgentActivityStore()
        XCTAssertTrue(store.sessions.isEmpty)

        store.begin(messageID: "msg-1")
        store.addStatus(
            messageID: "msg-1",
            title: "Searching documentation",
            summary: "Query: swiftui"
        )

        let session = store.session(for: "msg-1")
        XCTAssertNotNil(session)
        XCTAssertEqual(session?.items.count, 1)
        XCTAssertEqual(session?.items.first?.title, "Searching documentation")
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
        XCTAssertNotNil(view)
    }

    @MainActor
    func testAgentMessageViewInstantiates() {
        let view = AgentMessageView(
            id: "msg-123",
            role: .assistant,
            content: "Hello from **AgentUI**",
            isDarkMode: false
        )
        XCTAssertEqual(view.id, "msg-123")
    }

    @MainActor
    func testAgentComposerViewInstantiates() {
        let controller = MockAgentRuntimeController()
        var text = ""
        let view = AgentComposerView(
            messageText: Binding(get: { text }, set: { text = $0 }),
            driver: controller,
            isKeyboardVisible: false
        )
        XCTAssertNotNil(view)
    }

    func testAgentMessageFullPayload() {
        let msg = AgentMessage(
            id: "msg-canonical",
            role: .assistant,
            content: "Full canonical response",
            thoughts: "Initial thinking process",
            isThinking: false,
            timestamp: Date(),
            isCollapsed: false,
            isStreaming: false,
            streamError: nil,
            isRequestError: false,
            generationTimeSeconds: 1.45,
            contentChunks: [
                ContentChunk(id: "chunk-1", type: .paragraph, content: "Hello", isComplete: true)
            ],
            thinkingChunks: [
                ThinkingChunk(id: "tchunk-1", content: "Let's think", isComplete: true)
            ],
            webSearchState: WebSearchState(
                query: "SwiftUI architecture",
                status: .completed,
                sources: [WebSearchSource(id: "src-1", title: "Apple Docs", url: "https://apple.com")],
                reason: "User requested docs"
            ),
            urlFetches: [
                URLFetchState(id: "f-1", url: "https://apple.com", status: .completed)
            ],
            attachments: [
                Attachment(id: "att-1", type: .image, fileName: "test.png")
            ],
            contentParts: [
                MessageContentPart(id: "part-1", kind: .markdown, markdown: "Hello")
            ],
            annotations: [
                Annotation(type: "url", url_citation: URLCitation(title: "Source", url: "https://apple.com"))
            ]
        )
        XCTAssertEqual(msg.id, "msg-canonical")
        XCTAssertEqual(msg.contentChunks.count, 1)
        XCTAssertEqual(msg.thinkingChunks.count, 1)
        XCTAssertEqual(msg.webSearchState?.sources.count, 1)
        XCTAssertEqual(msg.urlFetches.count, 1)
        XCTAssertEqual(msg.attachments.count, 1)
        XCTAssertEqual(msg.contentParts.count, 1)
        XCTAssertEqual(msg.annotations?.count, 1)
        XCTAssertFalse(msg.shouldDisplayAsAttachment)
    }

    @MainActor
    func testAgentMessageViewWithDriverAndAccessory() {
        let controller = MockAgentRuntimeController()
        let msg = AgentMessage(role: .assistant, content: "Message with accessory")
        let view = AgentMessageView(
            message: msg,
            isDarkMode: true,
            isLastMessage: true,
            driver: controller
        ) {
            Text("Accessory View")
        }
        XCTAssertEqual(view.message.id, msg.id)
    }

    @MainActor
    func testAgentMessageTableViewInstantiates() {
        var isAtBottom = true
        var userHasScrolled = false
        var tableOpacity = 1.0
        let tableView = AgentMessageTableView(
            messages: [AgentMessage(role: .user, content: "Hello")],
            isDarkMode: false,
            isLoading: false,
            isAtBottom: Binding(get: { isAtBottom }, set: { isAtBottom = $0 }),
            userHasScrolled: Binding(get: { userHasScrolled }, set: { userHasScrolled = $0 }),
            scrollTrigger: UUID(),
            scrollToUserTrigger: UUID(),
            tableOpacity: Binding(get: { tableOpacity }, set: { tableOpacity = $0 }),
            keyboardHeight: 0
        )
        XCTAssertNotNil(tableView)
    }

    @MainActor
    func testAgentMessageListViewInstantiates() {
        let view = AgentMessageListView(
            messages: [AgentMessage(role: .user, content: "Hello")],
            isDarkMode: false,
            isLoading: false
        ) {
            Text("Composer")
        }
        XCTAssertNotNil(view)
    }

    @MainActor
    func testAgentChatSidebarViewInstantiates() {
        let session = AgentChatSessionDescriptor(id: "1", title: "Chat 1", createdAt: Date(), isBlankChat: false)
        let sidebar = AgentChatSidebarView(
            sessions: [session],
            currentSessionId: "1",
            onSelectSession: { _ in },
            onDeleteSession: { _ in },
            onRenameSession: { _, _ in },
            onCreateNewSession: { }
        )
        XCTAssertNotNil(sidebar)
    }

    @MainActor
    func testAgentChatViewInstantiates() {
        let chatView = AgentChatView(
            sidebar: { Text("Sidebar") },
            detail: { Text("Detail") }
        )
        XCTAssertNotNil(chatView)
    }
}
