// Sources/AgentUI/Core/AgentIDs.swift
import Foundation

public struct AgentMessageID: Hashable, Identifiable, Sendable, Codable, ExpressibleByStringInterpolation {
    public let rawValue: String

    public var id: String { rawValue }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    public init() {
        self.rawValue = UUID().uuidString
    }
}

public struct AgentRequestID: Hashable, Identifiable, Sendable, Codable, ExpressibleByStringInterpolation {
    public let rawValue: String

    public var id: String { rawValue }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    public init() {
        self.rawValue = UUID().uuidString
    }
}

public struct AgentActivityID: Hashable, Identifiable, Sendable, Codable, ExpressibleByStringInterpolation {
    public let rawValue: String

    public var id: String { rawValue }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    public init() {
        self.rawValue = UUID().uuidString
    }
}

public struct AgentToolCallID: Hashable, Identifiable, Sendable, Codable, ExpressibleByStringInterpolation {
    public let rawValue: String

    public var id: String { rawValue }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    public init() {
        self.rawValue = UUID().uuidString
    }
}

public struct AgentEmbeddedID: Hashable, Identifiable, Sendable, Codable, ExpressibleByStringInterpolation {
    public let rawValue: String

    public var id: String { rawValue }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    public init() {
        self.rawValue = UUID().uuidString
    }
}

public struct AgentConversationID: Hashable, Identifiable, Sendable, Codable, ExpressibleByStringInterpolation {
    public let rawValue: String

    public var id: String { rawValue }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    public init() {
        self.rawValue = UUID().uuidString
    }
}
