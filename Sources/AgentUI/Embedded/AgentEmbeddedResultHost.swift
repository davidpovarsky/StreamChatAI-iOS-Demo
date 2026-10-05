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
                if descriptor.expansion.allowedModes.contains(.sheet) {
                    Button {
                        isSheetPresented = true
                    } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(theme.tertiaryText)
                            .padding(4)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Expand to full sheet")
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
                            // Action tap
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
                session = registry.resolve(descriptor: descriptor)
            }
        }
        .onDisappear {
            session?.tearDown()
        }
        .sheet(isPresented: $isSheetPresented) {
            if let session {
                NavigationStack {
                    session.rootView
                        .navigationTitle(descriptor.title ?? "Result")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Done") { isSheetPresented = false }
                            }
                        }
                }
            }
        }
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
