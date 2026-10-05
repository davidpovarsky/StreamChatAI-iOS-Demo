// Sources/AgentUI/Core/AgentMessage.swift
import Foundation

public enum AgentMessageRole: String, Sendable, Equatable, Codable {
    case user
    case assistant
    case system
}

public struct AgentMessage: Identifiable, Sendable, Equatable {
    public let id: AgentMessageID
    public let role: AgentMessageRole
    public var blocks: [AgentContentBlock]
    public let createdAt: Date
    public var sectionSources: [String: [AgentSource]]
    public var allSources: [AgentSource]
    public var isStreaming: Bool
    public var error: AgentUIError?

    public init(
        id: AgentMessageID = AgentMessageID(),
        role: AgentMessageRole,
        blocks: [AgentContentBlock] = [],
        createdAt: Date = Date(),
        sectionSources: [String: [AgentSource]] = [:],
        allSources: [AgentSource] = [],
        isStreaming: Bool = false,
        error: AgentUIError? = nil
    ) {
        self.id = id
        self.role = role
        self.blocks = blocks
        self.createdAt = createdAt
        self.sectionSources = sectionSources
        self.allSources = allSources
        self.isStreaming = isStreaming
        self.error = error
    }

    public var textContent: String {
        blocks.compactMap { block in
            if case .markdown(_, let content) = block {
                return content
            }
            return nil
        }.joined(separator: "\n\n")
    }

    public mutating func appendOrUpdateMarkdown(delta: String) {
        if let lastIndex = blocks.indices.last, case .markdown(let id, let existing) = blocks[lastIndex] {
            blocks[lastIndex] = .markdown(id: id, content: existing + delta)
        } else {
            blocks.append(.markdown(id: UUID().uuidString, content: delta))
        }
    }
}
