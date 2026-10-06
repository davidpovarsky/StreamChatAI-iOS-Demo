import SwiftUI
@_exported import AgentUI

extension ChatViewModel: AgentComposerDriving {
    public var isConversationEmpty: Bool {
        currentChat?.messages.isEmpty ?? true
    }

    public var currentModelDescriptor: AgentModelDescriptor {
        AgentModelDescriptor(
            id: currentModel.id,
            displayName: currentModel.displayName,
            fullName: currentModel.fullName,
            iconName: currentModel.iconName,
            isMultimodal: currentModel.isMultimodal
        )
    }

    public var availableModels: [AgentModelDescriptor] {
        AppConfig.shared.filteredModelTypes().map {
            AgentModelDescriptor(
                id: $0.id,
                displayName: $0.displayName,
                fullName: $0.fullName,
                iconName: $0.iconName,
                isMultimodal: $0.isMultimodal
            )
        }
    }

    public func selectModel(_ model: AgentModelDescriptor) {
        if let target = AppConfig.shared.filteredModelTypes().first(where: { $0.id == model.id }) {
            changeModel(to: target)
        }
    }

    public var isAudioRecording: Bool {
        AudioRecordingService.shared.isRecording
    }

    public var isAudioTranscribing: Bool {
        AudioRecordingService.shared.isTranscribing
    }

    public var composerPendingAttachments: [AgentUI.Attachment] {
        pendingAttachments.map { att in
            AgentUI.Attachment(
                id: att.id,
                type: att.type == .image ? .image : .document,
                fileName: att.fileName,
                mimeType: att.mimeType,
                base64: att.base64,
                thumbnailBase64: att.thumbnailBase64,
                textContent: att.textContent,
                description: att.description,
                fileSize: att.fileSize,
                encryptionKey: att.encryptionKey,
                processingState: att.processingState == .completed ? .completed : (att.processingState == .processing ? .processing : (att.processingState == .failed ? .failed : .pending))
            )
        }
    }

    public func toggleAudioRecording() {
        // Fallback for parameterless toggle
    }

    public func toggleAudioRecording(text: Binding<String>) {
        let audioService = AudioRecordingService.shared
        if audioService.isRecording {
            guard let fileURL = audioService.stopRecording() else { return }
            Task {
                do {
                    let client = AppConfig.shared.makeClient()
                    let transcribed = try await audioService.transcribe(fileURL: fileURL, client: client)
                    text.wrappedValue += (text.wrappedValue.isEmpty ? "" : " ") + transcribed
                } catch {
                    self.attachmentError = error.localizedDescription
                }
            }
        } else {
            Task {
                let granted = await audioService.requestPermission()
                guard granted else {
                    self.attachmentError = "Microphone access is required for voice input. Enable it in Settings."
                    return
                }
                do {
                    try audioService.startRecording()
                } catch {
                    self.attachmentError = "Failed to start recording: \(error.localizedDescription)"
                }
            }
        }
    }
}
