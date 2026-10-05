//
//  AgentComposerView.swift
//  AgentUI
//
//  Extracted existing composer implementation with full visual and geometric parity.
//

import SwiftUI
import UIKit
import PhotosUI

public struct AgentComposerView<Driver: AgentComposerDriving>: View {
    fileprivate enum Layout {
        static let defaultHeight: CGFloat = 72
        static let minimumHeight: CGFloat = 72
        static let maximumHeight: CGFloat = 180
    }

    @Binding public var messageText: String
    @ObservedObject public var driver: Driver
    @Environment(\.colorScheme) private var colorScheme
    @State private var textHeight: CGFloat = Layout.defaultHeight
    public var isKeyboardVisible: Bool = false

    public init(
        messageText: Binding<String>,
        driver: Driver,
        isKeyboardVisible: Bool = false
    ) {
        self._messageText = messageText
        self.driver = driver
        self.isKeyboardVisible = isKeyboardVisible
    }

    private var isDarkMode: Bool { colorScheme == .dark }

    @State private var showDocumentPicker = false
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []

    private var showAttachmentError: Binding<Bool> {
        Binding(
            get: { driver.attachmentError != nil },
            set: { if !$0 { driver.attachmentError = nil } }
        )
    }

    @ViewBuilder
    public var body: some View {
        inputContent
            .alert("Attachment Error", isPresented: showAttachmentError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(driver.attachmentError ?? "An error occurred")
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPickerView { url, fileName in
                    driver.addDocumentAttachment(url: url, fileName: fileName)
                }
            }
            .sheet(isPresented: $showPhotoPicker, onDismiss: processSelectedPhotos) {
                NavigationStack {
                    PhotosPicker(selection: $selectedPhotoItems, matching: .images) {
                        Text("Select Photos")
                    }
                    .photosPickerStyle(.inline)
                    .navigationTitle("Select Photos")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { showPhotoPicker = false }
                        }
                    }
                }
                .presentationDetents([.medium, .large])
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPickerView { image in
                    if let data = image.jpegData(compressionQuality: AgentConstants.Attachments.imageCompressionQuality) {
                        driver.addImageAttachment(data: data, fileName: "Camera Photo.jpg")
                    }
                }
                .ignoresSafeArea()
            }
    }

    @ViewBuilder
    private var inputContent: some View {
        if #available(iOS 26, *) {
            VStack(spacing: 4) {
                VStack(spacing: 0) {
                    if !driver.pendingAttachments.isEmpty {
                        AttachmentPreviewBar(
                            attachments: driver.pendingAttachments,
                            thumbnails: driver.pendingImageThumbnails,
                            onRemove: { id in driver.removePendingAttachment(id: id) }
                        )
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                    }

                    CustomTextEditor(
                        text: $messageText,
                        textHeight: $textHeight,
                        placeholderText: driver.isConversationEmpty ? "What's on your mind?" : "Message",
                        shouldFocusInput: driver.shouldFocusInput,
                        isLoading: driver.isLoading,
                        onFocusHandled: { driver.shouldFocusInput = false },
                        onSendMessage: { text in driver.sendMessage(text: text) }
                    )
                    .frame(height: textHeight)
                    .padding(.horizontal)

                    HStack {
                        attachButton
                        AgentSelectedModelMenu(
                            currentModelId: driver.currentModel.id,
                            currentModelDisplayName: driver.currentModel.displayName,
                            availableModels: driver.availableModels,
                            isLoading: driver.isLoading,
                            isDarkMode: isDarkMode,
                            onSelectModel: { driver.selectModel($0) }
                        )
                        Spacer()

                        micButton

                        Button(action: sendOrCancelMessage) {
                            Image(systemName: driver.isLoading ? "stop.fill" : "arrow.up")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(width: 24, height: 24)
                                .foregroundColor(isDarkMode ? Color.agentSendButtonForegroundDark : Color.agentSendButtonForegroundLight)
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.circle)
                        .glassEffect(.regular.interactive(), in: .circle)
                        .clipShape(.circle)
                        .tint(isDarkMode ? Color.agentSendButtonBackgroundDark : Color.agentSendButtonBackgroundLight)
                        .padding(.trailing, 8)
                    }
                    .padding(.vertical, 8)
                }
                .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 26))
            }
            .padding(.horizontal, 12)
            .padding(.bottom, isKeyboardVisible ? 12 : 0)
        } else {
            VStack(spacing: 4) {
                VStack(spacing: 0) {
                    if !driver.pendingAttachments.isEmpty {
                        AttachmentPreviewBar(
                            attachments: driver.pendingAttachments,
                            thumbnails: driver.pendingImageThumbnails,
                            onRemove: { id in driver.removePendingAttachment(id: id) }
                        )
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                    }

                    CustomTextEditor(
                        text: $messageText,
                        textHeight: $textHeight,
                        placeholderText: driver.isConversationEmpty ? "What's on your mind?" : "Message",
                        shouldFocusInput: driver.shouldFocusInput,
                        isLoading: driver.isLoading,
                        onFocusHandled: { driver.shouldFocusInput = false },
                        onSendMessage: { text in driver.sendMessage(text: text) }
                    )
                    .frame(height: textHeight)
                    .padding(.horizontal)

                    HStack {
                        attachButton
                        AgentSelectedModelMenu(
                            currentModelId: driver.currentModel.id,
                            currentModelDisplayName: driver.currentModel.displayName,
                            availableModels: driver.availableModels,
                            isLoading: driver.isLoading,
                            isDarkMode: isDarkMode,
                            onSelectModel: { driver.selectModel($0) }
                        )
                        Spacer()

                        micButton

                        Button(action: sendOrCancelMessage) {
                            ZStack {
                                Circle()
                                    .fill(isDarkMode ? Color.agentSendButtonBackgroundDark : Color.agentSendButtonBackgroundLight)
                                    .frame(width: 32, height: 32)
                                Image(systemName: driver.isLoading ? "stop.fill" : "arrow.up")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(isDarkMode ? Color.agentSendButtonForegroundDark : Color.agentSendButtonForegroundLight)
                            }
                        }
                        .padding(.trailing, 8)
                    }
                    .padding(.vertical, 8)
                }
                .background {
                    RoundedRectangle(cornerRadius: 26)
                        .fill(.thickMaterial)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, isKeyboardVisible ? 12 : 0)
        }
    }

    @ViewBuilder
    private var attachButton: some View {
        if #available(iOS 26, *) {
            Menu {
                if driver.currentModel.isMultimodal {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button {
                            showCamera = true
                        } label: {
                            Label("Camera", systemImage: "camera")
                        }
                    }
                    Button {
                        showPhotoPicker = true
                    } label: {
                        Label("Photos", systemImage: "photo.on.rectangle")
                    }
                }
                Button {
                    showDocumentPicker = true
                } label: {
                    Label("Files", systemImage: "doc.badge.arrow.up")
                }

                Button {
                    driver.isWebSearchEnabled.toggle()
                } label: {
                    Label(
                        driver.isWebSearchEnabled ? "Disable Web Search" : "Enable Web Search",
                        systemImage: driver.isWebSearchEnabled ? "checkmark" : "globe"
                    )
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .clipShape(Circle())
            .disabled(driver.isLoading || driver.isProcessingAttachment)
            .padding(.leading, 8)
        } else {
            Menu {
                if driver.currentModel.isMultimodal {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button {
                            showCamera = true
                        } label: {
                            Label("Camera", systemImage: "camera")
                        }
                    }
                    Button {
                        showPhotoPicker = true
                    } label: {
                        Label("Photos", systemImage: "photo.on.rectangle")
                    }
                }
                Button {
                    showDocumentPicker = true
                } label: {
                    Label("Files", systemImage: "doc.badge.arrow.up")
                }

                Button {
                    driver.isWebSearchEnabled.toggle()
                } label: {
                    Label(
                        driver.isWebSearchEnabled ? "Disable Web Search" : "Enable Web Search",
                        systemImage: driver.isWebSearchEnabled ? "checkmark" : "globe"
                    )
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                    .frame(width: 24, height: 24)
            }
            .disabled(driver.isLoading || driver.isProcessingAttachment)
            .padding(.leading, 8)
        }
    }

    @State private var isPulsing = false

    @ViewBuilder
    private var micButton: some View {
        Button(action: { driver.toggleAudioRecording() }) {
            ZStack {
                if driver.isAudioRecording {
                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 44, height: 44)
                        .scaleEffect(isPulsing ? 1.1 : 0.9)
                        .animation(
                            .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                }

                Group {
                    if driver.isAudioTranscribing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: driver.isAudioRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 20))
                    }
                }
                .frame(width: 32, height: 32)
                .foregroundColor(driver.isAudioRecording ? .red : .secondary)
            }
            .frame(width: 32, height: 32)
        }
        .onChange(of: driver.isAudioRecording) { _, isRecording in
            isPulsing = isRecording
        }
        .disabled(driver.isAudioTranscribing || driver.isLoading)
        .padding(.trailing, 4)
    }

    private func sendOrCancelMessage() {
        if driver.isLoading {
            driver.cancelGeneration()
        } else if !messageText.isEmpty || !driver.pendingAttachments.isEmpty {
            driver.sendMessage(text: messageText)
            messageText = ""
            textHeight = Layout.defaultHeight
        }
    }

    private func processSelectedPhotos() {
        let items = selectedPhotoItems
        selectedPhotoItems = []
        for (index, item) in items.enumerated() {
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    let fileName = items.count > 1 ? "Photo \(index + 1).jpg" : "Photo.jpg"
                    driver.addImageAttachment(data: data, fileName: fileName)
                }
            }
        }
    }
}

public struct CustomTextEditor: UIViewRepresentable {
    @Binding public var text: String
    @Binding public var textHeight: CGFloat
    public var placeholderText: String
    public var shouldFocusInput: Bool
    public var isLoading: Bool
    public var onFocusHandled: () -> Void
    public var onSendMessage: (String) -> Void

    public init(
        text: Binding<String>,
        textHeight: Binding<CGFloat>,
        placeholderText: String,
        shouldFocusInput: Bool,
        isLoading: Bool,
        onFocusHandled: @escaping () -> Void,
        onSendMessage: @escaping (String) -> Void
    ) {
        self._text = text
        self._textHeight = textHeight
        self.placeholderText = placeholderText
        self.shouldFocusInput = shouldFocusInput
        self.isLoading = isLoading
        self.onFocusHandled = onFocusHandled
        self.onSendMessage = onSendMessage
    }

    public func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.alwaysBounceVertical = false
        textView.scrollsToTop = false
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 2, bottom: 8, right: 5)
        textView.textContainer.lineFragmentPadding = 0
        textView.tintColor = UIColor.systemBlue

        if text.isEmpty {
            textView.text = placeholderText
            textView.textColor = .lightGray
        } else {
            textView.text = text
            textView.textColor = UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? .white : .black
            }
        }

        return textView
    }

    public func updateUIView(_ uiView: UITextView, context: Context) {
        context.coordinator.parent = self
        let isCurrentlyEditing = context.coordinator.isEditing

        if shouldFocusInput && !context.coordinator.hasFocusedFromFlag {
            context.coordinator.hasFocusedFromFlag = true
            DispatchQueue.main.async {
                if !uiView.isFirstResponder { uiView.becomeFirstResponder() }
                self.onFocusHandled()
            }
        } else if !shouldFocusInput {
            context.coordinator.hasFocusedFromFlag = false
        }

        if text.isEmpty && !isCurrentlyEditing && uiView.textColor != .lightGray {
            uiView.text = placeholderText
            uiView.textColor = .lightGray
        } else if text.isEmpty && isCurrentlyEditing {
            if uiView.text.isEmpty && uiView.textColor == .lightGray {
                uiView.text = ""
                uiView.textColor = UIColor { tc in tc.userInterfaceStyle == .dark ? .white : .black }
            } else if !uiView.text.isEmpty && uiView.textColor != .lightGray {
                self.text = uiView.text
            }
        } else if !text.isEmpty && uiView.textColor == .lightGray {
            uiView.text = text
            uiView.textColor = UIColor { tc in tc.userInterfaceStyle == .dark ? .white : .black }
        } else if !text.isEmpty && uiView.text != text && uiView.textColor != .lightGray {
            uiView.text = text
        }

        uiView.isEditable = true

        let size = uiView.sizeThatFits(CGSize(width: uiView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        let newHeight = min(180, max(72, size.height))
        if textHeight != newHeight {
            DispatchQueue.main.async { self.textHeight = newHeight }
        }
    }

    public func makeCoordinator() -> Coordinator { Coordinator(self) }

    public class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextEditor
        var isEditing = false
        var hasFocusedFromFlag = false

        init(_ parent: CustomTextEditor) { self.parent = parent }

        public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                let isMac = ProcessInfo.processInfo.isiOSAppOnMac
                if isMac {
                    let currentText = textView.text ?? ""
                    let trimmedText = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmedText.isEmpty && !parent.isLoading {
                        parent.onSendMessage(trimmedText)
                        textView.text = ""
                        parent.text = ""
                        parent.textHeight = 72
                        textView.text = parent.placeholderText
                        textView.textColor = .lightGray
                        textView.resignFirstResponder()
                    }
                    return false
                }
            }

            let currentText = textView.text as NSString
            let _ = currentText.replacingCharacters(in: range, with: text)
            return true
        }

        public func textViewDidChange(_ textView: UITextView) {
            if textView.textColor != .lightGray {
                parent.text = textView.text
                let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
                let newHeight = min(180, max(72, size.height))
                if parent.textHeight != newHeight { parent.textHeight = newHeight }
            }
        }

        public func textViewDidBeginEditing(_ textView: UITextView) {
            isEditing = true
            if textView.textColor == .lightGray {
                textView.text = ""
                textView.textColor = UIColor { tc in tc.userInterfaceStyle == .dark ? .white : .black }
            }
        }

        public func textViewDidEndEditing(_ textView: UITextView) {
            isEditing = false
            if textView.text.isEmpty {
                textView.text = parent.placeholderText
                textView.textColor = .lightGray
            }
        }
    }
}
