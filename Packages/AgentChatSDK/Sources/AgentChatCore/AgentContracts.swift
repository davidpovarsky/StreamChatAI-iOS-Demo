import Foundation

// MARK: - Agent Chat Stream Event

public enum AgentChatStreamEvent: Sendable, Equatable {
    // Text and thinking tokens
    case token(String)
    case thinkingToken(String)
    case contentDelta(messageId: MessageID, text: String)

    // Run lifecycle
    case runStarted(runId: RunID, messageId: MessageID)
    case runFinished(runId: RunID, status: RunStatus)

    // Grouping & hierarchical operations
    case groupStarted(runId: RunID, groupId: ActivityGroupID, stage: ActivityStage, title: String?)
    case toolRequested(runId: RunID, groupId: ActivityGroupID?, operationId: OperationID, tool: String, title: String?, arguments: String?)
    case toolProgress(runId: RunID, operationId: OperationID, progress: Double, message: String?)
    case toolCompleted(runId: RunID, operationId: OperationID, resultSummary: String?, payload: String?, sources: [WebSearchSource])
    case toolFailed(runId: RunID, operationId: OperationID, error: String)

    // Approvals
    case approvalRequested(approval: ApprovalRequest)
    case approvalResolved(requestId: String, status: ApprovalStatus)

    // Rich Results
    case resultProduced(result: AgentResult)
    case richPart(MessageContentPart)

    // Legacy web search compatibility
    case webSearch(WebSearchState)

    // Status / Error / Termination
    case error(messageId: MessageID, error: AgentChatError)
    case finished
}

// MARK: - Agent Chat Runtime Provider

public protocol AgentChatRuntimeProvider: Sendable {
    func sendMessage(
        chatId: String,
        content: String,
        model: AgentModel,
        attachments: [Attachment]
    ) async throws -> AsyncStream<AgentChatStreamEvent>

    func cancel(chatId: String)
}

// Extension for backwards compatibility with legacy ModelType
public extension AgentChatRuntimeProvider {
    func sendMessage(
        chatId: String,
        content: String,
        model: ModelType,
        attachments: [Attachment]
    ) async throws -> AsyncStream<AgentChatStreamEvent> {
        try await sendMessage(chatId: chatId, content: content, model: model, attachments: attachments)
    }
}
