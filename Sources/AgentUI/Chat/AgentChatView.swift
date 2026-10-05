// Sources/AgentUI/Chat/AgentChatView.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentChatConfiguration: Sendable, Equatable {
    public var title: String?
    public var showHeader: Bool

    public init(
        title: String? = nil,
        showHeader: Bool = true
    ) {
        self.title = title
        self.showHeader = showHeader
    }

    public static let `default` = AgentChatConfiguration()
}

public struct AgentChatView: View {
    @Bindable public var session: AgentUISession
    public var configuration: AgentChatConfiguration
    public var surfaces: AgentToolSurfaceRegistry?
    public var embeddedSurfaces: AgentEmbeddedSurfaceRegistry?
    public var hostActions: (any AgentHostActions)?

    public init(
        session: AgentUISession,
        configuration: AgentChatConfiguration = .default,
        surfaces: AgentToolSurfaceRegistry? = nil,
        embeddedSurfaces: AgentEmbeddedSurfaceRegistry? = nil,
        hostActions: (any AgentHostActions)? = nil
    ) {
        self.session = session
        self.configuration = configuration
        self.surfaces = surfaces
        self.embeddedSurfaces = embeddedSurfaces
        self.hostActions = hostActions
    }

    public var body: some View {
        AgentChatShell(
            session: session,
            title: configuration.showHeader ? configuration.title : nil
        )
        .environment(\.agentToolSurfaces, surfaces ?? AgentToolSurfaceRegistry.shared)
        .environment(\.agentEmbeddedSurfaces, embeddedSurfaces ?? AgentEmbeddedSurfaceRegistry.shared)
    }
}
#endif
