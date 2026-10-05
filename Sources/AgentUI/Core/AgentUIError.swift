// Sources/AgentUI/Core/AgentUIError.swift
import Foundation

public struct AgentUIError: Error, Sendable, Equatable, CustomStringConvertible {
    public let code: String
    public let message: String
    public let underlyingErrorDescription: String?

    public init(
        code: String = "agent_error",
        message: String,
        underlyingErrorDescription: String? = nil
    ) {
        self.code = code
        self.message = message
        self.underlyingErrorDescription = underlyingErrorDescription
    }

    public var description: String {
        if let underlying = underlyingErrorDescription {
            return "[\(code)] \(message) (\(underlying))"
        }
        return "[\(code)] \(message)"
    }
}
