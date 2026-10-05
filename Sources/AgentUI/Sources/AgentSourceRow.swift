// Sources/AgentUI/Sources/AgentSourceRow.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentSourceRow: View {
    public let source: AgentSource

    @Environment(\.agentUITheme) private var theme

    public init(source: AgentSource) {
        self.source = source
    }

    public var body: some View {
        if let targetURL = URL(string: source.url) {
            Link(destination: targetURL) {
                content
            }
            .buttonStyle(.plain)
        } else {
            content
        }
    }

    private var content: some View {
        HStack(spacing: 10) {
            if let faviconURL = source.faviconURL {
                AsyncImage(url: faviconURL) { img in
                    img.resizable().scaledToFit()
                } placeholder: {
                    Image(systemName: "globe")
                        .foregroundStyle(theme.secondaryText)
                }
                .frame(width: 18, height: 18)
                .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(source.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(theme.primaryText)
                    .lineLimit(1)

                Text(source.domain)
                    .font(.caption2)
                    .foregroundStyle(theme.secondaryText)
            }

            Spacer()

            Image(systemName: "arrow.up.right")
                .font(.caption2)
                .foregroundStyle(theme.tertiaryText)
        }
        .padding(.vertical, 4)
    }
}
#endif
