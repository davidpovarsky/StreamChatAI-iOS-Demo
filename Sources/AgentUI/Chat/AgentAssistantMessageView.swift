// Sources/AgentUI/Chat/AgentAssistantMessageView.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentAssistantMessageView: View {
    public let message: AgentMessage
    public var activitySession: AgentActivitySession?
    public var onToggleActivity: (() -> Void)?

    @Environment(\.agentUITheme) private var theme
    @Environment(\.agentUIDesignTokens) private var tokens

    public init(
        message: AgentMessage,
        activitySession: AgentActivitySession? = nil,
        onToggleActivity: (() -> Void)? = nil
    ) {
        self.message = message
        self.activitySession = activitySession
        self.onToggleActivity = onToggleActivity
    }

    public var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                // Activity Timeline if present
                if let activity = activitySession, !activity.items.isEmpty {
                    AgentActivityTimelineView(
                        session: activity,
                        onToggle: onToggleActivity ?? {}
                    )
                }

                // Render content blocks
                ForEach(message.blocks) { block in
                    AgentContentRenderer(block: block)
                }

                // Streaming indicator if active with no content yet
                if message.isStreaming && message.blocks.isEmpty {
                    HStack(spacing: 4) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Thinking...")
                            .font(.subheadline)
                            .foregroundStyle(theme.secondaryText)
                    }
                    .padding(.vertical, 4)
                }

                // Footer sources if present
                if !message.allSources.isEmpty {
                    AgentSourcesFooterPill(sources: message.allSources)
                }

                // Error message if any
                if let err = message.error {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(theme.errorColor)
                        Text(err.message)
                            .font(.caption)
                            .foregroundStyle(theme.errorColor)
                    }
                    .padding(8)
                    .background(theme.errorColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            Spacer(minLength: 24)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 2)
    }
}
#endif
