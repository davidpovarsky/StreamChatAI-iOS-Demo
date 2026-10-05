// Sources/AgentUI/Core/AgentUIEvent.swift
import Foundation

public enum AgentUIEvent: Sendable, Equatable {
    case requestStarted(requestID: AgentRequestID)
    case assistantMessageStarted(messageID: AgentMessageID)
    case assistantTextDelta(messageID: AgentMessageID, text: String)
    case assistantTextCompleted(messageID: AgentMessageID, fullText: String)
    case reasoningSummaryStarted(messageID: AgentMessageID, itemID: AgentActivityID, title: String)
    case reasoningSummaryUpdated(messageID: AgentMessageID, itemID: AgentActivityID, summary: String)
    case reasoningSummaryCompleted(messageID: AgentMessageID, itemID: AgentActivityID)
    case activityStarted(messageID: AgentMessageID, item: AgentActivityItem)
    case activityUpdated(messageID: AgentMessageID, item: AgentActivityItem)
    case activityCompleted(messageID: AgentMessageID, itemID: AgentActivityID)
    case toolStarted(messageID: AgentMessageID, execution: AgentToolExecution)
    case toolProgress(messageID: AgentMessageID, toolCallID: AgentToolCallID, progress: Double, message: String?)
    case toolPresentationUpdated(messageID: AgentMessageID, execution: AgentToolExecution)
    case toolCompleted(messageID: AgentMessageID, toolCallID: AgentToolCallID, resultSummary: String?)
    case toolFailed(messageID: AgentMessageID, toolCallID: AgentToolCallID, errorMessage: String)
    case toolCancelled(messageID: AgentMessageID, toolCallID: AgentToolCallID)
    case sourceDiscovered(messageID: AgentMessageID, source: AgentSource)
    case sectionSourcesUpdated(messageID: AgentMessageID, sectionID: String, sources: [AgentSource])
    case contentBlockAdded(messageID: AgentMessageID, block: AgentContentBlock)
    case contentBlockUpdated(messageID: AgentMessageID, block: AgentContentBlock)
    case embeddedResultAdded(messageID: AgentMessageID, descriptor: AgentEmbeddedPresentationDescriptor)
    case requestCompleted(requestID: AgentRequestID)
    case requestFailed(requestID: AgentRequestID, error: AgentUIError)
    case requestCancelled(requestID: AgentRequestID)
}
