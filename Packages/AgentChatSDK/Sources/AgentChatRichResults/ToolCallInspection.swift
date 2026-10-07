#if canImport(AgentChatCore)
import AgentChatCore
#endif
import Foundation

public enum ToolExecutionStatus: String, Codable, Sendable, Equatable {
    case running
    case completed
    case failed
}

public struct ToolCallInspection: Identifiable, Sendable, Equatable {
    public let id: String
    public let toolName: String
    public let arguments: String
    public let rawOutput: String?
    public let duration: TimeInterval
    public let service: String?
    public let timestamp: Date

    public init(
        id: String = UUID().uuidString,
        toolName: String,
        arguments: String = "{}",
        rawOutput: String? = nil,
        duration: TimeInterval = 0,
        service: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.toolName = toolName
        self.arguments = arguments
        self.rawOutput = rawOutput
        self.duration = duration
        self.service = service
        self.timestamp = timestamp
    }

    public init(call: AgentToolCall, result: AgentToolResult? = nil) {
        self.id = call.id
        self.toolName = call.name
        self.arguments = call.arguments
        self.rawOutput = result?.rawOutput ?? result?.outputSummary
        self.duration = result != nil ? result!.timestamp.timeIntervalSince(call.timestamp) : 0
        self.service = call.service
        self.timestamp = call.timestamp
    }
}
