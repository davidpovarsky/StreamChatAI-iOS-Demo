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
#if canImport(Kingfisher)
import Kingfisher
#endif
#if canImport(UIKit)
import UIKit
#endif

import AgentChatCore
import AgentChatMotion
import AgentChatMarkdown
import AgentChatSources
import AgentChatRichMedia
import AgentChatActivity
import AgentChatToolPresentation
import AgentChatResultCards
import AgentChatComposer
import AgentChatCanvas
import AgentChatVoice
import AgentChatUI
import AgentChatSDK

@MainActor
final class AgentChatSDKTests: XCTestCase {

    // MARK: - 1. Canonical Conversation & Message Models Tests

    func testCanonicalChatAndMessageModels() {
        let msg1 = ChatMessage(
            id: "user-1",
            conversationId: "conv-1",
            role: .user,
            segments: [.init(kind: .markdown("Can you analyze this system?"))]
        )
        let msg2 = ChatMessage(
            id: "assistant-1",
            conversationId: "conv-1",
            role: .assistant,
            segments: [.init(kind: .markdown("Analyzing the architecture..."))],
            runIds: ["run-1"],
            isStreaming: false
        )

        let conv = Conversation(
            id: "conv-1",
            title: "Test Chat",
            messages: [msg1, msg2],
            selectedModel: .gpt4o
        )

        XCTAssertEqual(conv.messages.count, 2)
        XCTAssertEqual(conv.messages[0].role, .user)
        XCTAssertEqual(conv.messages[1].role, .assistant)
        XCTAssertEqual(conv.messages[1].plainTextContent, "Analyzing the architecture...")
        XCTAssertEqual(conv.lastMessagePreview, "Analyzing the architecture...")
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
        let chunkedSequence = buffer.chunkedStream(count: 2)

        let consumeTask = Task<[[String]], Never> {
            var chunks: [[String]] = []
            for await chunk in chunkedSequence {
                chunks.append(chunk)
                if chunks.count >= 1 {
                    break
                }
            }
            return chunks
        }

        try? await Task.sleep(nanoseconds: 30_000_000)

        buffer.append("Token 1")
        buffer.append("Token 2")

        let received = await consumeTask.value
        XCTAssertEqual(received.count, 1)
        XCTAssertEqual(received.first, ["Token 1", "Token 2"])
    }

    // MARK: - 3. Hierarchical Activity Lifecycle & Reducer Invariants

    func testHierarchicalActivityLifecycleAndReducer() {
        var conv = Conversation(id: "conv-test", title: "Test")
        let runId = "run-1"
        let msgId = "assistant-1"

        // Event 1: Run Started -> MUST default to collapsed (isExpanded == false)
        AgentEventReducer.reduce(conversation: &conv, event: .runStarted(runId: runId, messageId: msgId))
        let run = conv.runs[runId]
        XCTAssertNotNil(run)
        XCTAssertEqual(run?.status, .running)
        XCTAssertFalse(run?.isExpanded ?? true, "Hierarchical activity MUST be collapsed by default!")

        // Event 2: Group Started
        AgentEventReducer.reduce(conversation: &conv, event: .groupStarted(
            runId: runId,
            groupId: "research",
            stage: .research,
            title: "Researching topic"
        ))
        XCTAssertEqual(conv.runs[runId]?.groups.count, 1)
        XCTAssertFalse(conv.runs[runId]?.groups[0].isExpanded ?? true, "Group MUST be collapsed by default!")

        // Event 3: Tool Requested
        AgentEventReducer.reduce(conversation: &conv, event: .toolRequested(
            runId: runId,
            groupId: "research",
            operationId: "op-1",
            tool: "web_search",
            title: "Searched 5 websites",
            arguments: "{\"query\": \"iOS 27 SDK\"}"
        ))
        XCTAssertEqual(conv.runs[runId]?.groups[0].operations.count, 1)
        XCTAssertEqual(conv.runs[runId]?.groups[0].operations[0].status, .running)

        // Event 4: Content Delta (Streaming tokens MUST NOT expand or collapse activity)
        AgentEventReducer.reduce(conversation: &conv, event: .contentDelta(messageId: msgId, text: "Findings:"))
        XCTAssertFalse(conv.runs[runId]?.isExpanded ?? true, "Incoming tokens MUST NOT mutate activity expansion!")

        // Event 5: Tool Completed with Sources
        let s1 = WebSearchSource(title: "Apple Dev", url: "https://developer.apple.com")
        AgentEventReducer.reduce(conversation: &conv, event: .toolCompleted(
            runId: runId,
            operationId: "op-1",
            resultSummary: "Complete",
            payload: nil,
            sources: [s1]
        ))
        XCTAssertEqual(conv.runs[runId]?.groups[0].operations[0].status, .completed)
        XCTAssertEqual(conv.runs[runId]?.groups[0].operations[0].sources.count, 1)

        // Event 6: Run Finished
        AgentEventReducer.reduce(conversation: &conv, event: .runFinished(runId: runId, status: .completed))
        XCTAssertEqual(conv.runs[runId]?.status, .completed)
        XCTAssertFalse(conv.runs[runId]?.isExpanded ?? true, "Completed run MUST remain collapsed until user explicitly opens it!")
    }

    // MARK: - 4. Approval Request State Machine

    func testApprovalRequestStateMachine() {
        var conv = Conversation(id: "conv-app")
        let runId = "run-app"
        let msgId = "msg-app"
        AgentEventReducer.reduce(conversation: &conv, event: .runStarted(runId: runId, messageId: msgId))

        let approval = ApprovalRequest(
            id: "app-1",
            runId: runId,
            title: "Calendar Permission",
            descriptionText: "Add event to Calendar",
            provider: "EventKit"
        )
        AgentEventReducer.reduce(conversation: &conv, event: .approvalRequested(approval: approval))
        XCTAssertEqual(conv.runs[runId]?.approvals.count, 1)
        XCTAssertEqual(conv.runs[runId]?.approvals[0].status, .requested)

        AgentEventReducer.reduce(conversation: &conv, event: .approvalResolved(requestId: "app-1", status: .approved))
        XCTAssertEqual(conv.runs[runId]?.approvals[0].status, .approved)
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

    // MARK: - 6. Rich Media Content Parts (SVG, Video, Lottie)

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
            url: "https://example.com/demo.mp4",
            title: "Demo Video"
        )
        XCTAssertEqual(videoPart.kind, .video)

        let lottiePart = MessageContentPart(
            kind: .lottie,
            title: "Success Animation",
            lottieAnimationName: "checkmark"
        )
        XCTAssertEqual(lottiePart.kind, .lottie)
    }

    // MARK: - 7. Standalone Native AgentChatSession

    func testAgentChatSessionInitialization() {
        let session = AgentChatSession()
        XCTAssertEqual(session.conversations.count, 1)
        XCTAssertFalse(session.isStreaming)
        XCTAssertEqual(session.selectedModel.id, "gpt-4o")

        session.sendMessage("Hello native assistant!")
        XCTAssertEqual(session.currentConversation.messages.count, 2)
        XCTAssertTrue(session.isStreaming)

        session.cancel()
        XCTAssertFalse(session.isStreaming)
    }

    // MARK: - 8. Rich Result Registry & Typed Dispatches

    func testNativeResultCardRendererRegistry() {
        let registry = AgentResultRendererRegistry.shared
        let res = AgentResult(
            messageId: "m1",
            kind: .chart,
            title: "Quarterly Revenue",
            payload: AgentResultPayload(metadata: ["points": .string("Q1:100,Q2:150")])
        )
        XCTAssertEqual(res.kind, .chart)
        XCTAssertEqual(res.schemaVersion, 1)
    }

    // MARK: - 9. Snapshot Suite (All 22 Required Visual States)

#if os(iOS) && canImport(SnapshotTesting)

    func testVisualSnapshotSuite() {
        let s1 = WebSearchSource(title: "Apple HIG", url: "https://developer.apple.com")
        let s2 = WebSearchSource(title: "Swift.org", url: "https://swift.org")

        let imgPart = MessageContentPart(kind: .image, url: "https://example.com/img.png", title: "Preview")
        let svgPart = MessageContentPart(kind: .svg, caption: "Diagram", svgString: "<svg height='60' width='120'><rect width='120' height='60' fill='blue'/></svg>")
        let videoPart = MessageContentPart(kind: .video, url: "https://example.com/demo.mp4", title: "Video Tutorial")

        // 1. Empty / Initial Chat
        let emptySession = AgentChatSession()
        let emptyView = AgentChatView(session: emptySession, configuration: emptySession.configuration)
        assertSnapshot(of: emptyView, as: .image(layout: .fixed(width: 375, height: 600)), named: "01_EmptyInitialChat")

        // 2. User Message
        let userMsg = ChatMessage(
            id: "user-1",
            conversationId: "demo",
            role: .user,
            segments: [.init(kind: .markdown("What is the new native AgentChatSDK?"))]
        )
        let userMsgView = AgentUserMessageView(message: userMsg)
        assertSnapshot(of: userMsgView, as: .image(layout: .fixed(width: 375, height: 80)), named: "02_UserMessage")

        // 3. Normal Assistant Message
        let assistantMsg = ChatMessage(
            id: "assistant-1",
            conversationId: "demo",
            role: .assistant,
            segments: [.init(kind: .markdown("AgentChatSDK is a 100% native SwiftUI SDK with hierarchical agent activity."))],
            runIds: []
        )
        let assistantMsgView = AgentAssistantMessageView(
            message: assistantMsg,
            runs: [:],
            onToggleRun: { _ in },
            onToggleGroup: { _, _ in },
            onToggleOperation: { _, _ in },
            onSelectInspector: { _ in },
            onAction: { _ in },
            onRetry: {}
        )
        assertSnapshot(of: assistantMsgView, as: .image(layout: .fixed(width: 375, height: 100)), named: "03_NormalAssistantMessage")

        // 4. Streaming Assistant Message
        let streamingMsg = ChatMessage(
            id: "assistant-stream",
            conversationId: "demo",
            role: .assistant,
            segments: [.init(kind: .markdown("Generating native response incrementally..."))],
            isStreaming: true
        )
        let streamingMsgView = AgentAssistantMessageView(
            message: streamingMsg,
            runs: [:],
            onToggleRun: { _ in },
            onToggleGroup: { _, _ in },
            onToggleOperation: { _, _ in },
            onSelectInspector: { _ in },
            onAction: { _ in },
            onRetry: {}
        )
        assertSnapshot(of: streamingMsgView, as: .image(layout: .fixed(width: 375, height: 100)), named: "04_StreamingAssistantMessage")

        // 5. Reasoning / Activity Collapsed (Default)
        let runCollapsed = AgentRun(
            id: "run-col",
            messageId: "m1",
            status: .completed,
            startedAt: Date(timeIntervalSinceNow: -124),
            completedAt: Date(),
            groups: [
                ActivityGroup(id: "g1", stage: .research, title: "Researched UI frameworks", operations: [
                    ActivityOperation(id: "op1", toolName: "web_search", title: "Searched 8 websites", status: .completed, sources: [s1, s2])
                ])
            ],
            isExpanded: false
        )
        let activityHeader = AgentRunDisclosureHeader(run: runCollapsed, isExpanded: false) {}
        assertSnapshot(of: activityHeader, as: .image(layout: .fixed(width: 375, height: 44)), named: "05_ReasoningActivityState")

        // 6. Web Search State / Source Chips
        let sourceChips = AgentSourceChipsView(sources: [s1, s2])
        assertSnapshot(of: sourceChips, as: .image(layout: .fixed(width: 375, height: 44)), named: "06_WebSearchState")

        // 7. Inline Citations / Sources
        let inlineSourcesView = AgentSourceChipsView(sources: [s1, s2])
        assertSnapshot(of: inlineSourcesView, as: .image(layout: .fixed(width: 375, height: 44)), named: "07_InlineCitationsSources")

        // 8. Expanded Sources Sheet
        let sourcesSheet = SourcesSheetView(sources: [s1, s2], isDarkMode: false)
        assertSnapshot(of: sourcesSheet, as: .image(layout: .fixed(width: 375, height: 260)), named: "08_ExpandedSources")

        // 9. Tool Running inside Group
        let opRunning = ActivityOperation(id: "op-r", toolName: "github_search", title: "Searching repositories", status: .running)
        let opRunningRow = AgentActivityOperationRow(operation: opRunning, onToggle: {}, onSelectInspector: {})
        assertSnapshot(of: opRunningRow, as: .image(layout: .fixed(width: 375, height: 40)), named: "09_ToolRunning")

        // 10. Tool Completed
        let opCompleted = ActivityOperation(id: "op-c", toolName: "github_search", title: "Found repository", status: .completed, duration: 1.2)
        let opCompletedRow = AgentActivityOperationRow(operation: opCompleted, onToggle: {}, onSelectInspector: {})
        assertSnapshot(of: opCompletedRow, as: .image(layout: .fixed(width: 375, height: 40)), named: "10_ToolCompleted")

        // 11. Tool Failed
        let opFailed = ActivityOperation(id: "op-f", toolName: "sql_exec", title: "Host unreachable", status: .failed)
        let opFailedRow = AgentActivityOperationRow(operation: opFailed, onToggle: {}, onSelectInspector: {})
        assertSnapshot(of: opFailedRow, as: .image(layout: .fixed(width: 375, height: 40)), named: "11_ToolFailed")

        // 12. Hierarchical Activity Tree Expanded
        var runExpanded = runCollapsed
        runExpanded.isExpanded = true
        runExpanded.groups[0].isExpanded = true
        let treeExpanded = AgentHierarchicalActivityView(
            run: runExpanded,
            onToggleRun: {},
            onToggleGroup: { _ in },
            onToggleOperation: { _ in },
            onSelectInspector: { _ in }
        )
        assertSnapshot(of: treeExpanded, as: .image(layout: .fixed(width: 375, height: 160)), named: "12_ToolDisclosureExpanded")

        // 13. Remote Image
#if canImport(Kingfisher) && canImport(UIKit)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 320, height: 180))
        let fixtureImage = renderer.image { ctx in
            UIColor.systemIndigo.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 320, height: 180))
        }
        ImageCache.default.store(fixtureImage, forKey: "https://example.com/img.png")
#endif
        let imageView = SafeInlineImageMediaView(part: imgPart, isDarkMode: false)
        assertSnapshot(of: imageView, as: .image(layout: .fixed(width: 375, height: 200)), named: "13_RemoteImage")

        // 14. SVG Vector
        let svgView = InlineSVGMediaView(part: svgPart, isDarkMode: false)
        assertSnapshot(of: svgView, as: .image(layout: .fixed(width: 375, height: 140)), named: "14_SVGVector")

        // 15. Video Rich Media
        let videoView = SafeInlineVideoMediaView(part: videoPart, isDarkMode: false)
        assertSnapshot(of: videoView, as: .image(layout: .fixed(width: 375, height: 160)), named: "15_VideoRichMedia")

        // 16. Composer
        let composer = AgentComposerView(
            text: .constant("What is the architecture of AgentChatSDK?"),
            attachments: .constant([]),
            isStreaming: false,
            selectedModel: .constant(.gpt4o),
            onSend: { _, _, _ in },
            onStop: {}
        )
        assertSnapshot(of: composer, as: .image(layout: .fixed(width: 375, height: 110)), named: "16_Composer")

        // 17. Approval Request Card
        let approvalReq = ApprovalRequest(runId: "r1", title: "Calendar Access", descriptionText: "Add Design Review on Tuesday", provider: "EventKit")
        let approvalCard = AgentApprovalRequestCard(approval: approvalReq) { _ in }
        assertSnapshot(of: approvalCard, as: .image(layout: .fixed(width: 375, height: 140)), named: "17_ModelSelectorMenu")

        // 18. Light Mode Assistant
        let lightAssistant = assistantMsgView.environment(\.colorScheme, .light)
        assertSnapshot(of: lightAssistant, as: .image(layout: .fixed(width: 375, height: 100)), named: "18_LightMode")

        // 19. Dark Mode Assistant
        let darkAssistant = assistantMsgView.environment(\.colorScheme, .dark)
        assertSnapshot(of: darkAssistant, as: .image(layout: .fixed(width: 375, height: 100)), named: "19_DarkMode")

        // 20. RTL / Hebrew Assistant
        let hebrewMsg = ChatMessage(
            id: "hebrew-1",
            conversationId: "demo",
            role: .assistant,
            segments: [.init(kind: .markdown("שלום! זוהי הדגמה של עברית מלאה וכיווניות מימין לשמאל."))]
        )
        let hebrewView = AgentAssistantMessageView(
            message: hebrewMsg,
            runs: [:],
            onToggleRun: { _ in },
            onToggleGroup: { _, _ in },
            onToggleOperation: { _, _ in },
            onSelectInspector: { _ in },
            onAction: { _ in },
            onRetry: {}
        ).environment(\.layoutDirection, .rightToLeft)
        assertSnapshot(of: hebrewView, as: .image(layout: .fixed(width: 375, height: 100)), named: "20_RTLHebrew")

        // 21. Narrow iPhone Width
        assertSnapshot(of: treeExpanded, as: .image(layout: .fixed(width: 320, height: 160)), named: "21_NarrowiPhoneWidth")

        // 22. iPad Regular Width
        assertSnapshot(of: treeExpanded, as: .image(layout: .fixed(width: 768, height: 160)), named: "22_iPadRegularWidth")
    }

    // MARK: - 10. Motion System & Accessibility Reduce Motion Tests

    func testAgentMotionPolicyAndReduceMotion() {
        let policy = AgentMotionPolicy(forceReduceMotion: true)
        XCTAssertTrue(policy.effectiveReduceMotion(systemReduceMotion: false))

        let normalPolicy = AgentMotionPolicy(forceReduceMotion: false)
        XCTAssertFalse(normalPolicy.effectiveReduceMotion(systemReduceMotion: false))
    }

    func testAgentLottieMediaViewReduceMotion() {
        let viewAnimated = AgentLottieMediaView(animationName: "sparkles", isDarkMode: false, forceReduceMotion: false)
        assertSnapshot(of: viewAnimated, as: .image(layout: .fixed(width: 100, height: 100)), named: "Lottie_Animated")

        let viewReduceMotion = AgentLottieMediaView(animationName: "sparkles", isDarkMode: false, forceReduceMotion: true)
        assertSnapshot(of: viewReduceMotion, as: .image(layout: .fixed(width: 100, height: 100)), named: "Lottie_ReduceMotion")
    }

#endif
}
