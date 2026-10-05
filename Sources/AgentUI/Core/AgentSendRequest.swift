// Sources/AgentUI/Core/AgentSendRequest.swift
import Foundation

public struct AgentSendRequest: Sendable, Equatable {
    public let requestID: AgentRequestID
    public let conversationID: AgentConversationID
    public let prompt: String
    public let attachments: [AgentAttachment]
    public let model: AgentModelDescriptor
    public let enableWebSearch: Bool
    public let metadata: [String: String]

    public init(
        requestID: AgentRequestID = AgentRequestID(),
        conversationID: AgentConversationID = AgentConversationID(),
        prompt: String,
        attachments: [AgentAttachment] = [],
        model: AgentModelDescriptor,
        enableWebSearch: Bool = true,
        metadata: [String: String] = [:]
    ) {
        self.requestID = requestID
        self.conversationID = conversationID
        self.prompt = prompt
        self.attachments = attachments
        self.model = model
        self.enableWebSearch = enableWebSearch
        self.metadata = metadata
    }
}
