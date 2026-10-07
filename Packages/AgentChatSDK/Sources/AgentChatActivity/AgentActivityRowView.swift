#if canImport(SwiftUI)
import AgentChatCore
import SwiftUI

public struct AgentActivityRowView: View {
    public let item: AgentActivityItem
    public let isLast: Bool

    @State private var showingDetail = false

    public init(item: AgentActivityItem, isLast: Bool = false) {
        self.item = item
        self.isLast = isLast
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 10) {
            statusIcon
                .frame(width: 16, height: 16)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(item.title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(item.status == .failed ? .red : .primary)

                    if item.elapsed > 0.5 {
                        Text(formatDuration(item.elapsed))
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if hasDetails {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.tertiary)
                    }
                }

                if let summary = item.summary, !summary.isEmpty {
                    Text(summary)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                if !item.sources.isEmpty {
                    sourcesPills
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            if hasDetails {
                showingDetail = true
            }
        }
        .sheet(isPresented: $showingDetail) {
            AgentActivityItemDetailView(item: item)
        }
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch item.status {
        case .pending:
            Circle()
                .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 1.5)
        case .running:
            ProgressView()
                .controlSize(.mini)
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.system(size: 13))
        case .failed:
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.orange)
                .font(.system(size: 13))
        }
    }

    private var hasDetails: Bool {
        !item.sources.isEmpty || item.toolArguments != nil || item.toolResultSummary != nil || item.summary != nil
    }

    @ViewBuilder
    private var sourcesPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(item.sources) { source in
                    HStack(spacing: 4) {
                        Image(systemName: "globe")
                            .font(.system(size: 9))
                        Text(source.domain)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.secondary.opacity(0.12), in: Capsule())
                }
            }
            .padding(.top, 2)
        }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        if seconds < 1.0 {
            return String(format: "%.1fs", seconds)
        } else {
            return String(format: "%.0fs", seconds)
        }
    }
}
#endif
