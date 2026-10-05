//
//  AgentActivityModels.swift
//  AgentUI
//

import Foundation

public enum AgentActivityKind: Equatable, Sendable {
    case reasoning
    case webSearch
    case urlFetch
    case toolCall(service: String?)
    case status
}

public enum AgentActivityStatus: Equatable, Sendable {
    case pending
    case running
    case completed
    case failed
}

public struct AgentActivityItem: Identifiable, Equatable, Sendable {
    public let id: String
    public var kind: AgentActivityKind
    public var status: AgentActivityStatus
    public var title: String
    public var summary: String?
    public var startedAt: Date?
    public var completedAt: Date?
    public var sources: [WebSearchSource]
    public var toolName: String?
    public var toolArguments: String?
    public var toolResultSummary: String?

    public init(
        id: String = UUID().uuidString,
        kind: AgentActivityKind,
        status: AgentActivityStatus = .running,
        title: String,
        summary: String? = nil,
        sources: [WebSearchSource] = [],
        toolName: String? = nil,
        toolArguments: String? = nil,
        toolResultSummary: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.status = status
        self.title = title
        self.summary = summary
        self.startedAt = Date()
        self.sources = sources
        self.toolName = toolName
        self.toolArguments = toolArguments
        self.toolResultSummary = toolResultSummary
    }
}

public struct AgentActivitySession: Equatable, Sendable {
    public let messageID: String
    public var startedAt: Date
    public var completedAt: Date?
    public var items: [AgentActivityItem]
    public var answerStarted: Bool
    public var isExpanded: Bool

    public init(
        messageID: String,
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        items: [AgentActivityItem] = [],
        answerStarted: Bool = false,
        isExpanded: Bool = true
    ) {
        self.messageID = messageID
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.items = items
        self.answerStarted = answerStarted
        self.isExpanded = isExpanded
    }

    public var elapsed: TimeInterval {
        (completedAt ?? Date()).timeIntervalSince(startedAt)
    }
}
