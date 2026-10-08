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
import AgentChatSwiftChat
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
        buffer.append("Item 4") // Evicts Item 1

        let elements = buffer.allElements
        XCTAssertEqual(elements.count, 3)
        XCTAssertEqual(elements, ["Item 2", "Item 3", "Item 4"])
    }

    func testAsyncEventBufferAsyncAlgorithmsStreaming() async {
        let buffer = AsyncEventBuffer<String>(capacity: 10)
        buffer.append("Token 1")
        buffer.append("Token 2")
        buffer.append("Token 3")

        let all = buffer.allElements
        XCTAssertEqual(all.count, 3)
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

    // MARK: - 8. Snapshot Suite (All 22 Required States)

#if os(iOS) && canImport(SnapshotTesting)

    func testVisualSnapshotSuite() {
        // Shared Fixtures
        let s1 = WebSearchSource(title: "Apple HIG", url: "https://developer.apple.com")
        let s2 = WebSearchSource(title: "SwiftChat", url: "https://github.com/sachaservan/SwiftChat")

        let toolInspection = ToolCallInspection(
            service: "GitHub",
            toolName: "github_search",
            arguments: .text("repo: sachaservan/SwiftChat"),
            resultSummary: "Found repository"
        )

        let imgPart = MessageContentPart(kind: .image, title: "Preview", url: "https://example.com/img.png")
        let svgPart = MessageContentPart(kind: .svg, caption: "Diagram", svgString: "<svg height='60' width='120'><rect width='120' height='60' fill='blue'/></svg>")
        let videoPart = MessageContentPart(kind: .video, title: "Video Tutorial", url: "https://example.com/demo.mp4")

        // 1. Empty / Initial Chat
        let emptySession = AgentChatSession()
        let emptyView = AgentChatView(session: emptySession, configuration: emptySession.configuration)
        assertSnapshot(of: emptyView, as: .image(layout: .fixed(width: 375, height: 600)), named: "01_EmptyInitialChat")

        // 2. User Message
        let userMsg = Message(role: .user, content: "What is SwiftChat?")
        let userMsgView = MessageView(message: userMsg, isLast: true, isEditing: false, viewModel: emptySession.viewModel)
        assertSnapshot(of: userMsgView, as: .image(layout: .fixed(width: 375, height: 80)), named: "02_UserMessage")

        // 3. Normal Assistant Message
        let assistantMsg = Message(role: .assistant, content: "SwiftChat is an open-source ChatGPT-style client for iOS.")
        let assistantMsgView = MessageView(message: assistantMsg, isLast: true, isEditing: false, viewModel: emptySession.viewModel)
        assertSnapshot(of: assistantMsgView, as: .image(layout: .fixed(width: 375, height: 100)), named: "03_NormalAssistantMessage")

        // 4. Streaming Assistant Message
        let streamingMsg = Message(role: .assistant, content: "Generating response incrementally...", isStreaming: true)
        let streamingMsgView = MessageView(message: streamingMsg, isLast: true, isEditing: false, viewModel: emptySession.viewModel)
        assertSnapshot(of: streamingMsgView, as: .image(layout: .fixed(width: 375, height: 100)), named: "04_StreamingAssistantMessage")

        // 5. Reasoning / Activity State
        let actSession = AgentActivitySession(
            messageID: "reasoning-msg",
            startedAt: Date(),
            items: [
                AgentActivityItem(kind: .reasoning, title: "Analyzing system dependencies"),
                AgentActivityItem(kind: .status, status: .completed, title: "Inspected SwiftChat architecture")
            ],
            answerStarted: false,
            isExpanded: true
        )
        let activityView = AgentActivityTimelineView(session: actSession, isDarkMode: false) {}
        assertSnapshot(of: activityView, as: .image(layout: .fixed(width: 375, height: 110)), named: "05_ReasoningActivityState")

        // 6. Web Search State
        let webSearchBox = WebSearchBox(source: s1)
        assertSnapshot(of: webSearchBox, as: .image(layout: .fixed(width: 375, height: 60)), named: "06_WebSearchState")

        // 7. Inline Citations / Sources
        let inlineSourcesView = InlineSectionSourcesView(
            markdown: "According to Apple guidelines, materials provide depth.",
            sources: [s1, s2],
            isDarkMode: false
        ) { Text($0) }
        assertSnapshot(of: inlineSourcesView, as: .image(layout: .fixed(width: 375, height: 80)), named: "07_InlineCitationsSources")

        // 8. Expanded Sources
        let sourcesSheet = SourcesSheetView(sources: [s1, s2], isDarkMode: false)
        assertSnapshot(of: sourcesSheet, as: .image(layout: .fixed(width: 375, height: 260)), named: "08_ExpandedSources")

        // 9. Tool Running
        let toolRunning = ToolExecutionDisclosure(call: toolInspection, status: .running) {
            Text("Inspecting GitHub Repository")
        }
        assertSnapshot(of: toolRunning, as: .image(layout: .fixed(width: 375, height: 60)), named: "09_ToolRunning")

        // 10. Tool Completed
        let toolCompleted = ToolExecutionDisclosure(call: toolInspection, status: .completed) {
            Text("Inspected GitHub Repository")
        }
        assertSnapshot(of: toolCompleted, as: .image(layout: .fixed(width: 375, height: 60)), named: "10_ToolCompleted")

        // 11. Tool Failed
        let failCall = ToolCallInspection(service: "Database", toolName: "sql_exec", arguments: .text("SELECT *"), resultSummary: nil, errorMessage: "Host unreachable")
        let toolFailed = ToolExecutionDisclosure(call: failCall, status: .failed) {
            Text("Database Query")
        }
        assertSnapshot(of: toolFailed, as: .image(layout: .fixed(width: 375, height: 60)), named: "11_ToolFailed")

        // 12. Tool Disclosure Expanded
        let toolExpanded = ToolExecutionDisclosure(call: toolInspection, status: .completed, isExpanded: true) {
            Text("Inspected GitHub Repository")
        }
        assertSnapshot(of: toolExpanded, as: .image(layout: .fixed(width: 375, height: 180)), named: "12_ToolDisclosureExpanded")

        // 13. Remote Image
        let imageView = SafeInlineImageMediaView(part: imgPart, isDarkMode: false)
        assertSnapshot(of: imageView, as: .image(layout: .fixed(width: 375, height: 200)), named: "13_RemoteImage")

        // 14. SVG Vector
        let svgView = InlineSVGMediaView(part: svgPart, isDarkMode: false)
        assertSnapshot(of: svgView, as: .image(layout: .fixed(width: 375, height: 140)), named: "14_SVGVector")

        // 15. Video Rich Media
        let videoView = SafeInlineVideoMediaView(part: videoPart, isDarkMode: false)
        assertSnapshot(of: videoView, as: .image(layout: .fixed(width: 375, height: 160)), named: "15_VideoRichMedia")

        // 16. Composer
        let composer = MessageInputView(
            isDarkMode: false,
            text: .constant("What is the speed of light?"),
            viewModel: emptySession.viewModel,
            onSend: {}
        )
        assertSnapshot(of: composer, as: .image(layout: .fixed(width: 375, height: 80)), named: "16_Composer")

        // 17. Model Menu (Add menu popover)
        let modelMenu = SelectedModelMenu(currentModel: .gpt4o, isDarkMode: false, isLoading: false) { _ in }
        assertSnapshot(of: modelMenu, as: .image(layout: .fixed(width: 200, height: 44)), named: "17_ModelMenu")

        // 18. Light Mode
        let lightAssistant = assistantMsgView.environment(\.colorScheme, .light)
        assertSnapshot(of: lightAssistant, as: .image(layout: .fixed(width: 375, height: 100)), named: "18_LightMode")

        // 19. Dark Mode
        let darkAssistant = assistantMsgView.environment(\.colorScheme, .dark)
        assertSnapshot(of: darkAssistant, as: .image(layout: .fixed(width: 375, height: 100)), named: "19_DarkMode")

        // 20. RTL / Hebrew
        let hebrewMsg = Message(role: .assistant, content: "שלום! זוהי הדגמה של עברית וכיווניות מימין לשמאל.")
        let hebrewView = MessageView(message: hebrewMsg, isLast: true, isEditing: false, viewModel: emptySession.viewModel)
            .environment(\.layoutDirection, .rightToLeft)
        assertSnapshot(of: hebrewView, as: .image(layout: .fixed(width: 375, height: 100)), named: "20_RTLHebrew")

        // 21. Narrow iPhone Width
        assertSnapshot(of: toolExpanded, as: .image(layout: .fixed(width: 320, height: 180)), named: "21_NarrowiPhoneWidth")

        // 22. iPad Regular Width
        assertSnapshot(of: toolExpanded, as: .image(layout: .fixed(width: 768, height: 180)), named: "22_iPadRegularWidth")
    }

#endif
}
