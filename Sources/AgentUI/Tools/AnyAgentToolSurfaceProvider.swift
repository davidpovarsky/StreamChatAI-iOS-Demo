// Sources/AgentUI/Tools/AnyAgentToolSurfaceProvider.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentToolSurfaceContext: Sendable {
    public let execution: AgentToolExecution

    public init(execution: AgentToolExecution) {
        self.execution = execution
    }
}

public protocol AgentToolSurfaceProvider: Sendable {
    @MainActor
    func makeBody(context: AgentToolSurfaceContext) -> AnyView
}

public struct AnyAgentToolSurfaceProvider: AgentToolSurfaceProvider {
    private let _makeBody: @MainActor @Sendable (AgentToolSurfaceContext) -> AnyView

    public init<P: AgentToolSurfaceProvider>(_ provider: P) {
        self._makeBody = { context in provider.makeBody(context: context) }
    }

    public init<V: View>(@ViewBuilder _ builder: @escaping @MainActor @Sendable (AgentToolSurfaceContext) -> V) {
        self._makeBody = { context in AnyView(builder(context)) }
    }

    @MainActor
    public func makeBody(context: AgentToolSurfaceContext) -> AnyView {
        _makeBody(context)
    }
}
#endif
