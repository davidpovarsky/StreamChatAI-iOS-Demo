// Sources/AgentUI/Chat/AgentMessageList.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentMessageList: View {
    @Bindable public var session: AgentUISession

    @Environment(\.agentUIDesignTokens) private var tokens

    public init(session: AgentUISession) {
        self.session = session
    }

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: tokens.messageSpacing) {
                    ForEach(session.messages) { message in
                        AgentMessageRow(
                            message: message,
                            activitySession: session.activitySessions[message.id],
                            onToggleActivity: {
                                if var act = session.activitySessions[message.id] {
                                    act.isExpanded.toggle()
                                    session.activitySessions[message.id] = act
                                }
                            }
                        )
                        .id(message.id.rawValue)
                    }

                    Color.clear
                        .frame(height: 1)
                        .id("bottom-anchor")
                }
                .padding(.vertical, 12)
            }
            .onChange(of: session.messages.count) { _, _ in
                withAnimation(.easeOut(duration: 0.25)) {
                    proxy.scrollTo("bottom-anchor", anchor: .bottom)
                }
            }
        }
    }
}
#endif
