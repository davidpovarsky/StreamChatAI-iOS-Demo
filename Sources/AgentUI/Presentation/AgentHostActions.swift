// Sources/AgentUI/Presentation/AgentHostActions.swift
import Foundation

public struct AgentHostAction: Sendable, Equatable {
    public let actionID: String
    public let payload: String?

    public init(actionID: String, payload: String? = nil) {
        self.actionID = actionID
        self.payload = payload
    }
}

public struct AgentPresentationRequest: Sendable, Equatable {
    public let id: String
    public let title: String?
    public let targetIdentifier: String

    public init(id: String = UUID().uuidString, title: String? = nil, targetIdentifier: String) {
        self.id = id
        self.title = title
        self.targetIdentifier = targetIdentifier
    }
}

@MainActor
public protocol AgentHostActions: AnyObject, Sendable {
    func openURL(_ url: URL)
    func requestSheet(_ request: AgentPresentationRequest)
    func requestFullScreen(_ request: AgentPresentationRequest)
    func requestWindow(_ request: AgentPresentationRequest)
    func performAction(_ action: AgentHostAction)
}
