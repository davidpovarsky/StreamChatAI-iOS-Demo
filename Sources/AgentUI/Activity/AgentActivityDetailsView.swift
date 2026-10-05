// Sources/AgentUI/Activity/AgentActivityDetailsView.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentActivityDetailsView: View {
    public let item: AgentActivityItem

    @Environment(\.agentUITheme) private var theme

    public init(item: AgentActivityItem) {
        self.item = item
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let summary = item.summary, !summary.isEmpty {
                Text(summary)
                    .font(.caption)
                    .foregroundStyle(theme.secondaryText)
            }

            if !item.sources.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(item.sources) { source in
                        HStack(spacing: 6) {
                            Image(systemName: "globe")
                                .font(.system(size: 10))
                                .foregroundStyle(theme.tertiaryText)
                            Text(source.domain)
                                .font(.caption2)
                                .foregroundStyle(theme.secondaryText)
                            Text("— \(source.title)")
                                .font(.caption2)
                                .foregroundStyle(theme.tertiaryText)
                                .lineLimit(1)
                        }
                    }
                }
                .padding(.top, 2)
            }

            if let result = item.toolResultSummary, !result.isEmpty {
                Text(result)
                    .font(.caption2.monospaced())
                    .foregroundStyle(theme.secondaryText)
                    .padding(6)
                    .background(theme.surfaceBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(.leading, 24)
        .padding(.vertical, 4)
    }
}
#endif
