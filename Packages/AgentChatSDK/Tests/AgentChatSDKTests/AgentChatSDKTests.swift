import Foundation
#if canImport(XCTest)
import XCTest
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(SnapshotTesting)
import SnapshotTesting
#endif

import AgentChatCore
import AgentChatActivity
import AgentChatToolPresentation
import AgentChatSources
import AgentChatRichMedia
import AgentChatComposerExtensions
import AgentChatVoice
import AgentChatSDK

@MainActor
final class AgentChatSDKTests: XCTestCase {

    // MARK: - 1. Canonical Chat & Message Models Tests

    func testCanonicalChatAndMessageModels() {
        let chat = Chat.create(
            title: "Test Chat",
            titleState: .manual,
            messages: [
                Message(
                    id: "user-1",
                    role: .user,
                    content: "Can you analyze this system?"
                ),
                Message(
                    id: "assistant-1",
                    role: .assistant,
                    content: "Analyzing the architecture...",
                    thoughts: "The system is composed of modular SDK targets.",
                    isThinking: false,
                    isStreaming: false
                )
            ],
            modelType: .gpt4o
        )

        XCTAssertEqual(chat.messages.count, 2)
        XCTAssertEqual(chat.messages[0].role, .user)
        XCTAssertEqual(chat.messages[1].role, .assistant)
        XCTAssertEqual(chat.messages[1].thoughts, "The system is composed of modular SDK targets.")
        XCTAssertFalse(chat.isBlankChat)
        XCTAssertFalse(chat.needsGeneratedTitle)
    }

    // MARK: - 2. Async Event Buffer with Collections & AsyncAlgorithms

    func testAsyncEventBufferBoundedCapacity() {
        let buffer = AsyncEventBuffer<String>(capacity: 3)
        buffer.append("Item 1")
        buffer.append("Item 2")
        buffer.append("Item 3")
        buffer.append("Item 4") // Should evict Item 1

        let elements = buffer.allElements
        XCTAssertEqual(elements.count, 3)
        XCTAssertEqual(elements, ["Item 2", "Item 3", "Item 4"])
    }

    // MARK: - 3. Agent Activity Store Lifecycle

    func testAgentActivityStoreLifecycle() {
        let store = AgentActivityStore()
        let msgID = "test-msg-activity"

        store.begin(messageID: msgID)
        XCTAssertNotNil(store.session(for: msgID))

        store.beginReasoning(messageID: msgID, summary: "Thinking deeply")
        let session = store.session(for: msgID)
        XCTAssertEqual(session?.items.count, 1)
        XCTAssertEqual(session?.items.first?.kind, .reasoning)
        XCTAssertEqual(session?.items.first?.title, "Thinking deeply")

        store.beginWebSearch(messageID: msgID)
        store.addSearchSource(messageID: msgID, source: WebSearchSource(title: "Apple HIG", url: "https://developer.apple.com"))
        store.completeWebSearch(messageID: msgID)

        let updatedSession = store.session(for: msgID)
        XCTAssertEqual(updatedSession?.items.count, 2)

        store.markAnswerStarted(messageID: msgID)
        XCTAssertTrue(store.session(for: msgID)?.answerStarted ?? false)
    }

    // MARK: - 4. Tool Execution Store & Inspection

    func testToolExecutionDemoStoreInspection() {
        let store = ToolExecutionDemoStore.shared
        let executions = store.executions(for: ToolExecutionDemoStore.demoAssistantMessageID)

        XCTAssertFalse(executions.isEmpty)
        let githubTool = executions.first { $0.call.service == "GitHub" }
        XCTAssertNotNil(githubTool)
        XCTAssertEqual(githubTool?.status, .completed)
        XCTAssertTrue(githubTool?.call.arguments.formattedText.contains("sachaservan/SwiftChat") ?? false)
    }

    // MARK: - 5. Realtime Voice Provider Lifecycle

    func testMockVoiceProviderLifecycle() async throws {
        let provider = AgentMockVoiceProvider()
        XCTAssertEqual(provider.state, .disconnected)

        try await provider.startSession()
        XCTAssertTrue(provider.state == .connecting || provider.state == .listening)

        await provider.endSession()
        XCTAssertEqual(provider.state, .disconnected)
        XCTAssertEqual(provider.audioLevel, 0.0)
    }

    // MARK: - 6. Rich Media Content Parts (SVG, Video, YouTube, Lottie)

    func testRichMediaContentParts() {
        let svgPart = MessageContentPart(
            kind: .svg,
            caption: "System Architecture",
            svgString: "<svg height='100' width='100'><circle cx='50' cy='50' r='40'/></svg>"
        )
        XCTAssertEqual(svgPart.kind, .svg)
        XCTAssertNotNil(svgPart.svgString)

        let videoPart = MessageContentPart(
            kind: .video,
            title: "Demo Video",
            url: "https://example.com/demo.mp4"
        )
        XCTAssertEqual(videoPart.kind, .video)

        let lottiePart = MessageContentPart(
            kind: .lottie,
            title: "Success Animation",
            lottieAnimationName: "checkmark"
        )
        XCTAssertEqual(lottiePart.kind, .lottie)
    }

    // MARK: - 7. SwiftChat-derived Public Facade Session

    func testAgentChatSessionInitialization() {
        let session = AgentChatSession()
        XCTAssertNotNil(session.viewModel)
        XCTAssertNotNil(session.activityStore)
        XCTAssertNotNil(session.toolStore)
        XCTAssertNotNil(session.voiceProvider)
    }

    // MARK: - 8. Snapshot & Parity Testing

#if os(iOS) && canImport(SnapshotTesting)
    func testParitySnapshotViews() {
        // Representative Views for Visual Regression Testing
        let userMessage = Message(
            role: .user,
            content: "Explain SwiftUI and show a diagram."
        )

        let assistantMessage = Message(
            role: .assistant,
            content: "Here is the explanation with sources and diagram.",
            contentParts: [
                MessageContentPart(kind: .markdown, markdown: "SwiftUI is Apple's declarative framework."),
                MessageContentPart(
                    kind: .svg,
                    caption: "SwiftUI Hierarchy",
                    svgString: "<svg height='60' width='120'><rect width='120' height='60' fill='blue'/></svg>"
                )
            ]
        )

        let toolInspection = ToolCallInspection(
            service: "GitHub",
            toolName: "github_search",
            arguments: .text("repo: sachaservan/SwiftChat"),
            resultSummary: "Found repository"
        )

        let toolDisclosure = ToolExecutionDisclosure(call: toolInspection, status: .completed) {
            Text("Inspected GitHub Repository")
        }

        // Test light mode on iPhone
        assertSnapshot(of: toolDisclosure, as: .image(layout: .fixed(width: 375, height: 120)))

        // Test dark mode on iPhone
        let darkDisclosure = toolDisclosure.environment(\.colorScheme, .dark)
        assertSnapshot(of: darkDisclosure, as: .image(layout: .fixed(width: 375, height: 120)))

        // Test iPad width
        assertSnapshot(of: toolDisclosure, as: .image(layout: .fixed(width: 768, height: 120)))

        // Test Voice Orb
        let voiceOrb = AgentVoiceOrbView(state: .listening, audioLevel: 0.5, size: 160)
        assertSnapshot(of: voiceOrb, as: .image(layout: .fixed(width: 200, height: 200)))
    }
#endif
}
