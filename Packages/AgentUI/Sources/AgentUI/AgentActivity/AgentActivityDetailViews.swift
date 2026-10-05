//
//  AgentActivityDetailViews.swift
//  AgentUI
//

import SwiftUI

public struct AgentSearchDetailsView: View {
    public let sources: [WebSearchSource]
    public let isDarkMode: Bool

    public init(sources: [WebSearchSource], isDarkMode: Bool) {
        self.sources = sources
        self.isDarkMode = isDarkMode
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            ForEach(sources) { source in
                HStack(spacing: 8) {
                    FaviconView(url: source.url, isDarkMode: isDarkMode)
                        .frame(width: 16, height: 16)
                    Text(domain(for: source.url))
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.leading, 24)
    }

    private func domain(for value: String) -> String {
        guard let host = URL(string: value)?.host else { return value }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }
}

public struct AgentToolDetailsView: View {
    public let item: AgentActivityItem

    public init(item: AgentActivityItem) {
        self.item = item
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            detail("Tool", item.toolName)
            detail("Details", item.toolArguments)
            detail("Result", item.toolResultSummary)
        }
        .padding(.leading, 24)
    }

    @ViewBuilder
    private func detail(_ label: String, _ value: String?) -> some View {
        if let value, !value.isEmpty {
            HStack(alignment: .top, spacing: 5) {
                Text("\(label):").fontWeight(.medium)
                Text(value)
            }
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
        }
    }
}
