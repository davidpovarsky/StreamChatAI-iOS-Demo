// Sources/AgentUI/Chat/AgentChatScreen.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentChatScreen: View {
    @Bindable public var session: AgentUISession
    public var configuration: AgentChatConfiguration
    public var surfaces: AgentToolSurfaceRegistry?
    public var embeddedSurfaces: AgentEmbeddedSurfaceRegistry?
    public var hostActions: (any AgentHostActions)?

    @State private var mediaCoordinator = AgentMediaNavigationCoordinator()
    @Namespace private var zoomNamespace

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
        NavigationStack {
            AgentChatView(
                session: session,
                configuration: configuration,
                surfaces: surfaces,
                embeddedSurfaces: embeddedSurfaces,
                hostActions: hostActions
            )
            .environment(\.agentMediaCoordinator, mediaCoordinator)
            .environment(\.agentImageZoomNamespace, zoomNamespace)
            .navigationDestination(isPresented: Binding(
                get: { mediaCoordinator.activeZoomImageID != nil },
                set: { if !$0 { mediaCoordinator.dismiss() } }
            )) {
                if let imageID = mediaCoordinator.activeZoomImageID {
                    imageDestinationView(imageID: imageID)
                }
            }
        }
    }

    @ViewBuilder
    private func imageDestinationView(imageID: String) -> some View {
        #if os(iOS)
        if #available(iOS 18.0, *) {
            AgentImageViewer(
                imageURL: mediaCoordinator.activeImageURL,
                altText: mediaCoordinator.activeAltText,
                onClose: { mediaCoordinator.dismiss() }
            )
            .navigationTransition(.zoom(sourceID: imageID, in: zoomNamespace))
        } else {
            AgentImageViewer(
                imageURL: mediaCoordinator.activeImageURL,
                altText: mediaCoordinator.activeAltText,
                onClose: { mediaCoordinator.dismiss() }
            )
        }
        #else
        AgentImageViewer(
            imageURL: mediaCoordinator.activeImageURL,
            altText: mediaCoordinator.activeAltText,
            onClose: { mediaCoordinator.dismiss() }
        )
        #endif
    }
}
#endif
