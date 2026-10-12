import SwiftUI
#if canImport(PhotosUI)
import PhotosUI
#endif
import AgentChatCore
import AgentChatMotion

public struct AgentComposerView: View {
    @Binding public var text: String
    @Binding public var attachments: [Attachment]
    public let isStreaming: Bool
    public let availableModels: [AgentModel]
    @Binding public var selectedModel: AgentModel
    public let onSend: (String, [Attachment], AgentModel) -> Void
    public let onStop: () -> Void

    @FocusState private var isFocused: Bool
    @State private var showingAddMenu = false
    @State private var showingModelSheet = false
    @State private var isRecordingVoice = false

    public init(
        text: Binding<String>,
        attachments: Binding<[Attachment]>,
        isStreaming: Bool,
        availableModels: [AgentModel] = AgentModel.defaultModels,
        selectedModel: Binding<AgentModel>,
        onSend: @escaping (String, [Attachment], AgentModel) -> Void,
        onStop: @escaping () -> Void
    ) {
        self._text = text
        self._attachments = attachments
        self.isStreaming = isStreaming
        self.availableModels = availableModels
        self._selectedModel = selectedModel
        self.onSend = onSend
        self.onStop = onStop
    }

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !attachments.isEmpty
    }

    public var body: some View {
        VStack(spacing: 8) {
            // Attachments Tray
            if !attachments.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(attachments) { att in
                            HStack(spacing: 6) {
                                Image(systemName: "paperclip")
                                    .font(.system(size: 11))
                                Text(att.filename)
                                    .font(.system(size: 12))
                                    .lineLimit(1)
                                Button {
                                    attachments.removeAll { $0.id == att.id }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(Color.secondary.opacity(0.12))
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }

            // Input Bar
            HStack(alignment: .bottom, spacing: 8) {
                // Add Attachment Menu
                Menu {
                    Button {
                        // Demo attachment
                        let demoAtt = Attachment(
                            id: UUID().uuidString.lowercased(),
                            type: .image,
                            filename: "Sample-Architecture.png"
                        )
                        attachments.append(demoAtt)
                    } label: {
                        Label("Add Demo Image", systemImage: "photo")
                    }

                    Button {
                        let demoDoc = Attachment(
                            id: UUID().uuidString.lowercased(),
                            type: .document,
                            filename: "SystemSpec.pdf"
                        )
                        attachments.append(demoDoc)
                    } label: {
                        Label("Add Demo PDF", systemImage: "doc")
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Color.secondary.opacity(0.1)))
                }
                .buttonStyle(.plain)

                // Multiline Input
                TextField("Message Assistant...", text: $text, axis: .vertical)
                    .lineLimit(1...6)
                    .focused($isFocused)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.secondary.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isFocused ? Color.blue.opacity(0.4) : Color.clear, lineWidth: 1)
                    )

                // Voice Recording or Mock Voice Toggle
                Button {
                    isRecordingVoice.toggle()
                    if isRecordingVoice {
                        text = "Can you analyze the system architecture?"
                        isRecordingVoice = false
                    }
                } label: {
                    Image(systemName: isRecordingVoice ? "waveform" : "mic.fill")
                        .font(.system(size: 16))
                        .foregroundColor(isRecordingVoice ? .red : .secondary)
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Voice input")

                // Send / Stop Button
                if isStreaming {
                    Button(action: onStop) {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Stop streaming")
                } else {
                    Button {
                        guard canSend else { return }
                        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        let currentAttachments = attachments
                        text = ""
                        attachments = []
                        onSend(trimmed, currentAttachments, selectedModel)
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(canSend ? .blue : .secondary.opacity(0.35))
                    }
                    .buttonStyle(.plain)
                    .disabled(!canSend)
                    .accessibilityLabel("Send message")
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 6, y: 2)
            )

            // Model Selection Indicator
            HStack {
                Menu {
                    ForEach(availableModels) { model in
                        Button {
                            selectedModel = model
                        } label: {
                            HStack {
                                Text(model.name)
                                if model.id == selectedModel.id {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: selectedModel.iconSystemName)
                            .font(.system(size: 10))
                        Text(selectedModel.name)
                            .font(.system(size: 11, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 8))
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule().fill(Color.secondary.opacity(0.08))
                    )
                }

                Spacer()
            }
            .padding(.horizontal, 6)
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
    }
}
