// Sources/AgentUI/Media/AgentMediaFallbackView.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentMediaFallbackView: View {
    public let icon: String
    public let title: String
    public var actionTitle: String?
    public var action: (() -> Void)?

    @Environment(\.agentUITheme) private var theme

    public init(
        icon: String = "photo",
        title: String = "Media unavailable",
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(theme.secondaryText)

            Text(title)
                .font(.caption)
                .foregroundStyle(theme.secondaryText)

            Spacer()

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.accentColor)
                }
            }
        }
        .padding(12)
        .background(theme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
#endif
