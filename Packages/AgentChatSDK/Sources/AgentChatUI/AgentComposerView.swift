#if canImport(SwiftUI)
import AgentChatCore
import AgentChatVoice
import SwiftUI

public struct AgentComposerView: View {
    @Binding public var text: String
    public let isGenerating: Bool
    public var configuration: AgentComposerConfiguration
    public let onSend: (String, [AgentAttachment]) -> Void
    public let onStop: () -> Void
    public var onVoiceTap: (() -> Void)?

    @State private var showingEmojiPicker = false
    @State private var showingAttachmentSheet = false
    @State private var selectedModel: AgentModelItem?
    @FocusState private var isFocused: Bool

    public init(
        text: Binding<String>,
        isGenerating: Bool,
        configuration: AgentComposerConfiguration = AgentComposerConfiguration(),
        onSend: @escaping (String, [AgentAttachment]) -> Void,
        onStop: @escaping () -> Void,
        onVoiceTap: (() -> Void)? = nil
    ) {
        self._text = text
        self.isGenerating = isGenerating
        self.configuration = configuration
        self.onSend = onSend
        self.onStop = onStop
        self.onVoiceTap = onVoiceTap
        self._selectedModel = State(initialValue: configuration.selectedModel)
    }

    public var body: some View {
        VStack(spacing: 8) {
            if !configuration.availableModels.isEmpty {
                HStack {
                    AgentSelectedModelMenu(
                        selectedModel: $selectedModel,
                        availableModels: configuration.availableModels,
                        isDisabled: isGenerating
                    )
                    Spacer()
                }
                .padding(.horizontal, 14)
            }

            HStack(alignment: .bottom, spacing: 8) {
                if configuration.allowAttachments {
                    Button {
                        showingAttachmentSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .disabled(isGenerating)
                    .accessibilityLabel("Add attachment")
                }

                if configuration.allowEmojiPicker {
                    Button {
                        showingEmojiPicker = true
                    } label: {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 22))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .disabled(isGenerating)
                    .accessibilityLabel("Pick emoji")
                }

                // Text field
                TextField(configuration.placeholder, text: $text, axis: .vertical)
                    .lineLimit(1...configuration.maxLines)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 20))
                    .focused($isFocused)

                // Voice or Send / Stop button
                if isGenerating {
                    Button {
                        onStop()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.primary)
                                .frame(width: 34, height: 34)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(UIColor.systemBackground))
                                .frame(width: 12, height: 12)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Stop generation")
                } else if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && configuration.allowVoiceInput {
                    Button {
                        onVoiceTap?()
                    } label: {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.primary)
                            .frame(width: 34, height: 34)
                            .background(Color.secondary.opacity(0.12), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Voice input")
                } else {
                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 34))
                            .foregroundStyle(canSend ? Color.blue : Color.secondary.opacity(0.3))
                    }
                    .buttonStyle(.plain)
                    .disabled(!canSend)
                    .accessibilityLabel("Send message")
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 6)
        }
        .sheet(isPresented: $showingEmojiPicker) {
            AgentEmojiPicker { emoji in
                text.append(emoji)
            }
        }
        .confirmationDialog("Add Attachment", isPresented: $showingAttachmentSheet, titleVisibility: .visible) {
            Button("Photo Library") {
                // Photo library attachment entry
            }
            Button("Take Photo") {
                // Camera capture entry
            }
            Button("Choose File") {
                // Document picker entry
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isGenerating
    }

    private func sendMessage() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onSend(trimmed, [])
        text = ""
    }
}
#endif
