// Sources/AgentUI/NativeBlocks/AgentNativeBlockRenderer.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentNativeBlockRenderer: View {
    public let block: AgentNativeUIBlock

    @Environment(\.agentUITheme) private var theme
    @Environment(\.agentUIDesignTokens) private var tokens

    public init(block: AgentNativeUIBlock) {
        self.block = block
    }

    public var body: some View {
        switch block.family {
        case .text:
            if let body = block.body {
                Text(body)
                    .font(.body)
                    .foregroundStyle(theme.primaryText)
            }

        case .markdown:
            if let body = block.body {
                AgentMarkdownView(content: body)
            }

        case .card, .summary:
            cardView

        case .searchResults:
            searchResultsView

        case .source:
            sourceView

        case .calculation:
            calculationView

        case .keyValueList:
            keyValueListView

        case .error:
            errorView
        }
    }

    private var cardView: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let title = block.title {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(theme.primaryText)
            }
            if let subtitle = block.subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryText)
            }
            if let body = block.body {
                Text(body)
                    .font(.body)
                    .foregroundStyle(theme.primaryText)
            }
            if !block.children.isEmpty {
                ForEach(block.children) { child in
                    AgentNativeBlockRenderer(block: child)
                }
            }
        }
        .padding(12)
        .background(theme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: tokens.cardCornerRadius))
    }

    private var searchResultsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = block.title {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                    Text(title).font(.subheadline.weight(.semibold))
                }
            }
            ForEach(block.children) { child in
                AgentNativeBlockRenderer(block: child)
            }
        }
        .padding(10)
        .background(theme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: tokens.cardCornerRadius))
    }

    private var sourceView: some View {
        HStack(spacing: 8) {
            Image(systemName: "doc.text")
                .foregroundStyle(theme.accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(block.title ?? "Source")
                    .font(.subheadline.weight(.medium))
                if let sub = block.subtitle {
                    Text(sub).font(.caption2).foregroundStyle(theme.secondaryText)
                }
            }
            Spacer()
        }
        .padding(8)
    }

    private var calculationView: some View {
        HStack {
            if let title = block.title {
                Text(title).font(.body.monospaced())
            }
            Spacer()
            if let body = block.body {
                Text("= \(body)")
                    .font(.headline.monospaced())
                    .foregroundStyle(theme.accentColor)
            }
        }
        .padding(10)
        .background(theme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var keyValueListView: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(block.keyValues, id: \.key) { kv in
                HStack {
                    Text(kv.key)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(theme.secondaryText)
                    Spacer()
                    Text(kv.value)
                        .font(.caption.monospaced())
                        .foregroundStyle(theme.primaryText)
                }
                .padding(.vertical, 2)
            }
        }
        .padding(10)
        .background(theme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var errorView: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.octagon.fill")
                .foregroundStyle(theme.errorColor)
            Text(block.body ?? block.title ?? "Error")
                .font(.caption)
                .foregroundStyle(theme.errorColor)
        }
        .padding(10)
        .background(theme.errorColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
#endif
