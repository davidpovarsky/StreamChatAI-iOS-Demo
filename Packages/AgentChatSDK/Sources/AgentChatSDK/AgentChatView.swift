#if canImport(SwiftUI)
import SwiftUI
import AgentChatCore
import AgentChatUI

/// Public front door for the 100% native SwiftUI AgentChat experience.
/// Renders the complete native SwiftUI chat root with navigation split view,
/// hierarchical activity disclosures (collapsed by default), rich interactive result cards,
/// and responsive multiline composer.
@MainActor
public struct AgentChatView: View {
    @ObservedObject public var session: AgentChatSession
    public var configuration: AgentChatConfiguration
    public var onAction: ((AgentChatUserAction) -> Void)?

    public init(
        session: AgentChatSession,
        configuration: AgentChatConfiguration = AgentChatConfiguration(),
        onAction: ((AgentChatUserAction) -> Void)? = nil
    ) {
        self.session = session
        self.configuration = configuration
        self.onAction = onAction
    }

    public var body: some View {
        AgentChatRootView(
            session: session,
            configuration: configuration,
            onAction: onAction
        )
    }
}
#endif
