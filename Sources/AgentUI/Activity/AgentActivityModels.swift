// Sources/AgentUI/Activity/AgentActivityModels.swift
import Foundation

public enum AgentActivityKind: Sendable, Equatable, Hashable {
    case reasoning
    case webSearch(query: String)
    case sourceSearch(domain: String)
    case fileOperation(path: String)
    case codeExecution(language: String)
    case mapSearch(location: String)
    case calendar(event: String)
    case genericTool(toolName: String)
    case status(message: String)
    case error(message: String)

    public var iconSystemName: String {
        switch self {
        case .reasoning: return "sparkles"
        case .webSearch: return "globe"
        case .sourceSearch: return "magnifyingglass"
        case .fileOperation: return "doc.text"
        case .codeExecution: return "terminal"
        case .mapSearch: return "map"
        case .calendar: return "calendar"
        case .genericTool: return "wrench.and.screwdriver"
        case .status: return "clock"
        case .error: return "exclamationmark.triangle"
        }
    }
}

public enum AgentActivityStatus: Sendable, Equatable, Hashable {
    case pending
    case running
    case completed
    case failed
}

public struct AgentActivityItem: Identifiable, Sendable, Equatable, Hashable {
    public let id: AgentActivityID
    public var kind: AgentActivityKind
    public var status: AgentActivityStatus
    public var title: String
    public var summary: String?
    public var startedAt: Date
    public var completedAt: Date?
    public var sources: [AgentSource]
    public var toolName: String?
    public var toolArguments: String?
    public var toolResultSummary: String?
    public var isExpanded: Bool

    public init(
        id: AgentActivityID = AgentActivityID(),
        kind: AgentActivityKind,
        status: AgentActivityStatus = .running,
        title: String,
        summary: String? = nil,
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        sources: [AgentSource] = [],
        toolName: String? = nil,
        toolArguments: String? = nil,
        toolResultSummary: String? = nil,
        isExpanded: Bool = false
    ) {
        self.id = id
        self.kind = kind
        self.status = status
        self.title = title
        self.summary = summary
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.sources = sources
        self.toolName = toolName
        self.toolArguments = toolArguments
        self.toolResultSummary = toolResultSummary
        self.isExpanded = isExpanded
    }
}

public struct AgentActivitySession: Identifiable, Sendable, Equatable {
    public let messageID: AgentMessageID
    public var startedAt: Date
    public var completedAt: Date?
    public var items: [AgentActivityItem]
    public var answerStarted: Bool
    public var isExpanded: Bool
    public var hasAutoCollapsed: Bool

    public var id: String { messageID.rawValue }

    public init(
        messageID: AgentMessageID,
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        items: [AgentActivityItem] = [],
        answerStarted: Bool = false,
        isExpanded: Bool = true,
        hasAutoCollapsed: Bool = false
    ) {
        self.messageID = messageID
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.items = items
        self.answerStarted = answerStarted
        self.isExpanded = isExpanded
        self.hasAutoCollapsed = hasAutoCollapsed
    }

    public var elapsedDuration: TimeInterval {
        (completedAt ?? Date()).timeIntervalSince(startedAt)
    }
}
