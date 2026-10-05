// Sources/AgentUI/Composer/AgentComposerView.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentComposerView: View {
    @Bindable public var session: AgentUISession
    public var actions: AgentComposerActions

    @Environment(\.agentUITheme) private var theme
    @Environment(\.agentUIDesignTokens) private var tokens
    @FocusState private var isFocused: Bool

    public init(
        session: AgentUISession,
        actions: AgentComposerActions? = nil
    ) {
        self.session = session
        self.actions = actions ?? AgentComposerActions(
            onSend: { [session] text, attachments in
                session.send(prompt: text, attachments: attachments)
            },
            onStop: { [session] in
                session.stopStreaming()
            },
            onSelectModel: { [session] model in
                session.selectedModel = model
            },
            onToggleWebSearch: { [session] in
                session.isWebSearchEnabled.toggle()
            }
        )
    }

    public var body: some View {
        VStack(spacing: 8) {
            // Selected Model bar / attachments preview if any
            if !session.currentDraft.attachments.isEmpty {
                attachmentPreviewBar
            }

            HStack(alignment: .bottom, spacing: 8) {
                AgentAttachmentMenu(
                    isWebSearchEnabled: session.isWebSearchEnabled,
                    onToggleWebSearch: actions.onToggleWebSearch,
                    onAttachPhoto: {},
                    onAttachFile: {}
                )

                // Multiline text input
                TextField("Message Agent...", text: $session.currentDraft.text, axis: .vertical)
                    .lineLimit(1...5)
                    .focused($isFocused)
                    .font(.body)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.clear)

                // Trailing actions (Mic, Send / Stop)
                trailingActionButtons
            }

            // Bottom bar with Model Selector
            HStack {
                AgentModelMenu(
                    models: session.availableModels,
                    selectedModel: session.selectedModel,
                    isDisabled: session.isStreaming,
                    onSelect: actions.onSelectModel
                )

                Spacer()

                if session.isWebSearchEnabled {
                    HStack(spacing: 4) {
                        Image(systemName: "globe")
                            .font(.system(size: 10))
                        Text("Web")
                            .font(.caption2.weight(.medium))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(theme.surfaceBackground)
                    .clipShape(Capsule())
                    .foregroundStyle(theme.secondaryText)
                }
            }
            .padding(.top, 2)
        }
        .padding(.horizontal, tokens.composerPaddingHorizontal)
        .padding(.vertical, tokens.composerPaddingVertical)
        .agentGlassEffect(cornerRadius: tokens.composerCornerRadius)
        .padding(.horizontal, 12)
        .padding(.bottom, 6)
    }

    @ViewBuilder
    private var trailingActionButtons: some View {
        if session.isStreaming {
            Button(action: actions.onStop) {
                Image(systemName: "stop.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.red)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Stop generating")
        } else {
            let canSend = !session.currentDraft.isEmpty
            Button {
                let prompt = session.currentDraft.text
                let attachments = session.currentDraft.attachments
                actions.onSend(prompt, attachments)
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(canSend ? .white : theme.tertiaryText)
                    .frame(width: 32, height: 32)
                    .background(canSend ? theme.accentColor : theme.surfaceBackground)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(!canSend)
            .accessibilityLabel("Send message")
        }
    }

    private var attachmentPreviewBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(session.currentDraft.attachments) { att in
                    HStack(spacing: 4) {
                        Image(systemName: att.isImage ? "photo" : "doc")
                            .font(.caption)
                        Text(att.filename)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(theme.surfaceBackground)
                    .clipShape(Capsule())
                }
            }
        }
    }
}
#endif
