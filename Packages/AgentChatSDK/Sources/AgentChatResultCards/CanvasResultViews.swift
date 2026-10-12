import SwiftUI
import AgentChatCore

public struct CanvasDocumentResultView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void

    @State private var originalText: String = "The system uses modern SwiftUI architecture for high performance on iPadOS."
    @State private var revisedText: String = "The system uses modern native SwiftUI architecture with hierarchical activity, zero legacy baggage, and responsive iPad Stage Manager multitasking."
    @State private var isAccepted = false
    @State private var isRejected = false

    public init(result: AgentResult, onAction: @escaping (AgentChatUserAction) -> Void) {
        self.result = result
        self.onAction = onAction
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.purple)
                Text(result.title ?? "Document Revision: Architecture Spec")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Text("Canvas")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.secondary.opacity(0.12)))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Original Paragraph:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(originalText)
                    .font(.system(size: 13))
                    .strikethrough(isAccepted, color: .red)
                    .foregroundColor(isAccepted ? .secondary : .primary)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.red.opacity(0.08))
                    )

                Text("Proposed Revision:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(revisedText)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.green.opacity(0.08))
                    )
            }

            HStack {
                if !isAccepted && !isRejected {
                    Button {
                        isAccepted = true
                        let action = AgentChatUserAction(
                            kind: .select(option: "accept-revision"),
                            context: AgentResultActionContext(
                                conversationId: "demo",
                                messageId: result.messageId,
                                resultId: result.id
                            )
                        )
                        onAction(action)
                    } label: {
                        Label("Accept Change", systemImage: "checkmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(RoundedRectangle(cornerRadius: 6).fill(Color.green))
                    }
                    .buttonStyle(.plain)

                    Button {
                        isRejected = true
                        let action = AgentChatUserAction(
                            kind: .select(option: "reject-revision"),
                            context: AgentResultActionContext(
                                conversationId: "demo",
                                messageId: result.messageId,
                                resultId: result.id
                            )
                        )
                        onAction(action)
                    } label: {
                        Label("Reject", systemImage: "xmark")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(RoundedRectangle(cornerRadius: 6).fill(Color.secondary.opacity(0.12)))
                    }
                    .buttonStyle(.plain)
                } else {
                    Text(isAccepted ? "✓ Revision Accepted" : "✕ Revision Rejected")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isAccepted ? .green : .red)
                }

                Spacer()
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.secondary.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
        )
    }
}

public struct CanvasCodeResultView: View {
    public let result: AgentResult
    public let onAction: (AgentChatUserAction) -> Void

    @State private var isCopied = false

    public init(result: AgentResult, onAction: @escaping (AgentChatUserAction) -> Void) {
        self.result = result
        self.onAction = onAction
    }

    private var codeSnippet: String {
        result.payload.contentText ?? """
        @MainActor
        public struct AgentChatView: View {
            public let session: AgentChatSession
            public var body: some View {
                AgentChatRootView(session: session)
            }
        }
        """
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .foregroundColor(.blue)
                Text(result.title ?? "Swift Snippet")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Text(result.payload.language ?? "Swift")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)

                Button {
                    #if canImport(UIKit)
                    UIPasteboard.general.string = codeSnippet
                    #endif
                    isCopied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isCopied = false
                    }
                } label: {
                    Label(isCopied ? "Copied" : "Copy", systemImage: isCopied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 11))
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                Text(codeSnippet)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.primary)
                    .padding(10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.08))
            )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.secondary.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
        )
    }
}
