// Sources/AgentUI/NativeBlocks/AgentNativeBlockRenderer.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentNativeBlockRenderer: View {
    public let block: AgentNativeUIBlock

    @Environment(\.agentUITheme) private var theme
    @Environment(\.agentUIDesignTokens) private var tokens
    @Environment(\.agentHostActions) private var hostActions

    public init(block: AgentNativeUIBlock) {
        self.block = block
    }

    public var body: some View {
        switch block.family {
        case .text:
            textView

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

    private var textView: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let title = block.title {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(theme.primaryText)
            }
            if let body = block.body {
                Text(body)
                    .font(.body)
                    .foregroundStyle(theme.primaryText)
            }
            if let footnote = block.footnote {
                Text(footnote)
                    .font(.caption2)
                    .foregroundStyle(theme.tertiaryText)
            }
            actionsView
        }
    }

    private var cardView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with icon, title, subtitle
            if block.title != nil || block.systemImage != nil {
                HStack(alignment: .top, spacing: 8) {
                    if let systemImage = block.systemImage {
                        Image(systemName: systemImage)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(theme.accentColor)
                    }
                    VStack(alignment: .leading, spacing: 2) {
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
                    }
                    Spacer()
                }
            }

            // Image if present
            if let imageURL = block.imageURL {
                AgentImageView(url: imageURL, altText: block.title)
            }

            // Body text
            if let body = block.body {
                Text(body)
                    .font(.body)
                    .foregroundStyle(theme.primaryText)
            }

            // Key-values if present
            if !block.keyValues.isEmpty {
                keyValuesContent
            }

            // Link if present
            if let url = block.url {
                Link(destination: url) {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                        Text(url.absoluteString)
                            .lineLimit(1)
                    }
                    .font(.caption)
                    .foregroundStyle(theme.accentColor)
                }
            }

            // Footnote
            if let footnote = block.footnote {
                Text(footnote)
                    .font(.caption2)
                    .foregroundStyle(theme.tertiaryText)
            }

            // Child blocks
            if !block.children.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(block.children) { child in
                        AgentNativeBlockRenderer(block: child)
                    }
                }
            }

            // Actions
            actionsView
        }
        .padding(12)
        .background(theme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: tokens.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: tokens.cardCornerRadius)
                .strokeBorder(theme.borderColor, lineWidth: 0.5)
        )
    }

    private var searchResultsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: block.systemImage ?? "magnifyingglass")
                    .foregroundStyle(theme.accentColor)
                Text(block.title ?? "Search Results")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.primaryText)
                Spacer()
            }

            if let subtitle = block.subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(theme.secondaryText)
            }

            if let body = block.body {
                Text(body)
                    .font(.body)
                    .foregroundStyle(theme.primaryText)
            }

            ForEach(block.children) { child in
                AgentNativeBlockRenderer(block: child)
            }

            if let footnote = block.footnote {
                Text(footnote)
                    .font(.caption2)
                    .foregroundStyle(theme.tertiaryText)
            }

            actionsView
        }
        .padding(10)
        .background(theme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: tokens.cardCornerRadius))
    }

    private var sourceView: some View {
        HStack(spacing: 8) {
            Image(systemName: block.systemImage ?? "doc.text")
                .foregroundStyle(theme.accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(block.title ?? "Source")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(theme.primaryText)
                if let sub = block.subtitle {
                    Text(sub)
                        .font(.caption2)
                        .foregroundStyle(theme.secondaryText)
                }
                if let footnote = block.footnote {
                    Text(footnote)
                        .font(.caption2)
                        .foregroundStyle(theme.tertiaryText)
                }
            }
            Spacer()
            if let url = block.url {
                Link(destination: url) {
                    Image(systemName: "arrow.up.right")
                        .font(.caption2)
                        .foregroundStyle(theme.tertiaryText)
                }
            }
        }
        .padding(8)
    }

    private var calculationView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if let title = block.title {
                    Text(title)
                        .font(.body.monospaced())
                        .foregroundStyle(theme.primaryText)
                }
                Spacer()
                if let body = block.body {
                    Text("= \(body)")
                        .font(.headline.monospaced())
                        .foregroundStyle(theme.accentColor)
                }
            }

            if let footnote = block.footnote {
                Text(footnote)
                    .font(.caption2)
                    .foregroundStyle(theme.tertiaryText)
            }

            actionsView
        }
        .padding(10)
        .background(theme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var keyValueListView: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let title = block.title {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.primaryText)
                    .padding(.bottom, 2)
            }

            keyValuesContent

            if let footnote = block.footnote {
                Text(footnote)
                    .font(.caption2)
                    .foregroundStyle(theme.tertiaryText)
            }

            actionsView
        }
        .padding(10)
        .background(theme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var keyValuesContent: some View {
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

    private var errorView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: block.systemImage ?? "exclamationmark.octagon.fill")
                    .foregroundStyle(theme.errorColor)
                Text(block.body ?? block.title ?? AgentLocalization.string("Error"))
                    .font(.caption)
                    .foregroundStyle(theme.errorColor)
                Spacer()
            }

            if let footnote = block.footnote {
                Text(footnote)
                    .font(.caption2)
                    .foregroundStyle(theme.tertiaryText)
            }

            actionsView
        }
        .padding(10)
        .background(theme.errorColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private var actionsView: some View {
        if !block.actions.isEmpty {
            HStack(spacing: 8) {
                ForEach(block.actions) { actionItem in
                    Button {
                        handleAction(actionItem)
                    } label: {
                        HStack(spacing: 4) {
                            if let icon = actionItem.iconSystemName {
                                Image(systemName: icon)
                            }
                            Text(actionItem.title)
                                .font(.caption.weight(.medium))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(theme.surfaceBackground)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(hostActions == nil && !isSelfHandled(actionItem.action))
                    .accessibilityIdentifier("agentui_native_action_\(actionItem.id)")
                }
            }
            .padding(.top, 2)
        }
    }

    private func isSelfHandled(_ action: AgentNativeBlockAction) -> Bool {
        switch action {
        case .openURL:
            return true
        case .copy:
            return true
        case .hostAction, .routeAction:
            return false
        }
    }

    private func handleAction(_ actionItem: AgentNativeBlockActionItem) {
        switch actionItem.action {
        case .openURL(let url):
            if let hostActions {
                hostActions.openURL(url)
            }
        case .copy(let text):
            #if os(iOS)
            UIPasteboard.general.string = text
            #endif
            hostActions?.performAction(AgentHostAction(actionID: "copy", payload: text))
        case .hostAction(let actionID, let payload):
            hostActions?.performAction(AgentHostAction(actionID: actionID, payload: payload))
        case .routeAction(let route):
            hostActions?.performAction(AgentHostAction(actionID: "route", payload: route))
        }
    }
}
#endif
