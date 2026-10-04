import Foundation

enum AgentActivityKind: Equatable {
    case reasoning
    case webSearch
    case urlFetch
    case toolCall(service: String?)
    case status
}

enum AgentActivityStatus: Equatable {
    case pending
    case running
    case completed
    case failed
}

struct AgentActivityItem: Identifiable, Equatable {
    let id: String
    var kind: AgentActivityKind
    var status: AgentActivityStatus
    var title: String
    var summary: String?
    var startedAt: Date?
    var completedAt: Date?
    var sources: [WebSearchSource]
    var toolName: String?
    var toolArguments: String?
    var toolResultSummary: String?

    init(
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

struct AgentActivitySession: Equatable {
    let messageID: String
    var startedAt: Date
    var completedAt: Date?
    var items: [AgentActivityItem]
    var answerStarted: Bool
    var isExpanded: Bool

    var elapsed: TimeInterval {
        (completedAt ?? Date()).timeIntervalSince(startedAt)
    }
}
