// Sources/AgentUI/Activity/AgentActivityTimelineView.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentActivityTimelineView: View {
    public let session: AgentActivitySession
    public let onToggle: () -> Void

    @Environment(\.agentUIDesignTokens) private var tokens

    public init(session: AgentActivitySession, onToggle: @escaping () -> Void) {
        self.session = session
        self.onToggle = onToggle
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: onToggle) {
                HStack(spacing: 6) {
                    AgentActivityDurationView(session: session)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(Color.secondary.opacity(0.6))
                        .rotationEffect(.degrees(session.isExpanded ? 90 : 0))

                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(session.isExpanded ? "Collapse activity timeline" : "Expand activity timeline")

            if session.isExpanded {
                VStack(alignment: .leading, spacing: tokens.timelineItemSpacing) {
                    ForEach(session.items) { item in
                        AgentActivityRowView(item: item)
                    }
                }
                .padding(.leading, 6)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
#endif
