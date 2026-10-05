// Sources/AgentUI/Chat/AgentMessageRow.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentMessageRow: View {
    public let message: AgentMessage
    public var activitySession: AgentActivitySession?
    public var onToggleActivity: (() -> Void)?

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
        switch message.role {
        case .user:
            AgentUserMessageView(message: message)
        case .assistant:
            AgentAssistantMessageView(
                message: message,
                activitySession: activitySession,
                onToggleActivity: onToggleActivity
            )
        case .system:
            HStack {
                Spacer()
                Text(message.textContent)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Capsule())
                Spacer()
            }
        }
    }
}
#endif
