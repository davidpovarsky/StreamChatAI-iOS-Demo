import Foundation

// MARK: - Agent Chat Stream Event

public enum AgentChatStreamEvent: Sendable, Equatable {
    case token(String)
    case thinkingToken(String)
    case webSearch(WebSearchState)
    case toolRequested(name: String, callId: String, arguments: String)
    case toolProgress(name: String, callId: String, progress: Double)
    case toolCompleted(name: String, callId: String, resultSummary: String, payload: String?)
    case toolFailed(name: String, callId: String, error: String)
    case richPart(MessageContentPart)
    case finished
}

// MARK: - Agent Chat Runtime Provider

public protocol AgentChatRuntimeProvider: Sendable {
    func sendMessage(
        chatId: String,
        content: String,
        model: ModelType,
        attachments: [Attachment]
    ) async throws -> AsyncStream<AgentChatStreamEvent>

    func cancel(chatId: String)
}
