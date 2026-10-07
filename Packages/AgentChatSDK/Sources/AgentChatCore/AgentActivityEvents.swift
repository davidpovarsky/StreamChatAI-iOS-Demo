import Foundation

public enum AgentActivityKind: Equatable, Sendable, Codable {
    case reasoning
    case webSearch
    case urlFetch
    case toolCall(service: String?)
    case status
}

public enum AgentActivityStatus: Equatable, Sendable, Codable {
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
    public var sources: [AgentSource]
    public var toolName: String?
    public var toolArguments: String?
    public var toolResultSummary: String?

    public init(
        id: String = UUID().uuidString,
        kind: AgentActivityKind,
        status: AgentActivityStatus = .running,
        title: String,
        summary: String? = nil,
        sources: [AgentSource] = [],
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

    public var elapsed: TimeInterval {
        guard let started = startedAt else { return 0 }
        return (completedAt ?? Date()).timeIntervalSince(started)
    }
}

public struct AgentActivitySession: Equatable, Sendable {
    public let messageID: String
    public var startedAt: Date
    public var completedAt: Date?
    public var items: [AgentActivityItem]
    public var answerStarted: Bool
    public var isExpanded: Bool

    public var elapsed: TimeInterval {
        (completedAt ?? Date()).timeIntervalSince(startedAt)
    }

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
}

public enum AgentActivityEvent: Sendable, Equatable {
    case sessionStarted(messageID: String)
    case reasoningStarted(messageID: String, summary: String)
    case reasoningUpdated(messageID: String, summary: String)
    case webSearchStarted(messageID: String, query: String?)
    case sourceDiscovered(messageID: String, source: AgentSource)
    case webSearchCompleted(messageID: String)
    case toolStarted(messageID: String, toolID: String, toolName: String, service: String?, arguments: String?)
    case toolProgress(messageID: String, toolID: String, summary: String)
    case toolCompleted(messageID: String, toolID: String, resultSummary: String?)
    case toolFailed(messageID: String, toolID: String, errorSummary: String?)
    case statusAdded(messageID: String, title: String, summary: String?)
    case answerStarted(messageID: String)
    case sessionCompleted(messageID: String)
}
