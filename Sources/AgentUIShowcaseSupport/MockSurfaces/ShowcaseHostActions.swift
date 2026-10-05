// Sources/AgentUIShowcaseSupport/MockSurfaces/ShowcaseHostActions.swift
import Foundation
import AgentUI

@MainActor
public final class ShowcaseHostActions: AgentHostActions, @unchecked Sendable {
    public var lastOpenedURL: URL?
    public var lastRequestedSheet: AgentPresentationRequest?
    public var lastRequestedFullScreen: AgentPresentationRequest?
    public var lastRequestedWindow: AgentPresentationRequest?
    public var lastPerformedAction: AgentHostAction?
    public var lastActionMessage: String?

    public init() {}

    public func openURL(_ url: URL) {
        lastOpenedURL = url
        lastActionMessage = "Opened URL: \(url.absoluteString)"
    }

    public func requestSheet(_ request: AgentPresentationRequest) {
        lastRequestedSheet = request
        lastActionMessage = "Requested Sheet: \(request.title ?? request.targetIdentifier)"
    }

    public func requestFullScreen(_ request: AgentPresentationRequest) {
        lastRequestedFullScreen = request
        lastActionMessage = "Requested FullScreen: \(request.title ?? request.targetIdentifier)"
    }

    public func requestWindow(_ request: AgentPresentationRequest) {
        lastRequestedWindow = request
        lastActionMessage = "Requested Window: \(request.title ?? request.targetIdentifier)"
    }

    public func performAction(_ action: AgentHostAction) {
        lastPerformedAction = action
        lastActionMessage = "Performed Action: \(action.actionID)"
    }
}
