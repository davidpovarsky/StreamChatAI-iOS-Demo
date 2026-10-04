import SwiftUI

struct AgentActivityTimelineBridge: View {
    let messageID: String
    let isDarkMode: Bool
    @ObservedObject private var store = AgentActivityStore.shared

    var body: some View {
        if let session = store.session(for: messageID) {
            AgentActivityTimelineView(session: session, isDarkMode: isDarkMode) {
                store.setExpanded(!session.isExpanded, messageID: messageID)
            }
        }
    }
}

private struct AgentActivityTimelineView: View {
    let session: AgentActivitySession
    let isDarkMode: Bool
    let toggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                Button(action: toggle) {
                    HStack(spacing: 6) {
                        Text(header(at: context.date))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.tertiary)
                            .rotationEffect(.degrees(session.isExpanded ? 90 : 0))
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            if session.isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(session.items) { item in
                        AgentActivityRowView(item: item, isDarkMode: isDarkMode)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func header(at date: Date) -> String {
        let end = session.completedAt ?? date
        let seconds = max(0, Int(end.timeIntervalSince(session.startedAt).rounded()))
        return "\(session.answerStarted || session.completedAt != nil ? "Worked" : "Working") for \(seconds)s"
    }
}
