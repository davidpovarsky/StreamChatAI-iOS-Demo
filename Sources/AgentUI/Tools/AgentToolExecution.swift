// Sources/AgentUI/Tools/AgentToolExecution.swift
import Foundation

public struct ToolCallInspection: Sendable, Equatable, Hashable {
    public let callID: String?
    public let service: String?
    public let toolName: String
    public let arguments: String
    public let resultSummary: String?
    public let errorMessage: String?

    public init(
        callID: String? = nil,
        service: String? = nil,
        toolName: String,
        arguments: String,
        resultSummary: String? = nil,
        errorMessage: String? = nil
    ) {
        self.callID = callID
        self.service = service
        self.toolName = toolName
        self.arguments = Self.sanitize(arguments: arguments)
        self.resultSummary = resultSummary
        self.errorMessage = errorMessage
    }

    public static func sanitize(arguments: String) -> String {
        var clean = arguments
        let sensitiveKeys = ["api_key", "apikey", "token", "access_token", "secret", "password", "authorization"]
        for key in sensitiveKeys {
            let pattern = "\"\(key)\"\\s*:\\s*\"[^\"]+\""
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(location: 0, length: clean.utf16.count)
                clean = regex.stringByReplacingMatches(in: clean, options: [], range: range, withTemplate: "\"\(key)\": \"[REDACTED]\"")
            }
        }
        return clean
    }

    public var prettyPrintedArguments: String {
        guard let data = arguments.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data),
              let prettyData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return arguments
        }
        return prettyString
    }
}

public struct AgentToolExecution: Identifiable, Sendable, Equatable, Hashable {
    public let id: AgentToolCallID
    public let handlerID: String
    public let inspection: ToolCallInspection
    public var status: AgentActivityStatus
    public var startedAt: Date
    public var completedAt: Date?
    public var isExpanded: Bool

    public init(
        id: AgentToolCallID = AgentToolCallID(),
        handlerID: String,
        inspection: ToolCallInspection,
        status: AgentActivityStatus = .running,
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        isExpanded: Bool = false
    ) {
        self.id = id
        self.handlerID = handlerID
        self.inspection = inspection
        self.status = status
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.isExpanded = isExpanded
    }
}
