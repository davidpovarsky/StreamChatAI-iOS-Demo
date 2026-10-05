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

    @State private var ownedToolRegistry: AgentToolSurfaceRegistry
    @State private var ownedEmbeddedRegistry: AgentEmbeddedSurfaceRegistry
    @State private var ownedExpansionCoordinator = AgentExpansionCoordinator()

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
        self._ownedToolRegistry = State(initialValue: surfaces ?? AgentToolSurfaceRegistry())
        self._ownedEmbeddedRegistry = State(initialValue: embeddedSurfaces ?? AgentEmbeddedSurfaceRegistry())
    }

    public var body: some View {
        AgentChatShell(
            session: session,
            title: configuration.showHeader ? configuration.title : nil
        )
        .environment(\.agentToolSurfaces, surfaces ?? ownedToolRegistry)
        .environment(\.agentEmbeddedSurfaces, embeddedSurfaces ?? ownedEmbeddedRegistry)
        .environment(\.agentHostActions, hostActions)
        .environment(\.agentExpansionCoordinator, ownedExpansionCoordinator)
        .sheet(item: Binding(
            get: {
                if ownedExpansionCoordinator.activePresentation?.mode == .sheet {
                    return ownedExpansionCoordinator.activePresentation
                }
                return nil
            },
            set: { if $0 == nil { ownedExpansionCoordinator.dismiss() } }
        )) { presentation in
            if let session = ownedExpansionCoordinator.activeSession {
                NavigationStack {
                    session.rootView
                        .navigationTitle(presentation.descriptor.title ?? AgentLocalization.string("Result"))
                        #if os(iOS)
                        .navigationBarTitleDisplayMode(.inline)
                        #endif
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button(AgentLocalization.string("Done")) { ownedExpansionCoordinator.dismiss() }
                            }
                        }
                }
            }
        }
        #if os(iOS)
        .fullScreenCover(item: Binding(
            get: {
                if ownedExpansionCoordinator.activePresentation?.mode == .fullScreen {
                    return ownedExpansionCoordinator.activePresentation
                }
                return nil
            },
            set: { if $0 == nil { ownedExpansionCoordinator.dismiss() } }
        )) { presentation in
            if let session = ownedExpansionCoordinator.activeSession {
                NavigationStack {
                    session.rootView
                        .navigationTitle(presentation.descriptor.title ?? AgentLocalization.string("Result"))
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button(AgentLocalization.string("Done")) { ownedExpansionCoordinator.dismiss() }
                            }
                        }
                }
            }
        }
        #endif
    }
}
#endif
