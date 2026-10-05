// Sources/AgentUI/Chat/AgentChatShell.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentChatShell: View {
    @Bindable public var session: AgentUISession
    public var title: String?

    public init(session: AgentUISession, title: String? = nil) {
        self.session = session
        self.title = title
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header if custom title provided
            if let title {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }

            // Message list
            AgentMessageList(session: session)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Bottom floating composer
            AgentComposerView(session: session)
        }
    }
}
#endif
