// Sources/AgentUIShowcaseSupport/MockRuntime/MockAgentRuntime.swift
import Foundation
import AgentUI

@MainActor
public final class MockAgentRuntime: AgentUIRuntimeAdapter {
    private var activeStreams: [AgentRequestID: Task<Void, Never>] = [:]

    public init() {}

    public func send(_ request: AgentSendRequest) -> AsyncThrowingStream<AgentUIEvent, Error> {
        let messageID = AgentMessageID()
        let requestID = request.requestID

        let events: [AgentUIEvent] = [
            .requestStarted(requestID: requestID),
            .assistantMessageStarted(messageID: messageID),

            // Step 1: Reasoning activity
            .activityStarted(
                messageID: messageID,
                item: AgentActivityItem(
                    id: AgentActivityID("act-1"),
                    kind: .reasoning,
                    status: .running,
                    title: "Analyzing prompt intent..."
                )
            ),
            .reasoningSummaryUpdated(messageID: messageID, itemID: AgentActivityID("act-1"), summary: "Parsed user input and identified needed search queries."),
            .activityCompleted(messageID: messageID, itemID: AgentActivityID("act-1")),

            // Step 2: Web Search activity if enabled
            .activityStarted(
                messageID: messageID,
                item: AgentActivityItem(
                    id: AgentActivityID("act-2"),
                    kind: .webSearch(query: request.prompt),
                    status: .running,
                    title: "Searching the web for latest sources",
                    sources: [
                        AgentSource(title: "Swift.org Documentation", url: "https://swift.org/documentation"),
                        AgentSource(title: "Apple Developer", url: "https://developer.apple.com")
                    ]
                )
            ),
            .activityCompleted(messageID: messageID, itemID: AgentActivityID("act-2")),

            // Step 3: Tool Execution (e.g. GitHub or Code)
            .toolStarted(
                messageID: messageID,
                execution: AgentToolExecution(
                    id: AgentToolCallID("tool-1"),
                    handlerID: "github.search",
                    inspection: ToolCallInspection(
                        callID: "call_gh_01",
                        service: "GitHub API",
                        toolName: "search_repositories",
                        arguments: "{\"query\": \"\(request.prompt)\", \"limit\": 5}",
                        resultSummary: "Found 5 matching repositories."
                    ),
                    status: .completed,
                    completedAt: Date()
                )
            ),

            // Step 4: Discovered citations
            .sourceDiscovered(messageID: messageID, source: AgentSource(title: "Swift Evolution", url: "https://github.com/swiftlang/swift-evolution")),
            .sourceDiscovered(messageID: messageID, source: AgentSource(title: "WWDC Sessions", url: "https://developer.apple.com/videos")),

            // Step 5: Streaming answer text (triggers one-time auto-collapse!)
            .assistantTextDelta(messageID: messageID, text: "Here is what I found regarding **"),
            .assistantTextDelta(messageID: messageID, text: request.prompt),
            .assistantTextDelta(messageID: messageID, text: "**:\n\n1. Swift Package Manager supports modular cross-platform architectures.\n2. Liquid Glass provides modern Apple visual hierarchy with iOS 18 fallbacks.\n\n"),
            .assistantTextDelta(messageID: messageID, text: "```swift\nimport AgentUI\n\nlet session = AgentUISession()\nAgentChatView(session: session)\n```\n\n"),
            .assistantTextDelta(messageID: messageID, text: "All tool disclosures maintain a single continuous surface without disjointed cards."),

            .requestCompleted(requestID: requestID)
        ]

        return MockStreamEngine.makeStream(events: events, interval: 0.04)
    }

    public func cancel(requestID: AgentRequestID) async {
        activeStreams[requestID]?.cancel()
        activeStreams[requestID] = nil
    }
}
