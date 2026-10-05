// Sources/AgentUI/Composer/AgentAttachmentMenu.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentAttachmentMenu: View {
    public let isWebSearchEnabled: Bool
    public let onToggleWebSearch: () -> Void
    public let onAttachPhoto: () -> Void
    public let onAttachFile: () -> Void

    @Environment(\.agentUITheme) private var theme

    public init(
        isWebSearchEnabled: Bool = true,
        onToggleWebSearch: @escaping () -> Void = {},
        onAttachPhoto: @escaping () -> Void = {},
        onAttachFile: @escaping () -> Void = {}
    ) {
        self.isWebSearchEnabled = isWebSearchEnabled
        self.onToggleWebSearch = onToggleWebSearch
        self.onAttachPhoto = onAttachPhoto
        self.onAttachFile = onAttachFile
    }

    public var body: some View {
        Menu {
            Button(action: onToggleWebSearch) {
                Label(
                    isWebSearchEnabled ? "Web Search: Enabled" : "Web Search: Disabled",
                    systemImage: isWebSearchEnabled ? "globe.badge.chevron.backward" : "globe"
                )
            }

            Divider()

            Button(action: onAttachPhoto) {
                Label("Photos & Media", systemImage: "photo")
            }

            Button(action: onAttachFile) {
                Label("Documents & Files", systemImage: "doc")
            }
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 15, weight: .semibold))
                .frame(width: 32, height: 32)
                .background(theme.surfaceBackground)
                .clipShape(Circle())
                .foregroundStyle(theme.primaryText)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add attachments or options")
    }
}
#endif
