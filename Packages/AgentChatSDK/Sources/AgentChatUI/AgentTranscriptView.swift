import SwiftUI
import AgentChatCore
import AgentChatToolPresentation

public struct AgentTranscriptView: View {
    public let messages: [ChatMessage]
    public let runs: [RunID: AgentRun]
    public let onToggleRun: (RunID) -> Void
    public let onToggleGroup: (RunID, ActivityGroupID) -> Void
    public let onToggleOperation: (RunID, OperationID) -> Void
    public let onAction: (AgentChatUserAction) -> Void
    public let onRetryMessage: (MessageID) -> Void
    public let onSelectPrompt: (String) -> Void

    @State private var inspectedOperation: ActivityOperation? = nil
    @State private var isShowingInspector = false
    @State private var scrolledAwayFromBottom = false

    public init(
        messages: [ChatMessage],
        runs: [RunID: AgentRun],
        onToggleRun: @escaping (RunID) -> Void,
        onToggleGroup: @escaping (RunID, ActivityGroupID) -> Void,
        onToggleOperation: @escaping (RunID, OperationID) -> Void,
        onAction: @escaping (AgentChatUserAction) -> Void,
        onRetryMessage: @escaping (MessageID) -> Void,
        onSelectPrompt: @escaping (String) -> Void
    ) {
        self.messages = messages
        self.runs = runs
        self.onToggleRun = onToggleRun
        self.onToggleGroup = onToggleGroup
        self.onToggleOperation = onToggleOperation
        self.onAction = onAction
        self.onRetryMessage = onRetryMessage
        self.onSelectPrompt = onSelectPrompt
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if messages.isEmpty {
                AgentTranscriptEmptyView(onSelectPrompt: onSelectPrompt)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(messages) { msg in
                                AgentMessageRowView(
                                    message: msg,
                                    runs: runs,
                                    onToggleRun: onToggleRun,
                                    onToggleGroup: onToggleGroup,
                                    onToggleOperation: onToggleOperation,
                                    onSelectInspector: { op in
                                        inspectedOperation = op
                                        isShowingInspector = true
                                    },
                                    onAction: onAction,
                                    onRetry: { onRetryMessage(msg.id) }
                                )
                                .id(msg.id)
                            }

                            // Invisible anchor at the bottom
                            Color.clear
                                .frame(height: 1)
                                .id("bottom-anchor")
                        }
                        .padding(.vertical, 8)
                    }
                    .onChange(of: messages.count) { _, _ in
                        if !scrolledAwayFromBottom {
                            withAnimation(.easeOut(duration: 0.2)) {
                                proxy.scrollTo("bottom-anchor", anchor: .bottom)
                            }
                        }
                    }
                    .overlay(alignment: .bottom) {
                        if scrolledAwayFromBottom {
                            AgentScrollToBottomButton(count: 0) {
                                scrolledAwayFromBottom = false
                                withAnimation {
                                    proxy.scrollTo("bottom-anchor", anchor: .bottom)
                                }
                            }
                            .padding(.bottom, 12)
                        }
                    }
                }
            }
        }
        .sheet(item: $inspectedOperation) { op in
            AgentToolInspectorView(operation: op)
        }
    }
}
