import Foundation

// MARK: - Stable ID Types

public typealias ConversationID = String
public typealias MessageID = String
public typealias RunID = String
public typealias ActivityGroupID = String
public typealias OperationID = String
public typealias ToolCallID = String
public typealias ResultID = String
public typealias ActionID = String
public typealias SourceID = String

// MARK: - Agent Model Representation

public struct AgentModel: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: String
    public var name: String
    public var descriptionText: String?
    public var provider: String?
    public var iconSystemName: String

    public init(
        id: String,
        name: String,
        descriptionText: String? = nil,
        provider: String? = nil,
        iconSystemName: String = "cpu"
    ) {
        self.id = id
        self.name = name
        self.descriptionText = descriptionText
        self.provider = provider
        self.iconSystemName = iconSystemName
    }

    public static let gpt4o = AgentModel(
        id: "gpt-4o",
        name: "GPT-4o",
        descriptionText: "High-intelligence multimodal flagship model",
        provider: "OpenAI",
        iconSystemName: "sparkles"
    )

    public static let gpt4oMini = AgentModel(
        id: "gpt-4o-mini",
        name: "GPT-4o mini",
        descriptionText: "Fast, lightweight multimodal model",
        provider: "OpenAI",
        iconSystemName: "bolt.fill"
    )

    public static let o1 = AgentModel(
        id: "o1",
        name: "o1",
        descriptionText: "Reasoning model for complex multi-step problems",
        provider: "OpenAI",
        iconSystemName: "brain"
    )

    public static let o3Mini = AgentModel(
        id: "o3-mini",
        name: "o3-mini",
        descriptionText: "Fast reasoning model with adjustable effort",
        provider: "OpenAI",
        iconSystemName: "brain.head.profile"
    )

    public static let claude35Sonnet = AgentModel(
        id: "claude-3-5-sonnet",
        name: "Claude 3.5 Sonnet",
        descriptionText: "Advanced reasoning and coding excellence",
        provider: "Anthropic",
        iconSystemName: "wand.and.stars"
    )

    public static let defaultModels: [AgentModel] = [
        .gpt4o, .gpt4oMini, .o1, .o3Mini, .claude35Sonnet
    ]
}

public typealias ModelType = AgentModel

// MARK: - Typed AnySendable for Forms & Payloads

public enum AnySendable: Codable, Equatable, Hashable, Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([AnySendable])
    case dictionary([String: AnySendable])
    case null

    public init(_ value: Any) {
        if let str = value as? String { self = .string(str) }
        else if let num = value as? Int { self = .int(num) }
        else if let dbl = value as? Double { self = .double(dbl) }
        else if let b = value as? Bool { self = .bool(b) }
        else if let arr = value as? [Any] { self = .array(arr.map { AnySendable($0) }) }
        else if let dict = value as? [String: Any] { self = .dictionary(dict.mapValues { AnySendable($0) }) }
        else { self = .string(String(describing: value)) }
    }

    public var stringValue: String? {
        if case .string(let s) = self { return s }
        return nil
    }

    public var doubleValue: Double? {
        switch self {
        case .double(let d): return d
        case .int(let i): return Double(i)
        default: return nil
        }
    }

    public var boolValue: Bool? {
        if case .bool(let b) = self { return b }
        return nil
    }
}

// MARK: - Error Model

public struct AgentChatError: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: String
    public let code: String
    public let message: String
    public let isRetryable: Bool
    public let underlyingDetails: String?

    public init(
        id: String = UUID().uuidString.lowercased(),
        code: String,
        message: String,
        isRetryable: Bool = true,
        underlyingDetails: String? = nil
    ) {
        self.id = id
        self.code = code
        self.message = message
        self.isRetryable = isRetryable
        self.underlyingDetails = underlyingDetails
    }
}

// MARK: - Action Context & User Action

public struct AgentResultActionContext: Codable, Equatable, Hashable, Sendable {
    public let conversationId: ConversationID
    public let messageId: MessageID
    public let runId: RunID?
    public let resultId: ResultID?

    public init(
        conversationId: ConversationID,
        messageId: MessageID,
        runId: RunID? = nil,
        resultId: ResultID? = nil
    ) {
        self.conversationId = conversationId
        self.messageId = messageId
        self.runId = runId
        self.resultId = resultId
    }
}

public enum UserActionKind: Codable, Equatable, Hashable, Sendable {
    case tap(controlId: String)
    case select(option: String)
    case submit(values: [String: AnySendable])
    case approve(requestId: String)
    case deny(requestId: String)
    case retry(operationId: String?)
    case cancel(runId: String?)
    case openURL(urlString: String)
    case share(content: String)
    case copy(text: String)
}

public struct AgentChatUserAction: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: ActionID
    public let kind: UserActionKind
    public let context: AgentResultActionContext
    public let timestamp: Date

    public init(
        id: ActionID = UUID().uuidString.lowercased(),
        kind: UserActionKind,
        context: AgentResultActionContext,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.kind = kind
        self.context = context
        self.timestamp = timestamp
    }
}

// MARK: - Approval Request

public enum ApprovalStatus: String, Codable, Equatable, Hashable, Sendable {
    case requested
    case approved
    case denied
    case cancelled
    case expired
    case executing
    case completed
    case failed
}

public struct ApprovalRequest: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: String
    public let runId: RunID
    public var title: String
    public var descriptionText: String
    public var provider: String
    public var status: ApprovalStatus
    public var requestedAt: Date
    public var resolvedAt: Date?

    public init(
        id: String = UUID().uuidString.lowercased(),
        runId: RunID,
        title: String,
        descriptionText: String,
        provider: String,
        status: ApprovalStatus = .requested,
        requestedAt: Date = Date(),
        resolvedAt: Date? = nil
    ) {
        self.id = id
        self.runId = runId
        self.title = title
        self.descriptionText = descriptionText
        self.provider = provider
        self.status = status
        self.requestedAt = requestedAt
        self.resolvedAt = resolvedAt
    }
}

// MARK: - Activity Group & Operation Models

public enum ActivityStage: String, Codable, Equatable, Hashable, Sendable, CaseIterable {
    case planning
    case research
    case verification
    case coding
    case multimodal
    case synthesis
    case custom

    public var defaultTitle: String {
        switch self {
        case .planning: return "Planning workflow"
        case .research: return "Researching information"
        case .verification: return "Verifying results"
        case .coding: return "Writing & analyzing code"
        case .multimodal: return "Processing media"
        case .synthesis: return "Synthesizing answer"
        case .custom: return "Operations"
        }
    }

    public var iconSystemName: String {
        switch self {
        case .planning: return "list.bullet.clipboard"
        case .research: return "globe"
        case .verification: return "checkmark.shield"
        case .coding: return "chevron.left.forwardslash.chevron.right"
        case .multimodal: return "photo.stack"
        case .synthesis: return "sparkles"
        case .custom: return "gearshape"
        }
    }
}

public enum OperationStatus: String, Codable, Equatable, Hashable, Sendable {
    case pending
    case running
    case completed
    case failed
    case cancelled
}

public struct ActivityOperation: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: OperationID
    public let callId: String
    public var toolName: String
    public var title: String
    public var status: OperationStatus
    public var progress: Double?
    public var startedAt: Date
    public var completedAt: Date?
    public var duration: TimeInterval?
    public var sources: [WebSearchSource]
    public var argumentsText: String?
    public var resultSummary: String?
    public var rawPayload: String?
    public var attempt: Int
    public var isExpanded: Bool // Defaults to false

    public init(
        id: OperationID = UUID().uuidString.lowercased(),
        callId: String = UUID().uuidString.lowercased(),
        toolName: String,
        title: String,
        status: OperationStatus = .running,
        progress: Double? = nil,
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        duration: TimeInterval? = nil,
        sources: [WebSearchSource] = [],
        argumentsText: String? = nil,
        resultSummary: String? = nil,
        rawPayload: String? = nil,
        attempt: Int = 1,
        isExpanded: Bool = false
    ) {
        self.id = id
        self.callId = callId
        self.toolName = toolName
        self.title = title
        self.status = status
        self.progress = progress
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.duration = duration
        self.sources = sources
        self.argumentsText = argumentsText
        self.resultSummary = resultSummary
        self.rawPayload = rawPayload
        self.attempt = attempt
        self.isExpanded = isExpanded
    }
}

public struct ActivityGroup: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: ActivityGroupID
    public var stage: ActivityStage
    public var title: String
    public var summary: String?
    public var operations: [ActivityOperation]
    public var isExpanded: Bool // Defaults to false

    public init(
        id: ActivityGroupID = UUID().uuidString.lowercased(),
        stage: ActivityStage = .custom,
        title: String? = nil,
        summary: String? = nil,
        operations: [ActivityOperation] = [],
        isExpanded: Bool = false
    ) {
        self.id = id
        self.stage = stage
        self.title = title ?? stage.defaultTitle
        self.summary = summary
        self.operations = operations
        self.isExpanded = isExpanded
    }

    public var isComplete: Bool {
        operations.allSatisfy { $0.status == .completed || $0.status == .cancelled }
    }

    public var isRunning: Bool {
        operations.contains { $0.status == .running }
    }
}

public enum RunStatus: String, Codable, Equatable, Hashable, Sendable {
    case running
    case completed
    case failed
    case cancelled
}

public struct AgentRun: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: RunID
    public let messageId: MessageID
    public var status: RunStatus
    public var startedAt: Date
    public var completedAt: Date?
    public var groups: [ActivityGroup]
    public var approvals: [ApprovalRequest]
    public var isExpanded: Bool // DEFAULTS TO FALSE per non-negotiable requirement

    public var elapsedSeconds: TimeInterval {
        (completedAt ?? Date()).timeIntervalSince(startedAt)
    }

    public init(
        id: RunID = UUID().uuidString.lowercased(),
        messageId: MessageID,
        status: RunStatus = .running,
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        groups: [ActivityGroup] = [],
        approvals: [ApprovalRequest] = [],
        isExpanded: Bool = false
    ) {
        self.id = id
        self.messageId = messageId
        self.status = status
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.groups = groups
        self.approvals = approvals
        self.isExpanded = isExpanded
    }

    public var allSources: [WebSearchSource] {
        var set = [WebSearchSource]()
        for group in groups {
            for op in group.operations {
                for src in op.sources {
                    if !set.contains(where: { $0.url == src.url }) {
                        set.append(src)
                    }
                }
            }
        }
        return set
    }
}

// MARK: - Rich Result Kind & Typed Payloads

public enum AgentResultKind: String, Codable, Equatable, Hashable, Sendable {
    case markdown
    case code
    case math
    case image
    case svg
    case video
    case audio
    case file
    case citation
    case chart
    case map
    case calendar
    case reminder
    case health
    case knowledge
    case form
    case canvasDocument
    case canvasCode
    case miniApp
    case artifact
    case error
    case approval
    case richLink
    case webContentFallback
    case toolFallback
}

public struct AgentResultPayload: Codable, Equatable, Hashable, Sendable {
    public var title: String?
    public var subtitle: String?
    public var contentText: String?
    public var urlString: String?
    public var language: String?
    public var metadata: [String: AnySendable]
    public var sources: [WebSearchSource]

    public init(
        title: String? = nil,
        subtitle: String? = nil,
        contentText: String? = nil,
        urlString: String? = nil,
        language: String? = nil,
        metadata: [String: AnySendable] = [:],
        sources: [WebSearchSource] = []
    ) {
        self.title = title
        self.subtitle = subtitle
        self.contentText = contentText
        self.urlString = urlString
        self.language = language
        self.metadata = metadata
        self.sources = sources
    }
}

public struct AgentResult: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: ResultID
    public let runId: RunID?
    public let messageId: MessageID
    public var kind: AgentResultKind
    public var schemaVersion: Int
    public var title: String?
    public var payload: AgentResultPayload
    public var createdAt: Date

    public init(
        id: ResultID = UUID().uuidString.lowercased(),
        runId: RunID? = nil,
        messageId: MessageID,
        kind: AgentResultKind,
        schemaVersion: Int = 1,
        title: String? = nil,
        payload: AgentResultPayload,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.runId = runId
        self.messageId = messageId
        self.kind = kind
        self.schemaVersion = schemaVersion
        self.title = title
        self.payload = payload
        self.createdAt = createdAt
    }
}

// MARK: - Chat Message & Segments

public enum ChatMessageSegmentKind: Codable, Equatable, Hashable, Sendable {
    case markdown(String)
    case result(AgentResult)
}

public struct ChatMessageSegment: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: String
    public var kind: ChatMessageSegmentKind

    public init(id: String = UUID().uuidString.lowercased(), kind: ChatMessageSegmentKind) {
        self.id = id
        self.kind = kind
    }
}

public struct ChatMessage: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: MessageID
    public let conversationId: ConversationID
    public let role: MessageRole
    public var segments: [ChatMessageSegment]
    public var attachments: [Attachment]
    public var runIds: [RunID]
    public var isStreaming: Bool
    public var error: AgentChatError?
    public var createdAt: Date

    public init(
        id: MessageID = UUID().uuidString.lowercased(),
        conversationId: ConversationID,
        role: MessageRole,
        segments: [ChatMessageSegment] = [],
        attachments: [Attachment] = [],
        runIds: [RunID] = [],
        isStreaming: Bool = false,
        error: AgentChatError? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.conversationId = conversationId
        self.role = role
        self.segments = segments
        self.attachments = attachments
        self.runIds = runIds
        self.isStreaming = isStreaming
        self.error = error
        self.createdAt = createdAt
    }

    public var plainTextContent: String {
        segments.compactMap { segment in
            if case .markdown(let text) = segment.kind {
                return text
            }
            return nil
        }.joined()
    }
}

// MARK: - Conversation

public struct Conversation: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: ConversationID
    public var title: String
    public var messages: [ChatMessage]
    public var runs: [RunID: AgentRun]
    public var createdAt: Date
    public var updatedAt: Date
    public var selectedModel: AgentModel
    public var draft: String
    public var isPinned: Bool

    public init(
        id: ConversationID = UUID().uuidString.lowercased(),
        title: String = "New Conversation",
        messages: [ChatMessage] = [],
        runs: [RunID: AgentRun] = [:],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        selectedModel: AgentModel = .gpt4o,
        draft: String = "",
        isPinned: Bool = false
    ) {
        self.id = id
        self.title = title
        self.messages = messages
        self.runs = runs
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.selectedModel = selectedModel
        self.draft = draft
        self.isPinned = isPinned
    }

    public var lastMessagePreview: String {
        if let last = messages.last {
            let txt = last.plainTextContent.trimmingCharacters(in: .whitespacesAndNewlines)
            if !txt.isEmpty { return txt }
            if !last.segments.isEmpty { return "Rich card content" }
            return "Attachment"
        }
        return "No messages yet"
    }
}
