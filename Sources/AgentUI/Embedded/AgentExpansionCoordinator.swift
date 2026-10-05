// Sources/AgentUI/Embedded/AgentExpansionCoordinator.swift
import Foundation
import Observation

public struct AgentExpansionPresentation: Identifiable, Sendable {
    public let id: String
    public let descriptor: AgentEmbeddedPresentationDescriptor
    public let mode: AgentExpansionMode

    public init(descriptor: AgentEmbeddedPresentationDescriptor, mode: AgentExpansionMode) {
        self.id = descriptor.handlerID
        self.descriptor = descriptor
        self.mode = mode
    }
}

@MainActor
@Observable
public final class AgentExpansionCoordinator {
    public var activePresentation: AgentExpansionPresentation?
    public var activeSession: (any AgentEmbeddedResultSession)?

    public var isSheetPresented: Bool {
        activePresentation?.mode == .sheet
    }

    public var isFullScreenPresented: Bool {
        activePresentation?.mode == .fullScreen
    }

    public init() {}

    public func present(descriptor: AgentEmbeddedPresentationDescriptor, session: any AgentEmbeddedResultSession, mode: AgentExpansionMode) {
        self.activePresentation = AgentExpansionPresentation(descriptor: descriptor, mode: mode)
        self.activeSession = session
    }

    public func presentSheet(descriptor: AgentEmbeddedPresentationDescriptor, session: any AgentEmbeddedResultSession) {
        present(descriptor: descriptor, session: session, mode: .sheet)
    }

    public func presentFullScreen(descriptor: AgentEmbeddedPresentationDescriptor, session: any AgentEmbeddedResultSession) {
        present(descriptor: descriptor, session: session, mode: .fullScreen)
    }

    public func dismiss() {
        self.activePresentation = nil
        self.activeSession = nil
    }

    public func isPresenting(descriptor: AgentEmbeddedPresentationDescriptor) -> Bool {
        activePresentation?.descriptor.handlerID == descriptor.handlerID
    }
}

#if canImport(SwiftUI)
import SwiftUI

extension EnvironmentValues {
    @Entry public var agentExpansionCoordinator: AgentExpansionCoordinator? = nil
}
#endif
