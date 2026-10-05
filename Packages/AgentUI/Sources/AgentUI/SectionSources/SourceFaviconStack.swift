//
//  SourceFaviconStack.swift
//  AgentUI
//

import SwiftUI

public struct SourceFaviconStack: View {
    public let sources: [WebSearchSource]
    public let isDarkMode: Bool
    public var iconSize: CGFloat
    public var overlap: CGFloat

    public init(
        sources: [WebSearchSource],
        isDarkMode: Bool,
        iconSize: CGFloat = 18,
        overlap: CGFloat = -6
    ) {
        self.sources = sources
        self.isDarkMode = isDarkMode
        self.iconSize = iconSize
        self.overlap = overlap
    }

    private var uniqueDomains: [String] {
        var seen = Set<String>()
        var domains: [String] = []
        for source in sources {
            let domain = getDomain(from: source.url)
            if !seen.contains(domain) {
                seen.insert(domain)
                domains.append(domain)
            }
            if domains.count >= 4 { break }
        }
        return domains
    }

    private func getDomain(from urlString: String) -> String {
        guard let url = URL(string: urlString),
              let host = url.host else {
            return urlString
        }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }

    private func faviconUrl(for domain: String) -> String {
        "https://icons.duckduckgo.com/ip3/\(domain).ico"
    }

    public var body: some View {
        HStack(spacing: overlap) {
            ForEach(Array(uniqueDomains.enumerated()), id: \.offset) { index, domain in
                AsyncImage(url: URL(string: faviconUrl(for: domain))) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure, .empty:
                        Image(systemName: "globe")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: iconSize, height: iconSize)
                .background(isDarkMode ? Color.black : Color.white)
                .clipShape(Circle())
                .overlay(Circle().stroke(isDarkMode ? Color.white.opacity(0.2) : Color.black.opacity(0.1), lineWidth: 1))
                .zIndex(Double(uniqueDomains.count - index))
            }
        }
    }
}
