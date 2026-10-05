// Sources/AgentUI/Session/AgentConversation.swift
import Foundation

public struct AgentConversation: Identifiable, Sendable, Equatable {
    public let id: AgentConversationID
    public var title: String
    public let createdAt: Date
    public var updatedAt: Date
    public var messageIDs: [AgentMessageID]

    public init(
        id: AgentConversationID = AgentConversationID(),
        title: String = "New Conversation",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        messageIDs: [AgentMessageID] = []
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.messageIDs = messageIDs
    }
}
