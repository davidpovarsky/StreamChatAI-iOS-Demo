// Sources/AgentUI/Activity/AgentActivityDurationView.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentActivityDurationView: View {
    public let session: AgentActivitySession

    @Environment(\.agentUITheme) private var theme

    public init(session: AgentActivitySession) {
        self.session = session
    }

    public var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let isDone = session.completedAt != nil || session.answerStarted
            let end = session.completedAt ?? context.date
            let seconds = max(0, Int(end.timeIntervalSince(session.startedAt).rounded()))
            let label = isDone ? "Worked for \(seconds)s" : "Working for \(seconds)s"

            HStack(spacing: 6) {
                if !isDone {
                    ProgressView()
                        .controlSize(.mini)
                }

                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(theme.secondaryText)
            }
        }
    }
}
#endif
