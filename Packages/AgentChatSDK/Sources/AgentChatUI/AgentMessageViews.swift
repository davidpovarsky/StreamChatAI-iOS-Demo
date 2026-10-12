import SwiftUI
import AgentChatCore
import AgentChatMarkdown
import AgentChatActivity
import AgentChatToolPresentation
import AgentChatResultCards
import AgentChatMotion

// MARK: - Message Action Bar

public struct AgentMessageActionBarView: View {
    public let messageText: String
    public let onRetry: () -> Void
    public let onSpeak: () -> Void
    @State private var isCopied = false

    public init(messageText: String, onRetry: @escaping () -> Void, onSpeak: @escaping () -> Void) {
        self.messageText = messageText
        self.onRetry = onRetry
        self.onSpeak = onSpeak
    }

    public var body: some View {
        HStack(spacing: 12) {
            Button {
                #if canImport(UIKit)
                UIPasteboard.general.string = messageText
                #endif
                isCopied = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { isCopied = false }
            } label: {
                Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Copy response")

            Button(action: onSpeak) {
                Image(systemName: "speaker.wave.2")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Read aloud")

            Button(action: onRetry) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Regenerate response")

            Spacer()
        }
        .padding(.top, 4)
    }
}

// MARK: - User Message View

public struct AgentUserMessageView: View {
    public let message: ChatMessage
    public let maxWidth: CGFloat

    public init(message: ChatMessage, maxWidth: CGFloat = 760) {
        self.message = message
        self.maxWidth = maxWidth
    }

    public var body: some View {
        HStack {
            Spacer(minLength: 40)

            VStack(alignment: .trailing, spacing: 6) {
                if !message.attachments.isEmpty {
                    VStack(alignment: .trailing, spacing: 4) {
                        ForEach(message.attachments) { att in
                            HStack(spacing: 4) {
                                Image(systemName: "paperclip")
                                    .font(.system(size: 10))
                                Text(att.filename)
                                    .font(.system(size: 11))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.secondary.opacity(0.12)))
                        }
                    }
                }

                Text(message.plainTextContent)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.secondary.opacity(0.12))
                    )
            }
            .frame(maxWidth: min(maxWidth, 560), alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .agentMessageEntrance()
    }
}

// MARK: - Assistant Message View

public struct AgentAssistantMessageView: View {
    public let message: ChatMessage
    public let runs: [RunID: AgentRun]
    public let onToggleRun: (RunID) -> Void
    public let onToggleGroup: (RunID, ActivityGroupID) -> Void
    public let onToggleOperation: (RunID, OperationID) -> Void
    public let onSelectInspector: (ActivityOperation) -> Void
    public let onAction: (AgentChatUserAction) -> Void
    public let onRetry: () -> Void

    public init(
        message: ChatMessage,
        runs: [RunID: AgentRun],
        onToggleRun: @escaping (RunID) -> Void,
        onToggleGroup: @escaping (RunID, ActivityGroupID) -> Void,
        onToggleOperation: @escaping (RunID, OperationID) -> Void,
        onSelectInspector: @escaping (ActivityOperation) -> Void,
        onAction: @escaping (AgentChatUserAction) -> Void,
        onRetry: @escaping () -> Void
    ) {
        self.message = message
        self.runs = runs
        self.onToggleRun = onToggleRun
        self.onToggleGroup = onToggleGroup
        self.onToggleOperation = onToggleOperation
        self.onSelectInspector = onSelectInspector
        self.onAction = onAction
        self.onRetry = onRetry
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                // Associated Hierarchical Activity Runs
                ForEach(message.runIds, id: \.self) { runId in
                    if let run = runs[runId] {
                        // 1. Activity Tree (Collapsed by default!)
                        AgentHierarchicalActivityView(
                            run: run,
                            onToggleRun: { onToggleRun(runId) },
                            onToggleGroup: { gId in onToggleGroup(runId, gId) },
                            onToggleOperation: { opId in onToggleOperation(runId, opId) },
                            onSelectInspector: onSelectInspector
                        )

                        // 2. Action-Required Approvals (Visible outside collapsed activity!)
                        ForEach(run.approvals) { app in
                            AgentApprovalRequestCard(approval: app, onAction: onAction)
                        }
                    }
                }

                // Ordered message segments (Markdown prose + Result cards)
                ForEach(message.segments) { segment in
                    switch segment.kind {
                    case .markdown(let text):
                        AgentChatMarkdownView(
                            content: text,
                            isStreaming: message.isStreaming
                        )
                    case .result(let result):
                        AgentResultRendererRegistry.shared.view(for: result, onAction: onAction)
                    }
                }

                // Thinking / Streaming Indicator
                if message.isStreaming && message.segments.isEmpty {
                    AgentThinkingIndicator()
                }

                // Error View if present
                if let err = message.error {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                        Text(err.message)
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                        Spacer()
                        if err.isRetryable {
                            Button("Retry", action: onRetry)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.red.opacity(0.08)))
                }

                // Action Bar (When message has finished or has content)
                if !message.segments.isEmpty && !message.isStreaming {
                    AgentMessageActionBarView(
                        messageText: message.plainTextContent,
                        onRetry: onRetry,
                        onSpeak: {}
                    )
                }
            }
            .frame(maxWidth: 760, alignment: .leading)

            Spacer(minLength: 20)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .agentMessageEntrance()
    }
}

// MARK: - Row Dispatcher

public struct AgentMessageRowView: View {
    public let message: ChatMessage
    public let runs: [RunID: AgentRun]
    public let onToggleRun: (RunID) -> Void
    public let onToggleGroup: (RunID, ActivityGroupID) -> Void
    public let onToggleOperation: (RunID, OperationID) -> Void
    public let onSelectInspector: (ActivityOperation) -> Void
    public let onAction: (AgentChatUserAction) -> Void
    public let onRetry: () -> Void

    public init(
        message: ChatMessage,
        runs: [RunID: AgentRun],
        onToggleRun: @escaping (RunID) -> Void,
        onToggleGroup: @escaping (RunID, ActivityGroupID) -> Void,
        onToggleOperation: @escaping (RunID, OperationID) -> Void,
        onSelectInspector: @escaping (ActivityOperation) -> Void,
        onAction: @escaping (AgentChatUserAction) -> Void,
        onRetry: @escaping () -> Void
    ) {
        self.message = message
        self.runs = runs
        self.onToggleRun = onToggleRun
        self.onToggleGroup = onToggleGroup
        self.onToggleOperation = onToggleOperation
        self.onSelectInspector = onSelectInspector
        self.onAction = onAction
        self.onRetry = onRetry
    }

    public var body: some View {
        switch message.role {
        case .user:
            AgentUserMessageView(message: message)
        case .assistant:
            AgentAssistantMessageView(
                message: message,
                runs: runs,
                onToggleRun: onToggleRun,
                onToggleGroup: onToggleGroup,
                onToggleOperation: onToggleOperation,
                onSelectInspector: onSelectInspector,
                onAction: onAction,
                onRetry: onRetry
            )
        case .system:
            HStack {
                Spacer()
                Text(message.plainTextContent)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }
}
