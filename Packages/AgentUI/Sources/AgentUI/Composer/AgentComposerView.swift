//
//  AgentComposerView.swift
//  AgentUI
//
//  Extracted existing composer implementation with full visual and geometric parity.
//

import SwiftUI
import UIKit
import PhotosUI

fileprivate enum AgentComposerLayout {
    static let defaultHeight: CGFloat = 72
    static let minimumHeight: CGFloat = 72
    static let maximumHeight: CGFloat = 180
}

public struct AgentComposerView<Driver: AgentComposerDriving>: View {
    @Binding public var messageText: String
    @ObservedObject public var driver: Driver
    @Environment(\.colorScheme) private var colorScheme
    @State private var textHeight: CGFloat = AgentComposerLayout.defaultHeight
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
                            currentModelId: driver.currentModelDescriptor.id,
                            currentModelDisplayName: driver.currentModelDescriptor.displayName,
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
                                .foregroundColor(isDarkMode ? Color.sendButtonForegroundDark : Color.sendButtonForegroundLight)
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.circle)
                        .glassEffect(.regular.interactive(), in: .circle)
                        .clipShape(.circle)
                        .tint(isDarkMode ? Color.sendButtonBackgroundDark : Color.sendButtonBackgroundLight)
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
                            currentModelId: driver.currentModelDescriptor.id,
                            currentModelDisplayName: driver.currentModelDescriptor.displayName,
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
                                    .fill(isDarkMode ? Color.sendButtonBackgroundDark : Color.sendButtonBackgroundLight)
                                    .frame(width: 32, height: 32)
                                Image(systemName: driver.isLoading ? "stop.fill" : "arrow.up")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(isDarkMode ? Color.sendButtonForegroundDark : Color.sendButtonForegroundLight)
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
                if driver.currentModelDescriptor.isMultimodal {
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
                if driver.currentModelDescriptor.isMultimodal {
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
        Button(action: { driver.toggleAudioRecording(text: $messageText) }) {
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
            textHeight = AgentComposerLayout.defaultHeight
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
        let newHeight = min(AgentComposerLayout.maximumHeight, max(AgentComposerLayout.minimumHeight, size.height))
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
                        parent.textHeight = AgentComposerLayout.defaultHeight
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
                let newHeight = min(AgentComposerLayout.maximumHeight, max(AgentComposerLayout.minimumHeight, size.height))
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

/// Bottom sheet presented from the "+" button with attachment options and model selector
public struct AddToSheetView: View {
    public let availableModels: [AgentModelDescriptor]
    public let currentModelId: String
    public let isMultimodal: Bool
    public let isDarkMode: Bool
    public let onCamera: () -> Void
    public let onPhotos: () -> Void
    public let onFiles: () -> Void
    public let onSelectModel: (AgentModelDescriptor) -> Void
    @Environment(\.dismiss) private var dismiss

    public init(
        availableModels: [AgentModelDescriptor],
        currentModelId: String,
        isMultimodal: Bool,
        isDarkMode: Bool,
        onCamera: @escaping () -> Void,
        onPhotos: @escaping () -> Void,
        onFiles: @escaping () -> Void,
        onSelectModel: @escaping (AgentModelDescriptor) -> Void
    ) {
        self.availableModels = availableModels
        self.currentModelId = currentModelId
        self.isMultimodal = isMultimodal
        self.isDarkMode = isDarkMode
        self.onCamera = onCamera
        self.onPhotos = onPhotos
        self.onFiles = onFiles
        self.onSelectModel = onSelectModel
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Attachment buttons
                HStack(spacing: 12) {
                    if isMultimodal {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            attachmentButton(icon: "camera", label: "Camera") { onCamera() }
                        }
                        attachmentButton(icon: "photo.on.rectangle", label: "Photos") { onPhotos() }
                    }
                    attachmentButton(icon: "doc.badge.arrow.up", label: "Files") { onFiles() }
                }
                .padding(.horizontal, 20)

                Divider()
                    .padding(.horizontal, 20)

                // Model selector
                Text("Select a Model")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, -12)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(availableModels) { model in
                            ModelCard(
                                model: model,
                                isSelected: currentModelId == model.id,
                                isDarkMode: isDarkMode
                            ) {
                                onSelectModel(model)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background((isDarkMode ? Color(hex: "161616") : Color(UIColor.systemGroupedBackground)).ignoresSafeArea())
            .navigationTitle("Add to Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func attachmentButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                Text(label)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
    }
}

/// Simple model card for the model selector
public struct ModelCard: View {
    public let model: AgentModelDescriptor
    public let isSelected: Bool
    public let isDarkMode: Bool
    public let onTap: () -> Void

    public init(model: AgentModelDescriptor, isSelected: Bool, isDarkMode: Bool, onTap: @escaping () -> Void) {
        self.model = model
        self.isSelected = isSelected
        self.isDarkMode = isDarkMode
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(model.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)

                Text(model.displayName)
                    .font(.system(size: 13, weight: .medium))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundColor(isSelected ? .primary : .secondary)
            .frame(width: 120, height: 110)
            .background(
                ZStack {
                    if #available(iOS 26, *) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.thickMaterial)
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.chatSurface(isDarkMode: isDarkMode))
                    }
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.accentPrimary.opacity(0.15))
                    }
                    if !isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
                    }
                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                Circle()
                                    .fill(Color.accentPrimary)
                                    .frame(width: 16, height: 16)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                            }
                            Spacer()
                        }
                        .padding(8)
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
