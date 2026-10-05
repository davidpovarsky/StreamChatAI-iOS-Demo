// Sources/AgentUI/Sources/AgentSourceCluster.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentSourceCluster: View {
    public let sources: [AgentSource]
    public let maxVisible: Int

    @Environment(\.agentUIDesignTokens) private var tokens
    @Environment(\.agentFaviconResolver) private var faviconResolver

    public init(sources: [AgentSource], maxVisible: Int = 4) {
        self.sources = sources
        self.maxVisible = maxVisible
    }

    private var orderedDomains: [String] {
        Array(AgentSourceClusterData(sources: sources).uniqueDomains.prefix(maxVisible))
    }

    public var body: some View {
        HStack(spacing: -6) {
            ForEach(orderedDomains, id: \.self) { domain in
                let favicon = faviconResolver?.resolveFavicon(for: domain) ?? URL(string: "https://icons.duckduckgo.com/ip3/\(domain).ico")
                AsyncImage(url: favicon) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Circle()
                        .fill(Color.secondary.opacity(0.2))
                        .overlay(Image(systemName: "globe").font(.system(size: 8)))
                }
                .frame(width: tokens.sourceFaviconSize, height: tokens.sourceFaviconSize)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(Color.white, lineWidth: 1))
                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
            }
        }
    }
}
#endif
