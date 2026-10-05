// Sources/AgentUI/Rendering/AgentLinkPreviewView.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentLinkPreviewView: View {
    public let url: URL
    public let title: String?
    public let descriptionText: String?
    public let iconURL: URL?

    @Environment(\.agentUITheme) private var theme
    @Environment(\.agentUIDesignTokens) private var tokens

    public init(
        url: URL,
        title: String? = nil,
        descriptionText: String? = nil,
        iconURL: URL? = nil
    ) {
        self.url = url
        self.title = title
        self.descriptionText = descriptionText
        self.iconURL = iconURL
    }

    public var body: some View {
        Link(destination: url) {
            HStack(spacing: 12) {
                if let iconURL {
                    AsyncImage(url: iconURL) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        Image(systemName: "globe")
                    }
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image(systemName: "safari")
                        .font(.system(size: 22))
                        .foregroundStyle(theme.accentColor)
                        .frame(width: 36, height: 36)
                        .background(theme.surfaceBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title ?? url.host ?? url.absoluteString)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(theme.primaryText)
                        .lineLimit(1)

                    if let descriptionText, !descriptionText.isEmpty {
                        Text(descriptionText)
                            .font(.caption)
                            .foregroundStyle(theme.secondaryText)
                            .lineLimit(2)
                    }

                    Text(url.host ?? url.absoluteString)
                        .font(.caption2)
                        .foregroundStyle(theme.tertiaryText)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(theme.tertiaryText)
            }
            .padding(12)
            .background(theme.surfaceBackground)
            .clipShape(RoundedRectangle(cornerRadius: tokens.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: tokens.cardCornerRadius)
                    .strokeBorder(theme.borderColor, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
    }
}
#endif
