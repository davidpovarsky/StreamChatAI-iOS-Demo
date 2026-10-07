#if canImport(AgentChatActivity)
import AgentChatActivity
#endif
#if canImport(AgentChatCore)
import AgentChatCore
#endif
#if canImport(AgentChatIntegrations)
import AgentChatIntegrations
#endif
#if canImport(AgentChatMedia)
import AgentChatMedia
#endif
#if canImport(AgentChatRendering)
import AgentChatRendering
#endif
#if canImport(AgentChatRichResults)
import AgentChatRichResults
#endif
#if canImport(AgentChatSDK)
import AgentChatSDK
#endif
#if canImport(AgentChatUI)
import AgentChatUI
#endif
#if canImport(AgentChatVoice)
import AgentChatVoice
#endif
#if canImport(Combine)
import Combine
#endif
#if canImport(SnapshotTesting)
import SnapshotTesting
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(XCTest)
import XCTest

@MainActor
final class AgentChatSDKTests: XCTestCase {

    // 1. Message Model & Blocks Test
    func testMessageModelAndBlocks() {
        let msg = AgentMessage(
            role: .assistant,
            blocks: [
                .markdown(id: "1", text: "Hello world"),
                .code(id: "2", code: "print(1)", language: "swift"),
                .math(id: "3", formula: "x^2", displayMode: true)
            ],
            rawText: "Hello world",
            generationState: .completed
        )

        XCTAssertEqual(msg.role, .assistant)
        XCTAssertEqual(msg.blocks.count, 3)
        XCTAssertFalse(msg.isGenerating)
        XCTAssertEqual(msg.blocks[0].id, "1")
    }

    // 2. Activity Session & Event Transitions Test
    func testActivitySessionAndEvents() {
        let session = AgentChatSession()
        let assistantID = session.startAssistantMessage()

        XCTAssertTrue(session.isGenerating)
        XCTAssertEqual(session.messages.count, 1)

        session.publishEvent(.sessionStarted(messageID: assistantID))
        session.publishEvent(.reasoningStarted(messageID: assistantID, summary: "Initial reasoning"))
        session.publishEvent(.reasoningUpdated(messageID: assistantID, summary: "Updated reasoning"))
        session.publishEvent(.webSearchStarted(messageID: assistantID, query: "Swift 6"))
        session.publishEvent(.sourceDiscovered(messageID: assistantID, source: AgentSource(title: "Swift.org", url: "https://swift.org")))
        session.publishEvent(.webSearchCompleted(messageID: assistantID))

        XCTAssertNotNil(session.currentActivity)
        let items = session.currentActivity?.items ?? []
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].kind, .reasoning)
        XCTAssertEqual(items[0].title, "Updated reasoning")
        XCTAssertEqual(items[1].kind, .webSearch)
        XCTAssertEqual(items[1].sources.count, 1)
        XCTAssertEqual(items[1].status, .completed)
    }

    // 3. Tool State Transitions Test
    func testToolStateTransitions() {
        let session = AgentChatSession()
        let msgID = session.startAssistantMessage()
        let toolID = "tool-weather"

        session.publishEvent(.toolStarted(messageID: msgID, toolID: toolID, toolName: "weather_lookup", service: "Meteo", arguments: "{\"loc\":\"NYC\"}"))
        session.publishEvent(.toolProgress(messageID: msgID, toolID: toolID, summary: "Querying radar"))
        session.publishEvent(.toolCompleted(messageID: msgID, toolID: toolID, resultSummary: "22C Sunny"))

        let activity = session.currentActivity
        let toolItem = activity?.items.first(where: { $0.id == toolID })
        XCTAssertNotNil(toolItem)
        XCTAssertEqual(toolItem?.status, .completed)
        XCTAssertEqual(toolItem?.toolResultSummary, "22C Sunny")

        let inspection = ToolCallInspection(
            call: AgentToolCall(id: toolID, name: "weather_lookup", arguments: "{\"loc\":\"NYC\"}"),
            result: AgentToolResult(callID: toolID, toolName: "weather_lookup", outputSummary: "22C Sunny")
        )
        XCTAssertEqual(inspection.toolName, "weather_lookup")
        XCTAssertEqual(inspection.rawOutput, "22C Sunny")
    }

    // 4. Tool Renderer Registry Test
    #if canImport(SwiftUI)
    func testToolRendererRegistry() {
        let registry = AgentToolRendererRegistry.shared
        XCTAssertNotNil(registry.renderer(for: "weather_lookup"))
        XCTAssertNotNil(registry.renderer(for: "stock_quote"))
        XCTAssertNotNil(registry.renderer(for: "calculator"))
        XCTAssertNil(registry.renderer(for: "unknown_tool_xyz"))
    }
    #endif

    // 5. Source Grouping & Parsing Test
    func testSourceGrouping() {
        let text = "Here is a fact.\n\nMore detailed analysis follows.\n\nReferences and citations."
        let presentation = SectionSourcesPresentation.parse(text)
        XCTAssertNotNil(presentation)
        XCTAssertEqual(presentation?.paragraphMarkdown, "References and citations.")
        XCTAssertEqual(presentation?.leadingMarkdown, "Here is a fact.\n\nMore detailed analysis follows.")
    }

    // 6. Markdown Parsing Test
    func testMarkdownParsing() {
        let parser = AgentMarkdownParser()
        let md = """
        Paragraph 1

        ```swift
        let x = 42
        ```

        Paragraph 2

        $$
        a^2 + b^2 = c^2
        $$
        """
        let blocks = parser.parse(markdown: md)
        XCTAssertEqual(blocks.count, 4)

        if case .markdown(_, let text) = blocks[0] {
            XCTAssertTrue(text.contains("Paragraph 1"))
        } else {
            XCTFail("Block 0 should be markdown")
        }

        if case .code(_, let code, let lang) = blocks[1] {
            XCTAssertEqual(lang, "swift")
            XCTAssertTrue(code.contains("let x = 42"))
        } else {
            XCTFail("Block 1 should be code")
        }

        if case .markdown(_, let text) = blocks[2] {
            XCTAssertTrue(text.contains("Paragraph 2"))
        } else {
            XCTFail("Block 2 should be markdown")
        }

        if case .math(_, let formula, let display) = blocks[3] {
            XCTAssertTrue(display)
            XCTAssertTrue(formula.contains("a^2 + b^2 = c^2"))
        } else {
            XCTFail("Block 3 should be math")
        }
    }

    // 7. Configuration Defaults & Capabilities Test
    func testConfigurationDefaultsAndCapabilities() {
        var config = AgentChatConfiguration()
        XCTAssertTrue(config.capabilities.supportsMarkdown)
        XCTAssertTrue(config.capabilities.supportsCodeHighlighting)
        XCTAssertTrue(config.capabilities.supportsLaTeXMath)
        XCTAssertTrue(config.capabilities.supportsVoice)

        config.capabilities.supportsVoice = false
        XCTAssertFalse(config.capabilities.supportsVoice)
        XCTAssertEqual(config.composer.maxLines, 6)
        XCTAssertEqual(config.appearance.userBubbleCornerRadius, 18.0)
    }

    // 8. Mock Voice State Machine Test
    func testMockVoiceStateMachine() async {
        let provider = AgentMockVoiceProvider()
        XCTAssertEqual(provider.currentState, .idle)

        do {
            try await provider.startSession()
            XCTAssertEqual(provider.currentState, .listening)
            await provider.stopSession()
            XCTAssertEqual(provider.currentState, .idle)
        } catch {
            XCTFail("Voice session failed with \(error)")
        }
    }

    // 9. Retry and Cancellation Test
    func testRetryAndCancellation() {
        let session = AgentChatSession()
        session.appendUserMessage(text: "Hello")
        let assistantID = session.startAssistantMessage()
        session.appendToken("First attempt", toMessageID: assistantID)
        session.completeAssistantMessage(id: assistantID)

        XCTAssertEqual(session.messages.count, 2)
        session.retryLastAssistantMessage()
        XCTAssertEqual(session.messages.count, 1)
        XCTAssertEqual(session.messages[0].role, .user)
    }

    // 10. Visual Surface Verification Tests
    #if canImport(SwiftUI) && canImport(UIKit)
    func testVisualSurfacesInstantiation() {
        let msg = AgentMessage(role: .assistant, rawText: "Test response", generationState: .completed)
        let row = AgentMessageRowView(message: msg)
        XCTAssertNotNil(row)

        let codeView = AgentCodeBlockView(code: "print(\"hello\")", language: "swift")
        XCTAssertNotNil(codeView)

        let mathView = AgentMathView(formula: "E=mc^2")
        XCTAssertNotNil(mathView)

        let sources = [AgentSource(title: "Apple", url: "https://apple.com")]
        let sourcesView = InlineSectionSourcesView(sources: sources)
        XCTAssertNotNil(sourcesView)

        let richResultView = AgentRichResultView(
            call: AgentToolCall(name: "weather_lookup", arguments: "{}"),
            result: AgentToolResult(callID: "1", toolName: "weather_lookup", outputSummary: "Sunny")
        )
        XCTAssertNotNil(richResultView)
    }
    #endif
}
#endif

