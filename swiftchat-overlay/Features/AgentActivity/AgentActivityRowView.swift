import SwiftUI

struct AgentActivityRowView: View {
    let item: AgentActivityItem
    let isDarkMode: Bool
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Button {
                if hasDetails { withAnimation(.easeInOut(duration: 0.18)) { isExpanded.toggle() } }
            } label: {
                HStack(spacing: 8) {
                    leadingIcon
                        .frame(width: 16, height: 16)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(item.title)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                        if let summary = item.summary, !summary.isEmpty {
                            Text(summary)
                                .font(.system(size: 11))
                                .foregroundStyle(.tertiary)
                                .lineLimit(2)
                        }
                    }
                    Spacer(minLength: 4)
                    if item.status == .running { ProgressView().controlSize(.mini) }
                    if hasDetails {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.tertiary)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                switch item.kind {
                case .webSearch:
                    AgentSearchDetailsView(sources: item.sources, isDarkMode: isDarkMode)
                case .toolCall:
                    AgentToolDetailsView(item: item)
                default:
                    EmptyView()
                }
            }
        }
    }

    @ViewBuilder
    private var leadingIcon: some View {
        switch item.kind {
        case .reasoning: Image(systemName: "brain.head.profile")
        case .webSearch:
            if let first = item.sources.first {
                FaviconView(url: first.url, isDarkMode: isDarkMode)
            } else {
                Image(systemName: "globe")
            }
        case .urlFetch: Image(systemName: "link")
        case .toolCall(let service):
            Image(systemName: service?.lowercased() == "github" ? "chevron.left.forwardslash.chevron.right" : "wrench.and.screwdriver")
        case .status: Image(systemName: "checkmark.circle")
        }
    }

    private var hasDetails: Bool {
        switch item.kind {
        case .webSearch: !item.sources.isEmpty
        case .toolCall: item.toolName != nil || item.toolArguments != nil || item.toolResultSummary != nil
        default: false
        }
    }
}
