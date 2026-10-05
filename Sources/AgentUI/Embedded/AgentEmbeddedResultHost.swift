// Sources/AgentUI/Embedded/AgentEmbeddedResultHost.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentEmbeddedResultHost: View {
    public let descriptor: AgentEmbeddedPresentationDescriptor

    @State private var session: (any AgentEmbeddedResultSession)?
    @State private var isSheetPresented = false
    @State private var isFullScreenPresented = false

    @Environment(\.agentEmbeddedSurfaces) private var registry
    @Environment(\.agentUIDesignTokens) private var tokens
    @Environment(\.agentUITheme) private var theme
    @Environment(\.agentHostActions) private var hostActions
    @Environment(\.agentExpansionCoordinator) private var expansionCoordinator

    @State private var hasTornDown = false

    public init(descriptor: AgentEmbeddedPresentationDescriptor) {
        self.descriptor = descriptor
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header if title or expansion available
            HStack {
                if let title = descriptor.title {
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.secondaryText)
                }

                Spacer()

                // Expansion button
                if !descriptor.expansion.allowedModes.isEmpty {
                    Button {
                        handleExpansion()
                    } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(theme.tertiaryText)
                            .padding(4)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Expand result")
                    .accessibilityIdentifier("agentui_embedded_expand_button")
                }
            }

            // Embedded session content or fallback
            Group {
                if let session {
                    session.rootView
                        .frame(minHeight: targetHeight, maxHeight: maxHeight)
                } else {
                    fallbackView
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: tokens.embeddedResultCornerRadius))

            // Action buttons if present
            if !descriptor.payload.actions.isEmpty {
                HStack(spacing: 8) {
                    ForEach(descriptor.payload.actions) { action in
                        Button {
                            executeAction(action)
                        } label: {
                            HStack(spacing: 4) {
                                if let icon = action.iconSystemName {
                                    Image(systemName: icon)
                                }
                                Text(action.title)
                                    .font(.caption.weight(.medium))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(theme.surfaceBackground)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .disabled(hostActions == nil && !isSelfHandled(action))
                        .accessibilityIdentifier("agentui_embedded_action_\(action.actionID)")
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(12)
        .background(theme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: tokens.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: tokens.cardCornerRadius)
                .strokeBorder(theme.borderColor, lineWidth: 0.5)
        )
        .padding(.vertical, 4)
        .onAppear {
            if session == nil {
                session = registry?.resolve(descriptor: descriptor)
            }
        }
        .onDisappear {
            performTeardown()
        }
        .sheet(isPresented: $isSheetPresented) {
            if let session {
                NavigationStack {
                    session.rootView
                        .navigationTitle(descriptor.title ?? "Result")
                        #if os(iOS)
                        .navigationBarTitleDisplayMode(.inline)
                        #endif
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") { isSheetPresented = false }
                            }
                        }
                }
            }
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $isFullScreenPresented) {
            if let session {
                NavigationStack {
                    session.rootView
                        .navigationTitle(descriptor.title ?? "Result")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") { isFullScreenPresented = false }
                            }
                        }
                }
            }
        }
        #endif
    }

    private func handleExpansion() {
        let preferred = descriptor.expansion.preferredMode
        switch preferred {
        case .window:
            if let hostActions {
                hostActions.requestWindow(AgentPresentationRequest(title: descriptor.title, targetIdentifier: descriptor.handlerID))
            } else if descriptor.expansion.allowedModes.contains(.fullScreen) {
                presentExpanded(mode: .fullScreen)
            } else if descriptor.expansion.allowedModes.contains(.sheet) {
                presentExpanded(mode: .sheet)
            }
        case .fullScreen:
            #if os(iOS)
            if descriptor.expansion.allowedModes.contains(.fullScreen) {
                presentExpanded(mode: .fullScreen)
            } else if descriptor.expansion.allowedModes.contains(.sheet) {
                presentExpanded(mode: .sheet)
            }
            #else
            presentExpanded(mode: .sheet)
            #endif
        case .sheet:
            if descriptor.expansion.allowedModes.contains(.sheet) {
                presentExpanded(mode: .sheet)
            } else if descriptor.expansion.allowedModes.contains(.fullScreen) {
                #if os(iOS)
                presentExpanded(mode: .fullScreen)
                #else
                presentExpanded(mode: .sheet)
                #endif
            }
        }
    }

    private func presentExpanded(mode: AgentExpansionMode) {
        guard let session else { return }
        if let expansionCoordinator {
            expansionCoordinator.present(descriptor: descriptor, session: session, mode: mode)
        } else {
            if mode == .sheet {
                isSheetPresented = true
            } else if mode == .fullScreen {
                #if os(iOS)
                isFullScreenPresented = true
                #else
                isSheetPresented = true
                #endif
            }
        }
    }

    private func isSelfHandled(_ action: AgentEmbeddedContentAction) -> Bool {
        action.actionID.hasPrefix("http://") || action.actionID.hasPrefix("https://")
    }

    private func executeAction(_ action: AgentEmbeddedContentAction) {
        if action.actionID.hasPrefix("http://") || action.actionID.hasPrefix("https://"),
           let url = URL(string: action.actionID) {
            hostActions?.openURL(url)
            return
        }

        guard let hostActions else { return }

        if action.actionID == "window" {
            hostActions.requestWindow(AgentPresentationRequest(title: descriptor.title, targetIdentifier: descriptor.handlerID))
        } else if action.actionID == "sheet" {
            presentExpanded(mode: .sheet)
            hostActions.requestSheet(AgentPresentationRequest(title: descriptor.title, targetIdentifier: descriptor.handlerID))
        } else if action.actionID == "fullscreen" {
            presentExpanded(mode: .fullScreen)
            hostActions.requestFullScreen(AgentPresentationRequest(title: descriptor.title, targetIdentifier: descriptor.handlerID))
        } else {
            hostActions.performAction(AgentHostAction(actionID: action.actionID, payload: descriptor.payload.jsonString))
        }
    }

    private func performTeardown() {
        guard !hasTornDown else { return }
        if let expansionCoordinator, expansionCoordinator.isPresenting(descriptor: descriptor) {
            return
        }
        if isSheetPresented || isFullScreenPresented {
            return
        }
        hasTornDown = true
        session?.tearDown()
    }

    private var targetHeight: CGFloat {
        if let ideal = descriptor.sizing.idealHeight {
            return CGFloat(ideal)
        }
        return CGFloat(descriptor.sizing.preset.defaultHeight)
    }

    private var maxHeight: CGFloat? {
        if let max = descriptor.sizing.maxHeight {
            return CGFloat(max)
        }
        return nil
    }

    private var fallbackView: some View {
        HStack(spacing: 8) {
            Image(systemName: "app.dashed")
                .font(.system(size: 20))
                .foregroundStyle(theme.secondaryText)
            VStack(alignment: .leading, spacing: 2) {
                Text(descriptor.title ?? "Embedded Content")
                    .font(.subheadline.weight(.medium))
                Text(descriptor.handlerID)
                    .font(.caption2.monospaced())
                    .foregroundStyle(theme.tertiaryText)
            }
            Spacer()
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
    }
}
#endif
