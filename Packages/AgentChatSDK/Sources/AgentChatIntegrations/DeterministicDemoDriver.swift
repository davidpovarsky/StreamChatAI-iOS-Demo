#if canImport(AgentChatActivity)
import AgentChatActivity
#endif
#if canImport(AgentChatCore)
import AgentChatCore
#endif
#if canImport(AgentChatRendering)
import AgentChatRendering
#endif
#if canImport(AgentChatRichResults)
import AgentChatRichResults
#endif
import Foundation

@MainActor
public final class DeterministicDemoDriver: ObservableObject {
    public let session: AgentChatSession

    public init(session: AgentChatSession) {
        self.session = session
    }

    // Scenario A: Web Research
    public func startWebResearchScenario() {
        session.clearMessages()
        session.appendUserMessage(text: "What are the latest updates in Swift 6 concurrency?")

        let assistantID = session.startAssistantMessage()

        let task = Task {
            let activityDriver = AgentActivityDemoDriver()
            await activityDriver.runWebResearchScenario(messageID: assistantID) { [weak self] event in
                Task { @MainActor [weak self] in
                    self?.session.publishEvent(event)
                }
            }

            guard !Task.isCancelled else { return }

            let markdownResponse = """
            ## Swift 6 Concurrency Highlights

            Swift 6 achieves complete data-race safety by default, transforming concurrent programming into a compile-time checked model.

            ### Key Enhancements
            - **Complete Concurrency Checking**: Guarantees prevention of shared mutable state races.
            - **Region-based Isolation (SE-0414)**: Eliminates boilerplate `@Sendable` markers when values don't cross isolation regions.
            - **Sending Parameter and Result Values (SE-0430)**: Expressive transfers of non-Sendable values between actors.
            """

            for char in markdownResponse {
                guard !Task.isCancelled else { return }
                self.session.appendToken(String(char), toMessageID: assistantID)
                try? await Task.sleep(nanoseconds: 8_000_000)
            }

            let parser = AgentMarkdownParser()
            let parsedBlocks = parser.parse(markdown: markdownResponse)
            var finalBlocks = parsedBlocks
            finalBlocks.append(.sources(id: UUID().uuidString, items: [
                AgentSource(title: "Swift 6 Concurrency Migration Guide", url: "https://swift.org/migration/swift-6/concurrency"),
                AgentSource(title: "WWDC 2024: Migrate your app to Swift 6", url: "https://developer.apple.com/videos/play/wwdc2024/10169"),
                AgentSource(title: "Swift Evolution SE-0414", url: "https://github.com/swiftlang/swift-evolution/blob/main/proposals/0414-region-based-isolation.md")
            ]))

            self.session.updateBlocks(finalBlocks, forMessageID: assistantID)
            self.session.completeAssistantMessage(id: assistantID)
        }

        session.setTask(task)
    }

    // Scenario B: Tool Execution
    public func startToolExecutionScenario() {
        session.clearMessages()
        session.appendUserMessage(text: "Check the weather in Tel Aviv right now.")

        let assistantID = session.startAssistantMessage()

        let task = Task {
            let toolCallID = UUID().uuidString
            let toolCall = AgentToolCall(
                id: toolCallID,
                name: "weather_lookup",
                arguments: "{\"location\": \"Tel Aviv\", \"units\": \"metric\"}",
                service: "OpenMeteoService"
            )

            self.session.publishEvent(.sessionStarted(messageID: assistantID))
            try? await Task.sleep(nanoseconds: 200_000_000)

            self.session.publishEvent(.reasoningStarted(messageID: assistantID, summary: "Extracting location parameter and calling weather API"))
            try? await Task.sleep(nanoseconds: 300_000_000)

            self.session.publishEvent(.toolStarted(
                messageID: assistantID,
                toolID: toolCallID,
                toolName: "weather_lookup",
                service: "OpenMeteoService",
                arguments: toolCall.arguments
            ))

            self.session.appendBlock(.tool(id: toolCallID, call: toolCall, result: nil), toMessageID: assistantID)

            try? await Task.sleep(nanoseconds: 600_000_000)

            let toolResult = AgentToolResult(
                callID: toolCallID,
                toolName: "weather_lookup",
                isSuccess: true,
                outputSummary: "24°C, Clear Skies, Humidity 45%, Wind 12 km/h NW",
                rawOutput: "{\"temp\": 24, \"condition\": \"clear\", \"humidity\": 45, \"wind_speed\": 12}"
            )

            self.session.publishEvent(.toolCompleted(
                messageID: assistantID,
                toolID: toolCallID,
                resultSummary: toolResult.outputSummary
            ))

            self.session.updateBlocks([
                .tool(id: toolCallID, call: toolCall, result: toolResult),
                .markdown(id: UUID().uuidString, text: "The weather in Tel Aviv is currently **24°C and clear** with pleasant north-westerly breezes.")
            ], forMessageID: assistantID)

            self.session.publishEvent(.answerStarted(messageID: assistantID))
            self.session.publishEvent(.sessionCompleted(messageID: assistantID))
            self.session.completeAssistantMessage(id: assistantID)
        }

        session.setTask(task)
    }

    // Scenario C: Rich Content
    public func startRichContentScenario() {
        session.clearMessages()
        session.appendUserMessage(text: "Show me a rich overview including code, math, images, SVG, and structured data.")

        let assistantID = session.startAssistantMessage()

        let richBlocks: [AgentMessageBlock] = [
            .markdown(id: UUID().uuidString, text: "# Multimodal Agent Output 🚀\n\nHere is a comprehensive demonstration of the **ChatGPT-style rendering stack**:"),
            .code(id: UUID().uuidString, code: """
            func streamTokens(from response: AsyncThrowingStream<String, Error>) async throws {
                for try await token in response {
                    await session.appendToken(token, toMessageID: messageID)
                }
            }
            """, language: "swift"),
            .math(id: UUID().uuidString, formula: "E = mc^2 \\quad \\Longleftrightarrow \\quad \\int_{-\\infty}^{\\infty} e^{-x^2} dx = \\sqrt{\\pi}", displayMode: true),
            .image(id: UUID().uuidString, content: AgentImageContent(
                url: "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&auto=format&fit=crop&q=80",
                caption: "Generative fluid abstract rendering (Kingfisher cached)",
                altText: "Abstract fluid gradient"
            )),
            .svg(id: UUID().uuidString, content: AgentSVGContent(
                rawSVG: """
                <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                  <circle cx="50" cy="50" r="40" stroke="#007AFF" stroke-width="4" fill="#34C759" fill-opacity="0.2" />
                  <polygon points="50,25 60,65 30,40 70,40 40,65" fill="#FF9500" />
                </svg>
                """,
                title: "Dynamic Vector Graphic (SVGView)",
                width: 140,
                height: 140
            )),
            .tool(
                id: UUID().uuidString,
                call: AgentToolCall(name: "stock_quote", arguments: "{\"ticker\": \"AAPL\"}"),
                result: AgentToolResult(
                    callID: UUID().uuidString,
                    toolName: "stock_quote",
                    outputSummary: "AAPL: $228.45 (+1.84%)"
                )
            ),
            .sources(id: UUID().uuidString, items: [
                AgentSource(title: "Apple Inc. (AAPL) Valuation", url: "https://finance.yahoo.com/quote/AAPL"),
                AgentSource(title: "Securities and Exchange Commission", url: "https://www.sec.gov")
            ])
        ]

        session.updateBlocks(richBlocks, forMessageID: assistantID)
        session.completeAssistantMessage(id: assistantID)
    }

    // Scenario D: Voice Mode
    public func startVoiceScenario() {
        session.appendUserMessage(text: "Let's switch to voice mode.")
        let assistantID = session.startAssistantMessage()
        session.updateBlocks([
            .markdown(id: UUID().uuidString, text: "Voice session initialized. Tap the microphone icon below or enter the voice overlay to start speaking.")
        ], forMessageID: assistantID)
        session.completeAssistantMessage(id: assistantID)
    }

    // Scenario E: Failure & Retry
    public func startFailureRetryScenario() {
        session.clearMessages()
        session.appendUserMessage(text: "Calculate the orbital trajectory for Mars transfer.")

        let assistantID = session.startAssistantMessage()

        let task = Task {
            session.publishEvent(.sessionStarted(messageID: assistantID))
            session.publishEvent(.reasoningStarted(messageID: assistantID, summary: "Connecting to ephemeris trajectory server"))
            try? await Task.sleep(nanoseconds: 500_000_000)

            session.publishEvent(.toolFailed(
                messageID: assistantID,
                toolID: UUID().uuidString,
                errorSummary: "ConnectionTimeout: The trajectory API did not respond within 5000ms."
            ))

            session.failAssistantMessage(id: assistantID, error: "Network timeout: Unable to reach the orbital computation service. Tap Retry to reconnect.")
        }

        session.setTask(task)
    }
}
