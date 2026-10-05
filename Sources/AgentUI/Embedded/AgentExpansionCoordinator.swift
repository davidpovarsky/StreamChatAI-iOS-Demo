// Sources/AgentUI/Embedded/AgentExpansionCoordinator.swift
import Foundation
import Observation

@MainActor
@Observable
public final class AgentExpansionCoordinator {
    public var activeSheetSession: (any AgentEmbeddedResultSession)?
    public var activeFullScreenSession: (any AgentEmbeddedResultSession)?
    public var isSheetPresented: Bool {
        activeSheetSession != nil
    }
    public var isFullScreenPresented: Bool {
        activeFullScreenSession != nil
    }

    public init() {}

    public func presentSheet(_ session: any AgentEmbeddedResultSession) {
        self.activeSheetSession = session
    }

    public func presentFullScreen(_ session: any AgentEmbeddedResultSession) {
        self.activeFullScreenSession = session
    }

    public func dismiss() {
        self.activeSheetSession = nil
        self.activeFullScreenSession = nil
    }
}
