#if canImport(SwiftUI)
import AgentChatCore
import SwiftUI

public struct AgentActivityTimelineView: View {
    public let session: AgentActivitySession
    public let onToggleExpand: (() -> Void)?

    @State private var isExpanded: Bool

    public init(session: AgentActivitySession, onToggleExpand: (() -> Void)? = nil) {
        self.session = session
        self.onToggleExpand = onToggleExpand
        self._isExpanded = State(initialValue: session.isExpanded)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
                onToggleExpand?()
            } label: {
                HStack(spacing: 8) {
                    headerIcon
                        .frame(width: 14, height: 14)

                    Text(summaryTitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.primary)

                    if session.elapsed > 0.5 {
                        Text(formatDuration(session.elapsed))
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    Divider()
                        .padding(.vertical, 2)

                    ForEach(Array(session.items.enumerated()), id: \.element.id) { index, item in
                        AgentActivityRowView(
                            item: item,
                            isLast: index == session.items.count - 1
                        )
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Agent process timeline: \(summaryTitle)")
        .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
    }

    @ViewBuilder
    private var headerIcon: some View {
        if isRunning {
            ProgressView()
                .controlSize(.mini)
        } else {
            Image(systemName: "sparkles")
                .foregroundStyle(.blue)
                .font(.system(size: 12))
        }
    }

    private var isRunning: Bool {
        session.completedAt == nil && session.items.contains { $0.status == .running }
    }

    private var summaryTitle: String {
        if isRunning {
            if let activeItem = session.items.last(where: { $0.status == .running }) {
                return activeItem.title
            }
            return "Thinking..."
        }
        let completedCount = session.items.filter { $0.status == .completed }.count
        if completedCount > 0 {
            return "Finished in \(formatDuration(session.elapsed)) (\(completedCount) steps)"
        }
        return "Process completed"
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
