#if canImport(SwiftUI)
import SwiftUI
import AgentChatCore
import AgentChatSwiftChat

/// Public front door for the SwiftChat-derived AgentChat experience.
/// Renders the complete, packaged SwiftChat chat container with navigation, sidebar,
/// reasoning disclosure, inline sources, rich media, and tool presentations.
public struct AgentChatView: View {
    @ObservedObject public var session: AgentChatSession
    public var configuration: AgentChatConfiguration

    public init(
        session: AgentChatSession,
        configuration: AgentChatConfiguration = AgentChatConfiguration()
    ) {
        self.session = session
        self.configuration = configuration
    }

    public var body: some View {
        ChatContainer()
            .environmentObject(session.viewModel)
            .environmentObject(session)
    }
}
#endif
