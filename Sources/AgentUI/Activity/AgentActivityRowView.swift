// Sources/AgentUI/Activity/AgentActivityRowView.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentActivityRowView: View {
    public let item: AgentActivityItem
    @State private var isDetailExpanded: Bool

    @Environment(\.agentUITheme) private var theme
    @Environment(\.agentUIDesignTokens) private var tokens

    public init(item: AgentActivityItem) {
        self.item = item
        self._isDetailExpanded = State(initialValue: item.isExpanded)
    }

    private var hasDetails: Bool {
        (item.summary != nil && !item.summary!.isEmpty) ||
        !item.sources.isEmpty ||
        item.toolResultSummary != nil
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button {
                if hasDetails {
                    isDetailExpanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: item.kind.iconSystemName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(theme.secondaryText)
                        .frame(width: tokens.timelineIconSize, height: tokens.timelineIconSize)

                    Text(item.title)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(theme.primaryText)
                        .lineLimit(1)

                    Spacer()

                    if item.status == .running {
                        ProgressView()
                            .controlSize(.mini)
                    } else if item.status == .failed {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(theme.errorColor)
                    } else if hasDetails {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(theme.tertiaryText)
                            .rotationEffect(.degrees(isDetailExpanded ? 90 : 0))
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!hasDetails)

            if isDetailExpanded && hasDetails {
                AgentActivityDetailsView(item: item)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
#endif
