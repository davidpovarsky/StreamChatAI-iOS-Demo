#if canImport(AgentChatCore)
import AgentChatCore
#endif
import Foundation

public final class AgentActivityDemoDriver: Sendable {
    public init() {}

    public func runWebResearchScenario(
        messageID: String,
        query: String = "Latest developments in Swift concurrency",
        emit: @escaping @Sendable (AgentActivityEvent) -> Void
    ) async {
        emit(.sessionStarted(messageID: messageID))
        try? await Task.sleep(nanoseconds: 200_000_000)

        emit(.reasoningStarted(messageID: messageID, summary: "Analyzing query"))
        try? await Task.sleep(nanoseconds: 300_000_000)

        emit(.reasoningUpdated(messageID: messageID, summary: "Deciding to search web for Swift 6 features"))
        try? await Task.sleep(nanoseconds: 250_000_000)

        emit(.webSearchStarted(messageID: messageID, query: query))
        try? await Task.sleep(nanoseconds: 300_000_000)

        emit(.sourceDiscovered(
            messageID: messageID,
            source: AgentSource(
                title: "Swift 6 Language Guide",
                url: "https://swift.org/documentation/concurrency",
                snippet: "Data race safety and isolation boundaries in Swift 6."
            )
        ))
        try? await Task.sleep(nanoseconds: 200_000_000)

        emit(.sourceDiscovered(
            messageID: messageID,
            source: AgentSource(
                title: "WWDC 2024: Migrate to Swift 6",
                url: "https://developer.apple.com/videos/play/wwdc2024/10169",
                snippet: "Step-by-step techniques for incremental migration."
            )
        ))
        try? await Task.sleep(nanoseconds: 250_000_000)

        emit(.sourceDiscovered(
            messageID: messageID,
            source: AgentSource(
                title: "Swift Evolution Proposals Index",
                url: "https://github.com/swiftlang/swift-evolution",
                snippet: "SE-0414: Region-based Isolation, SE-0430: sending parameter and result values."
            )
        ))
        try? await Task.sleep(nanoseconds: 250_000_000)

        emit(.webSearchCompleted(messageID: messageID))
        emit(.answerStarted(messageID: messageID))
    }

    public func runToolExecutionScenario(
        messageID: String,
        toolName: String = "weather_lookup",
        location: String = "Tel Aviv, IL",
        emit: @escaping @Sendable (AgentActivityEvent) -> Void
    ) async {
        emit(.sessionStarted(messageID: messageID))
        try? await Task.sleep(nanoseconds: 200_000_000)

        emit(.reasoningStarted(messageID: messageID, summary: "Determining required tool for current temperature in \(location)"))
        try? await Task.sleep(nanoseconds: 300_000_000)

        let toolID = UUID().uuidString
        emit(.toolStarted(
            messageID: messageID,
            toolID: toolID,
            toolName: toolName,
            service: "WeatherService",
            arguments: "{\"location\": \"\(location)\", \"unit\": \"celsius\"}"
        ))
        try? await Task.sleep(nanoseconds: 400_000_000)

        emit(.toolProgress(messageID: messageID, toolID: toolID, summary: "Fetching meteorological data from satellite API"))
        try? await Task.sleep(nanoseconds: 350_000_000)

        emit(.toolCompleted(
            messageID: messageID,
            toolID: toolID,
            resultSummary: "24°C, Sunny, Humidity 45%, Wind 12 km/h"
        ))
        try? await Task.sleep(nanoseconds: 200_000_000)

        emit(.answerStarted(messageID: messageID))
        emit(.sessionCompleted(messageID: messageID))
    }
}
