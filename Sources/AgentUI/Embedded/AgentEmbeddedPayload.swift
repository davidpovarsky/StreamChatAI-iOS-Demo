// Sources/AgentUI/Embedded/AgentEmbeddedPayload.swift
import Foundation

public struct AgentEmbeddedContentAction: Identifiable, Sendable, Equatable, Hashable {
    public let id: String
    public let title: String
    public let iconSystemName: String?
    public let actionID: String

    public init(id: String = UUID().uuidString, title: String, iconSystemName: String? = nil, actionID: String) {
        self.id = id
        self.title = title
        self.iconSystemName = iconSystemName
        self.actionID = actionID
    }
}

public struct AgentEmbeddedPayload: Sendable, Equatable {
    public let jsonString: String
    public let dictionary: [String: String]
    public let actions: [AgentEmbeddedContentAction]

    public init(
        jsonString: String = "{}",
        dictionary: [String: String] = [:],
        actions: [AgentEmbeddedContentAction] = []
    ) {
        self.jsonString = jsonString
        self.dictionary = dictionary
        self.actions = actions
    }

    public static let empty = AgentEmbeddedPayload()
}
