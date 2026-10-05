//
//  ToolCallInspection.swift
//  AgentUI
//
//  Lightweight, portable value model for displaying tool call inspection details.
//

import Foundation

public struct ToolCallField: Identifiable, Equatable, Sendable {
    public var id: String { key }
    public let key: String
    public let value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

public enum ToolCallArguments: Equatable, Sendable {
    case json(String)
    case fields([ToolCallField])
    case text(String)

    public var formattedText: String {
        switch self {
        case .json(let raw):
            return Self.prettyPrintedJSON(raw)
        case .fields(let fields):
            return fields.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
        case .text(let text):
            return text
        }
    }

    private static func prettyPrintedJSON(_ raw: String) -> String {
        guard let data = raw.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys]),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return raw
        }
        return prettyString
    }
}

public struct ToolCallInspection: Identifiable, Equatable, Sendable {
    public let id: String
    public let service: String?
    public let toolName: String
    public let callID: String?
    public let arguments: ToolCallArguments
    public let resultSummary: String?
    public let errorMessage: String?

    public init(
        id: String = UUID().uuidString,
        service: String? = nil,
        toolName: String,
        callID: String? = nil,
        arguments: ToolCallArguments,
        resultSummary: String? = nil,
        errorMessage: String? = nil
    ) {
        self.id = id
        self.service = service
        self.toolName = toolName
        self.callID = callID
        self.arguments = arguments
        self.resultSummary = resultSummary
        self.errorMessage = errorMessage
    }
}
