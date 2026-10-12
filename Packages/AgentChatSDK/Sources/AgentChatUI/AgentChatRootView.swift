import SwiftUI
import AgentChatCore
import AgentChatComposer
import AgentChatMotion

public struct AgentChatRootView: View {
    @ObservedObject public var session: AgentChatSession
    public var configuration: AgentChatConfiguration
    public var onAction: ((AgentChatUserAction) -> Void)?

    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic

    public init(
        session: AgentChatSession,
        configuration: AgentChatConfiguration = AgentChatConfiguration(),
        onAction: ((AgentChatUserAction) -> Void)? = nil
    ) {
        self.session = session
        self.configuration = configuration
        self.onAction = onAction
    }

    private func handleAction(_ action: AgentChatUserAction) {
        session.handleUserAction(action)
        onAction?(action)
    }

    public var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            AgentConversationSidebarView(
                conversations: $session.conversations,
                selectedConversationId: $session.selectedConversationId,
                onNewConversation: { session.newConversation() },
                onDeleteConversation: { id in session.deleteConversation(id: id) }
            )
        } detail: {
            VStack(spacing: 0) {
                // Top Header
                AgentConversationHeaderView(
                    title: session.currentConversation.title,
                    selectedModel: $session.selectedModel,
                    availableModels: session.configuration.availableModels,
                    onNewChat: { session.newConversation() },
                    onClearChat: { session.clearMessages() }
                )

                Divider()

                // Center Transcript
                AgentTranscriptView(
                    messages: session.messages,
                    runs: session.runs,
                    onToggleRun: { runId in session.toggleRunExpansion(runId: runId) },
                    onToggleGroup: { runId, gId in session.toggleGroupExpansion(runId: runId, groupId: gId) },
                    onToggleOperation: { runId, opId in session.toggleOperationExpansion(runId: runId, operationId: opId) },
                    onAction: { action in handleAction(action) },
                    onRetryMessage: { _ in
                        if let last = session.messages.last(where: { $0.role == .user }) {
                            session.sendMessage(last.plainTextContent, attachments: last.attachments)
                        }
                    },
                    onSelectPrompt: { prompt in
                        session.sendMessage(prompt)
                    }
                )

                // Bottom Composer
                AgentComposerView(
                    text: $session.draftText,
                    attachments: $session.attachments,
                    isStreaming: session.isStreaming,
                    availableModels: session.configuration.availableModels,
                    selectedModel: $session.selectedModel,
                    onSend: { text, atts, model in
                        session.sendMessage(text, attachments: atts, model: model)
                    },
                    onStop: {
                        session.cancel()
                    }
                )
            }
            .background(Color(uiColor: .systemBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
