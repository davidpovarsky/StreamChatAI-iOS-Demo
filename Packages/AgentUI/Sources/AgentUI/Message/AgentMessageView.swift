//
//  AgentMessageView.swift
//  AgentUI
//
//  Authoritative message presentation extracted directly from SwiftChat.
//

import AVKit
import SwiftUI
import Textual
import SwiftMath
import UIKit
import WebKit

public struct AgentMessageView: View {
    public let message: AgentMessage
    public let isDarkMode: Bool
    public let isLastMessage: Bool
    public let isLoading: Bool
    public let messageIndex: Int
    public weak var driver: (any AgentMessageDriving)?

    public var onEditMessage: ((Int, String) -> Void)?
    public var onRegenerateLastResponse: (() -> Void)?
    public var onRegenerateMessage: ((Int) -> Void)?
    public var webSearchSummary: String?
    public var thinkingSummary: String?

    @ObservedObject private var activityStore = AgentActivityStore.shared
    @State private var showCopyFeedback = false
    @State private var cachedParsedContent: (thinkingText: String, remainderText: String, contentHash: Int)? = nil
    @State private var showLongMessageSheet = false
    @State private var showRawContentModal = false
    @State private var isEditMode = false
    @State private var editedContent = ""
    @State private var showSelectableText = false
    @State private var showSourcesSheet = false
    @State private var showUserMessageActions = false
    @State private var showThoughtsSheet = false
    @State private var showURLFetchSheet = false

    private let accessory: AnyView?

    private var hasAgentActivity: Bool {
        activityStore.session(for: message.id) != nil
    }

    private var effectiveWebSearchSummary: String? {
        webSearchSummary ?? driver?.drivingWebSearchSummary
    }

    private var effectiveThinkingSummary: String? {
        thinkingSummary ?? driver?.drivingThinkingSummary
    }

    private var isEffectivelyLoading: Bool {
        driver?.isMessageLoading ?? isLoading
    }

    public init(
        message: AgentMessage,
        isDarkMode: Bool,
        isLastMessage: Bool = false,
        isLoading: Bool = false,
        messageIndex: Int = 0,
        driver: (any AgentMessageDriving)? = nil,
        onEditMessage: ((Int, String) -> Void)? = nil,
        onRegenerateLastResponse: (() -> Void)? = nil,
        onRegenerateMessage: ((Int) -> Void)? = nil,
        webSearchSummary: String? = nil,
        thinkingSummary: String? = nil
    ) {
        self.message = message
        self.isDarkMode = isDarkMode
        self.isLastMessage = isLastMessage
        self.isLoading = isLoading
        self.messageIndex = messageIndex
        self.driver = driver
        self.onEditMessage = onEditMessage
        self.onRegenerateLastResponse = onRegenerateLastResponse
        self.onRegenerateMessage = onRegenerateMessage
        self.webSearchSummary = webSearchSummary
        self.thinkingSummary = thinkingSummary
        self.accessory = nil
    }

    public init<Accessory: View>(
        message: AgentMessage,
        isDarkMode: Bool,
        isLastMessage: Bool = false,
        isLoading: Bool = false,
        messageIndex: Int = 0,
        driver: (any AgentMessageDriving)? = nil,
        onEditMessage: ((Int, String) -> Void)? = nil,
        onRegenerateLastResponse: (() -> Void)? = nil,
        onRegenerateMessage: ((Int) -> Void)? = nil,
        webSearchSummary: String? = nil,
        thinkingSummary: String? = nil,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.message = message
        self.isDarkMode = isDarkMode
        self.isLastMessage = isLastMessage
        self.isLoading = isLoading
        self.messageIndex = messageIndex
        self.driver = driver
        self.onEditMessage = onEditMessage
        self.onRegenerateLastResponse = onRegenerateLastResponse
        self.onRegenerateMessage = onRegenerateMessage
        self.webSearchSummary = webSearchSummary
        self.thinkingSummary = thinkingSummary
        self.accessory = AnyView(accessory())
    }

    /// Backward compatibility initializer
    public init(
        id: String,
        role: MessageRole,
        content: String,
        thoughts: String? = nil,
        isThinking: Bool = false,
        isDarkMode: Bool,
        isLastMessage: Bool = false,
        isLoading: Bool = false,
        generationTimeSeconds: Double? = nil,
        webSearchState: WebSearchState? = nil,
        urlFetches: [URLFetchState] = [],
        attachments: [Attachment] = [],
        contentParts: [MessageContentPart] = [],
        streamError: String? = nil,
        isRequestError: Bool = false,
        activitySession: AgentActivitySession? = nil,
        onToggleActivity: (() -> Void)? = nil,
        onCopy: (() -> Void)? = nil,
        onRegenerate: (() -> Void)? = nil,
        onSelectImage: ((Attachment) -> Void)? = nil
    ) {
        let msg = AgentMessage(
            id: id,
            role: role,
            content: content,
            thoughts: thoughts,
            isThinking: isThinking,
            generationTimeSeconds: generationTimeSeconds,
            webSearchState: webSearchState,
            urlFetches: urlFetches,
            attachments: attachments,
            contentParts: contentParts
        )
        self.init(
            message: msg,
            isDarkMode: isDarkMode,
            isLastMessage: isLastMessage,
            isLoading: isLoading,
            messageIndex: 0,
            onRegenerateLastResponse: onRegenerate
        )
    }

    public var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }

            VStack(alignment: .trailing, spacing: 4) {
                // Show attachment indicators above the message bubble
                if message.role == .user && !message.attachments.isEmpty {
                    MessageAttachmentIndicator(
                        attachments: message.attachments,
                        isDarkMode: isDarkMode
                    )
                }

                VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 2) {
                    if message.role == .assistant {
                        if let session = activityStore.session(for: message.id) {
                            AgentActivityTimelineView(session: session, isDarkMode: isDarkMode) {
                                activityStore.setExpanded(!session.isExpanded, messageID: message.id)
                            }
                        }
                        if let accessory = accessory {
                            accessory
                        }
                    }

                    // Show the loading dots for a fresh streaming assistant response
                    if message.role == .assistant &&
                        message.content.isEmpty &&
                        message.thoughts == nil &&
                        !message.isThinking &&
                        isEffectivelyLoading &&
                        isLastMessage {
                        VStack(alignment: .leading, spacing: 4) {
                            if !message.urlFetches.isEmpty {
                                URLFetchBox(urlFetches: message.urlFetches, isDarkMode: isDarkMode, onTap: { showURLFetchSheet = true })
                            }

                            // Show web search box if searching
                            if !hasAgentActivity, let webSearchState = message.webSearchState {
                                WebSearchBox(
                                    webSearchState: webSearchState,
                                    isDarkMode: isDarkMode,
                                    isStreaming: true,
                                    webSearchSummary: effectiveWebSearchSummary,
                                    onTap: { showSourcesSheet = true }
                                )
                            }

                            // Show loading dots if no web search or search is complete
                            if !hasAgentActivity && (message.webSearchState == nil || message.webSearchState?.status != .searching) {
                                LoadingDotsView(isDarkMode: isDarkMode)
                                    .padding(.horizontal)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // If the message is thinking or has thoughts, display them in a thinking box
                    else if message.isThinking || message.thoughts != nil {
                        VStack(alignment: .leading, spacing: 4) {
                            if !message.urlFetches.isEmpty {
                                URLFetchBox(urlFetches: message.urlFetches, isDarkMode: isDarkMode, onTap: { showURLFetchSheet = true })
                            }

                            if !hasAgentActivity, let webSearchState = message.webSearchState {
                                WebSearchBox(
                                    webSearchState: webSearchState,
                                    isDarkMode: isDarkMode,
                                    isStreaming: isEffectivelyLoading && isLastMessage,
                                    webSearchSummary: isLastMessage ? effectiveWebSearchSummary : nil,
                                    onTap: { showSourcesSheet = true }
                                )
                            }

                            if !hasAgentActivity {
                                CollapsibleThinkingBox(
                                    thinkingText: message.thoughts ?? "",
                                    isDarkMode: isDarkMode,
                                    isStreaming: message.isThinking && isEffectivelyLoading && isLastMessage,
                                    generationTimeSeconds: message.generationTimeSeconds,
                                    thinkingSummary: isLastMessage && message.isThinking ? effectiveThinkingSummary : nil,
                                    onTap: { showThoughtsSheet = true }
                                )
                            }

                            if !message.content.isEmpty {
                                if !message.contentChunks.isEmpty {
                                    ChunkedContentView(chunks: message.contentChunks, isDarkMode: isDarkMode, isStreaming: isEffectivelyLoading && isLastMessage)
                                        .equatable()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    LaTeXMarkdownView(content: message.content, isDarkMode: isDarkMode, isStreaming: isEffectivelyLoading && isLastMessage)
                                        .equatable()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .transaction { transaction in
                                            transaction.animation = nil
                                        }
                                }
                            }
                        }
                    }

                    // Legacy support: if content still has <think> tags, parse and display
                    else if let parsed = getParsedMessageContent() {
                        VStack(alignment: .leading, spacing: 4) {
                            CollapsibleThinkingBox(
                                thinkingText: parsed.thinkingText,
                                isDarkMode: isDarkMode,
                                isStreaming: isEffectivelyLoading && isLastMessage,
                                generationTimeSeconds: message.generationTimeSeconds,
                                thinkingSummary: isLastMessage && !message.content.contains("</think>") ? effectiveThinkingSummary : nil,
                                onTap: { showThoughtsSheet = true }
                            )

                            if !parsed.remainderText.isEmpty {
                                LaTeXMarkdownView(content: parsed.remainderText, isDarkMode: isDarkMode, isStreaming: isEffectivelyLoading && isLastMessage)
                                    .equatable()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .transaction { transaction in
                                        transaction.animation = nil
                                    }
                            }
                        }
                    }

                    // Display long user messages as an attachment-style preview that expands on tap
                    else if message.role == .user && message.shouldDisplayAsAttachment {
                        if isEditMode {
                            UserMessageEditView(
                                content: $editedContent,
                                isDarkMode: isDarkMode,
                                onSave: {
                                    saveEditedMessage()
                                    isEditMode = false
                                },
                                onCancel: {
                                    isEditMode = false
                                    editedContent = message.content
                                }
                            )
                        } else {
                            LongMessageAttachmentView(message: message, isDarkMode: isDarkMode) {
                                showLongMessageSheet = true
                            }
                        }
                    }

                    else if !message.content.isEmpty {
                        if message.role == .user {
                            if isEditMode {
                                UserMessageEditView(
                                    content: $editedContent,
                                    isDarkMode: isDarkMode,
                                    onSave: {
                                        saveEditedMessage()
                                        isEditMode = false
                                    },
                                    onCancel: {
                                        isEditMode = false
                                        editedContent = message.content
                                    }
                                )
                            } else {
                                AdaptiveMarkdownText(content: message.content, isDarkMode: isDarkMode)
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                if !message.urlFetches.isEmpty {
                                    URLFetchBox(urlFetches: message.urlFetches, isDarkMode: isDarkMode, onTap: { showURLFetchSheet = true })
                                }

                                if !hasAgentActivity, let webSearchState = message.webSearchState {
                                    WebSearchBox(
                                        webSearchState: webSearchState,
                                        isDarkMode: isDarkMode,
                                        isStreaming: isEffectivelyLoading && isLastMessage,
                                        webSearchSummary: isLastMessage ? effectiveWebSearchSummary : nil,
                                        onTap: { showSourcesSheet = true }
                                    )
                                }

                                if !message.contentParts.isEmpty {
                                    ForEach(message.contentParts) { part in
                                        switch part.kind {
                                        case .markdown:
                                            if let text = part.markdown, !text.isEmpty {
                                                if part.sources.isEmpty {
                                                    LaTeXMarkdownView(content: text, isDarkMode: isDarkMode, isStreaming: false)
                                                        .equatable()
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                } else {
                                                    InlineSectionSourcesView(
                                                        markdown: text,
                                                        sources: part.sources,
                                                        isDarkMode: isDarkMode
                                                    )
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                }
                                            }
                                        case .image:
                                            SafeInlineImageMediaView(part: part, isDarkMode: isDarkMode)
                                        case .video:
                                            SafeInlineVideoMediaView(part: part, isDarkMode: isDarkMode)
                                        case .youtube:
                                            SafeInlineYouTubeMediaView(part: part, isDarkMode: isDarkMode)
                                        case .linkPreview:
                                            InlineLinkPreviewView(part: part, isDarkMode: isDarkMode)
                                        }
                                    }
                                } else if !message.contentChunks.isEmpty {
                                    ChunkedContentView(chunks: message.contentChunks, isDarkMode: isDarkMode, isStreaming: isEffectivelyLoading && isLastMessage)
                                        .equatable()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    LaTeXMarkdownView(content: message.content, isDarkMode: isDarkMode, isStreaming: isEffectivelyLoading && isLastMessage)
                                        .equatable()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }

                    // Show error box with regenerate button if stream failed
                    if message.streamError != nil && message.role == .assistant {
                        ErrorMessageView(
                            errorMessage: message.streamError!,
                            isDarkMode: isDarkMode,
                            isRequestError: message.isRequestError,
                            onRegenerate: isLastMessage ? { triggerRegenerateLast() } : nil
                        )
                        .padding(.top, message.content.isEmpty && message.thoughts == nil ? 0 : 8)
                    }

                    // Action buttons for assistant messages
                    if message.role == .assistant &&
                       (!message.content.isEmpty || !message.contentParts.isEmpty || message.thoughts != nil) &&
                       !(isEffectivelyLoading && isLastMessage) {
                        HStack(spacing: 16) {
                            if let webSearchState = message.webSearchState,
                               !webSearchState.sources.isEmpty {
                                SourcesButton(
                                    sources: webSearchState.sources,
                                    isDarkMode: isDarkMode
                                ) {
                                    showSourcesSheet = true
                                }
                            }

                            Button {
                                showRawContentModal = true
                            } label: {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(isDarkMode ? .white.opacity(0.5) : .black.opacity(0.5))
                                    .frame(width: 32, height: 32)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())

                            if isLastMessage && !isEffectivelyLoading && messageIndex > 0 {
                                Button {
                                    triggerRegenerate(at: messageIndex - 1)
                                } label: {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(isDarkMode ? .white.opacity(0.5) : .black.opacity(0.5))
                                        .frame(width: 32, height: 32)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }

                            Spacer()
                        }
                        .padding(.vertical, 8)

                        if isLastMessage {
                            Text("AI can make mistakes. Verify important information.")
                                .font(.system(size: 11))
                                .foregroundColor(isDarkMode ? .white.opacity(0.35) : .black.opacity(0.35))
                        }
                    }
                }
                .padding(.vertical, message.role == .user && message.content.isEmpty ? 0 : 8)
                .padding(.horizontal, message.role == .user && !message.content.isEmpty ? 12 : 0)
                .background {
                    if message.role == .user && !message.content.isEmpty {
                        if #available(iOS 26, *) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.thickMaterial)
                        } else {
                            Color.userMessageBackground(isDarkMode: isDarkMode)
                        }
                    }
                }
                .cornerRadius(16)
                .modifier(MessageBubbleModifier(isUserMessage: message.role == .user))
                .contextMenu {
                    if message.role == .user && !message.content.isEmpty {
                        Button {
                            triggerRegenerate(at: messageIndex)
                        } label: {
                            Label("Resend", systemImage: "arrow.clockwise")
                        }
                        .disabled(isEffectivelyLoading)

                        Button {
                            UIPasteboard.general.string = message.content
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        }

                        Button {
                            editedContent = message.content
                            isEditMode = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                    }
                }
                .onChange(of: message.id) { _, _ in
                    isEditMode = false
                    editedContent = ""
                }
            }
        }
        .padding(.horizontal, 4)
        .sheet(isPresented: $showLongMessageSheet) {
            LongMessageDetailView(message: message)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showRawContentModal) {
            RawContentModalView(message: message)
                .presentationDetents([.medium, .large])
                .presentationBackground(isDarkMode ? Color(hex: "161616") : Color(UIColor.systemGroupedBackground))
        }
        .sheet(isPresented: $showSelectableText) {
            UserMessageSelectView(content: message.content)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showSourcesSheet) {
            if let sources = message.webSearchState?.sources {
                SourcesSheetView(sources: sources, isDarkMode: isDarkMode)
                    .presentationDetents([.medium, .large])
            }
        }
        .sheet(isPresented: $showThoughtsSheet) {
            ThoughtsSheetView(
                thinkingText: thoughtsContent ?? "",
                thinkingChunks: message.thinkingChunks,
                generationTimeSeconds: message.generationTimeSeconds,
                isDarkMode: isDarkMode
            )
            .presentationDetents([.medium, .large])
            .presentationBackground(isDarkMode ? Color(hex: "161616") : Color(UIColor.systemGroupedBackground))
        }
        .sheet(isPresented: $showURLFetchSheet) {
            URLFetchSheetView(urlFetches: message.urlFetches, isDarkMode: isDarkMode)
                .presentationDetents([.medium, .large])
                .presentationBackground(isDarkMode ? Color(hex: "161616") : Color(UIColor.systemGroupedBackground))
        }
        .environment(\.openURL, OpenURLAction { url in
            if url.scheme == "cite" {
                let path = url.absoluteString.dropFirst(5)
                if let tildeIndex = path.firstIndex(of: "~") {
                    let afterFirstTilde = path[path.index(after: tildeIndex)...]
                    if let secondTildeIndex = afterFirstTilde.firstIndex(of: "~") {
                        let encodedUrl = String(afterFirstTilde[..<secondTildeIndex])
                        if let decodedUrl = encodedUrl.removingPercentEncoding,
                           let sourceURL = URL(string: decodedUrl) {
                            UIApplication.shared.open(sourceURL)
                            return .handled
                        }
                    }
                }
                return .handled
            }
            return .systemAction
        })
    }

    private func saveEditedMessage() {
        if let driver = driver {
            driver.editMessage(at: messageIndex, newContent: editedContent)
        } else {
            onEditMessage?(messageIndex, editedContent)
        }
    }

    private func triggerRegenerate(at index: Int) {
        if let driver = driver {
            driver.regenerateMessage(at: index)
        } else {
            onRegenerateMessage?(index)
        }
    }

    private func triggerRegenerateLast() {
        if let driver = driver {
            driver.regenerateLastResponse()
        } else {
            onRegenerateLastResponse?()
        }
    }

    private func copyMessagePart(_ text: String) {
        let cleanText = removeThinktags(from: text)
        UIPasteboard.general.string = cleanText

        withAnimation {
            showCopyFeedback = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showCopyFeedback = false
            }
        }
    }

    private func removeThinktags(from text: String) -> String {
        guard text.hasPrefix("<think>") else { return text }
        if let endTagRange = text.range(of: "</think>") {
            return String(text[endTagRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return text.replacingOccurrences(of: "<think>", with: "")
    }

    private var thoughtsContent: String? {
        if let thoughts = message.thoughts, !thoughts.isEmpty {
            return thoughts
        }
        if message.content.hasPrefix("<think>") {
            let tagPrefix = "<think>"
            let tagSuffix = "</think>"
            let start = message.content.index(message.content.startIndex, offsetBy: tagPrefix.count)

            if let endTagRange = message.content.range(of: tagSuffix, range: start..<message.content.endIndex) {
                return String(message.content[start..<endTagRange.lowerBound])
            } else {
                return String(message.content[start...])
            }
        }
        return nil
    }

    private var responseContent: String {
        if message.thoughts != nil {
            return message.content.hasPrefix("<think>") ? "" : message.content
        }
        if message.content.hasPrefix("<think>") {
            let tagSuffix = "</think>"
            if let endTagRange = message.content.range(of: tagSuffix) {
                return String(message.content[endTagRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return message.content
    }

    private func getParsedMessageContent() -> (thinkingText: String, remainderText: String)? {
        guard message.content.hasPrefix("<think>") else { return nil }
        let tagPrefix = "<think>"
        let tagSuffix = "</think>"
        let start = message.content.index(message.content.startIndex, offsetBy: tagPrefix.count)

        if let endTagRange = message.content.range(of: tagSuffix, range: start..<message.content.endIndex) {
            let thinkingText = String(message.content[start..<endTagRange.lowerBound])
            let remainderText = String(message.content[endTagRange.upperBound...])
            return (thinkingText, remainderText)
        } else {
            let thinkingText = String(message.content[start...])
            return (thinkingText, "")
        }
    }
}

// MARK: - Long Message Presentation

private struct LongMessageAttachmentView: View {
    let message: AgentMessage
    let isDarkMode: Bool
    let openAction: () -> Void

    private var wordCountText: String {
        let words = message.content.split { $0.isWhitespace || $0.isNewline }
        return "\(words.count) words"
    }

    private var previewText: String {
        let trimmed = message.content.trimmingCharacters(in: .whitespacesAndNewlines)
        let preview = trimmed.prefix(180)
        return preview + (trimmed.count > 180 ? "…" : "")
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "doc.text")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(Color.userMessageForeground(isDarkMode: isDarkMode).opacity(0.85))

            VStack(alignment: .leading, spacing: 6) {
                Text("Long Message")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.userMessageForeground(isDarkMode: isDarkMode))

                Text(wordCountText)
                    .font(.system(size: 12))
                    .foregroundColor(Color.userMessageForeground(isDarkMode: isDarkMode).opacity(0.6))

                Text(previewText)
                    .font(.system(size: 14))
                    .foregroundColor(Color.userMessageForeground(isDarkMode: isDarkMode).opacity(0.85))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.userMessageForeground(isDarkMode: isDarkMode).opacity(0.5))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture(perform: openAction)
    }
}

private struct LongMessageDetailView: View {
    let message: AgentMessage
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                SelectableTextView(text: message.content)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color.backgroundPrimary)
            .navigationTitle("Long Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct SelectableTextView: UIViewRepresentable {
    let text: String
    @Environment(\.colorScheme) private var colorScheme

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.alwaysBounceVertical = true
        textView.isScrollEnabled = true
        textView.showsVerticalScrollIndicator = true
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.textColor = colorScheme == .dark ? UIColor(white: 1.0, alpha: 0.92) : UIColor(white: 0.0, alpha: 0.92)
    }
}

private struct UserMessageSelectView: View {
    let content: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            SelectableTextView(text: content)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(20)
                .background(Color.backgroundPrimary)
                .navigationTitle("Select Text")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
        }
        .preferredColorScheme(.dark)
    }
}

private struct RawContentModalView: View {
    let message: AgentMessage

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showCopyAllFeedback = false
    @State private var showCopyResponseFeedback = false
    @State private var showCopyThoughtsFeedback = false

    private var isDarkMode: Bool { colorScheme == .dark }

    private var hasThoughts: Bool {
        if let thoughts = message.thoughts, !thoughts.isEmpty {
            return true
        }
        return message.content.hasPrefix("<think>")
    }

    private var thoughtsContent: String? {
        if let thoughts = message.thoughts, !thoughts.isEmpty {
            return thoughts
        }
        if message.content.hasPrefix("<think>") {
            let tagPrefix = "<think>"
            let tagSuffix = "</think>"
            let start = message.content.index(message.content.startIndex, offsetBy: tagPrefix.count)

            if let endTagRange = message.content.range(of: tagSuffix, range: start..<message.content.endIndex) {
                return String(message.content[start..<endTagRange.lowerBound])
            } else {
                return String(message.content[start...])
            }
        }
        return nil
    }

    private var responseContent: String {
        if message.thoughts != nil {
            return message.content.hasPrefix("<think>") ? "" : message.content
        }
        if message.content.hasPrefix("<think>") {
            let tagSuffix = "</think>"
            if let endTagRange = message.content.range(of: tagSuffix) {
                return String(message.content[endTagRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return message.content
    }

    private var fullRawContent: String {
        if let thoughts = thoughtsContent, !thoughts.isEmpty {
            if !responseContent.isEmpty {
                return thoughts + "\n\n" + responseContent
            }
            return thoughts
        }
        return responseContent
    }

    private var sheetBackground: Color {
        isDarkMode ? Color(hex: "161616") : Color(UIColor.systemGroupedBackground)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SelectableTextView(text: fullRawContent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 20)

                Divider()

                VStack(spacing: 10) {
                    copyButton(
                        action: copyAll,
                        icon: showCopyAllFeedback ? "checkmark" : "doc.on.doc",
                        label: showCopyAllFeedback ? "Copied All!" : "Copy All"
                    )

                    if hasThoughts && !responseContent.isEmpty {
                        copyButton(
                            action: copyResponse,
                            icon: showCopyResponseFeedback ? "checkmark" : "text.quote",
                            label: showCopyResponseFeedback ? "Copied Response!" : "Copy Response"
                        )
                    }

                    if hasThoughts {
                        copyButton(
                            action: copyThoughts,
                            icon: showCopyThoughtsFeedback ? "checkmark" : "brain",
                            label: showCopyThoughtsFeedback ? "Copied Thoughts!" : "Copy Thoughts"
                        )
                    }
                }
                .padding(20)
            }
            .background(sheetBackground)
            .navigationTitle("Raw Content")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                    }
                }
            }
        }
    }

    private func copyButton(action: @escaping () -> Void, icon: String, label: String) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(label)
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.brandAccentDark)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func copyAll() {
        UIPasteboard.general.string = fullRawContent
        withAnimation {
            showCopyAllFeedback = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showCopyAllFeedback = false
            }
        }
    }

    private func copyResponse() {
        UIPasteboard.general.string = responseContent
        withAnimation {
            showCopyResponseFeedback = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showCopyResponseFeedback = false
            }
        }
    }

    private func copyThoughts() {
        if let thoughts = thoughtsContent {
            UIPasteboard.general.string = thoughts
            withAnimation {
                showCopyThoughtsFeedback = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    showCopyThoughtsFeedback = false
                }
            }
        }
    }
}

// MARK: - Sizing and Text Modifiers

public struct MessageBubbleModifier: ViewModifier {
    public let isUserMessage: Bool

    public init(isUserMessage: Bool) {
        self.isUserMessage = isUserMessage
    }

    public func body(content: Content) -> some View {
        Group {
            if isUserMessage {
                content
                    .frame(minWidth: 60, idealWidth: nil, maxWidth: max(60, UIScreen.main.bounds.width * 0.85), alignment: .trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

public struct MarkdownText: View {
    public let content: String
    public let isDarkMode: Bool
    public let horizontalPadding: CGFloat

    public init(content: String, isDarkMode: Bool, horizontalPadding: CGFloat = 0) {
        self.content = content
        self.isDarkMode = isDarkMode
        self.horizontalPadding = horizontalPadding
    }

    public var body: some View {
        StructuredText(markdown: content)
            .textual.structuredTextStyle(.gitHub)
            .textual.highlighterTheme(.default)
            .textual.textSelection(.enabled)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, horizontalPadding)
            .environment(\.colorScheme, isDarkMode ? .dark : .light)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

public struct AdaptiveMarkdownText: View {
    public let content: String
    public let isDarkMode: Bool
    public let horizontalPadding: CGFloat

    public init(content: String, isDarkMode: Bool, horizontalPadding: CGFloat = 0) {
        self.content = content
        self.isDarkMode = isDarkMode
        self.horizontalPadding = horizontalPadding
    }

    public var body: some View {
        StructuredText(markdown: content)
            .textual.structuredTextStyle(.gitHub)
            .textual.highlighterTheme(.default)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, -16)
            .padding(.horizontal, horizontalPadding)
            .environment(\.colorScheme, isDarkMode ? .dark : .light)
    }
}

// MARK: - Thinking Components

public struct CollapsibleThinkingBox: View {
    public let thinkingText: String
    public let isDarkMode: Bool
    public let isStreaming: Bool
    public let generationTimeSeconds: Double?
    public let thinkingSummary: String?
    public let onTap: () -> Void

    public init(
        thinkingText: String,
        isDarkMode: Bool,
        isStreaming: Bool = false,
        generationTimeSeconds: Double? = nil,
        thinkingSummary: String? = nil,
        onTap: @escaping () -> Void
    ) {
        self.thinkingText = thinkingText
        self.isDarkMode = isDarkMode
        self.isStreaming = isStreaming
        self.generationTimeSeconds = generationTimeSeconds
        self.thinkingSummary = thinkingSummary
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            HStack {
                if let seconds = generationTimeSeconds {
                    Text("Thought for \(String(format: "%.1f", seconds))s")
                        .font(.subheadline)
                        .foregroundColor(isDarkMode ? .white.opacity(0.7) : Color.black.opacity(0.6))
                } else if isStreaming {
                    if let summary = thinkingSummary, !summary.isEmpty {
                        Text(summary)
                            .font(.subheadline)
                            .foregroundColor(isDarkMode ? .white : Color.black.opacity(0.8))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .modifier(TextPulseAnimation())
                    } else {
                        HStack(spacing: 4) {
                            Text("Thinking")
                                .font(.system(size: 16))
                                .foregroundColor(isDarkMode ? .white : Color.black.opacity(0.8))
                            InlineLoadingDotsView(isDarkMode: isDarkMode)
                        }
                        .modifier(TextPulseAnimation())
                    }
                } else {
                    Text("Thinking")
                        .font(.system(size: 16))
                        .foregroundColor(isDarkMode ? .white : Color.black.opacity(0.8))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isDarkMode ? .white.opacity(0.4) : .black.opacity(0.4))
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(NoHighlightButtonStyle())
    }
}

public struct ThoughtsSheetView: View {
    public let thinkingText: String
    public let thinkingChunks: [ThinkingChunk]
    public let generationTimeSeconds: Double?
    public let isDarkMode: Bool
    @Environment(\.dismiss) private var dismiss

    public init(
        thinkingText: String,
        thinkingChunks: [ThinkingChunk] = [],
        generationTimeSeconds: Double? = nil,
        isDarkMode: Bool
    ) {
        self.thinkingText = thinkingText
        self.thinkingChunks = thinkingChunks
        self.generationTimeSeconds = generationTimeSeconds
        self.isDarkMode = isDarkMode
    }

    private var titleText: String {
        if let seconds = generationTimeSeconds {
            return "Thought for \(String(format: "%.1f", seconds))s"
        }
        return "Thoughts"
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if !thinkingChunks.isEmpty {
                        ForEach(thinkingChunks) { chunk in
                            ThinkingChunkView(chunk: chunk, isDarkMode: isDarkMode)
                                .equatable()
                        }
                    } else {
                        Text(thinkingText)
                            .font(.system(.body))
                            .foregroundColor(isDarkMode ? .white.opacity(0.9) : Color.black.opacity(0.8))
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle(titleText)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

public struct ThinkingChunkView: View, Equatable {
    public let chunk: ThinkingChunk
    public let isDarkMode: Bool

    public init(chunk: ThinkingChunk, isDarkMode: Bool) {
        self.chunk = chunk
        self.isDarkMode = isDarkMode
    }

    nonisolated public static func == (lhs: ThinkingChunkView, rhs: ThinkingChunkView) -> Bool {
        if lhs.chunk.isComplete && rhs.chunk.isComplete {
            return lhs.chunk.id == rhs.chunk.id && lhs.isDarkMode == rhs.isDarkMode
        }
        return lhs.chunk.id == rhs.chunk.id &&
               lhs.chunk.content == rhs.chunk.content &&
               lhs.isDarkMode == rhs.isDarkMode
    }

    public var body: some View {
        Text(chunk.content)
            .font(.system(.body))
            .foregroundColor(isDarkMode ? .white.opacity(0.9) : Color.black.opacity(0.8))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 8)
    }
}

// MARK: - Loading Dots and Animations

public struct LoadingDotsView: View {
    public let isDarkMode: Bool

    public init(isDarkMode: Bool) {
        self.isDarkMode = isDarkMode
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 6, height: 6)
                    .modifier(PulsingAnimation(delay: 0.2 * Double(index)))
            }
        }
        .foregroundColor(isDarkMode ? .white : .black)
    }
}

public struct InlineLoadingDotsView: View {
    public let isDarkMode: Bool

    public init(isDarkMode: Bool) {
        self.isDarkMode = isDarkMode
    }

    public var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 4, height: 4)
                    .modifier(PulsingAnimation(delay: 0.2 * Double(index)))
            }
        }
        .foregroundColor(isDarkMode ? .white.opacity(0.8) : Color.black.opacity(0.7))
    }
}

public struct TextPulseAnimation: ViewModifier {
    @State private var offset: CGFloat = -1.0

    public init() {}

    public func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    let shimmerWidth = geometry.size.width * 0.4
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.35),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: shimmerWidth)
                    .offset(x: offset * (geometry.size.width + shimmerWidth))
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: false)
                ) {
                    offset = 1.0
                }
            }
    }
}

// MARK: - Chunked and Table Rendering

public struct ChunkedContentView: View, Equatable {
    public let chunks: [ContentChunk]
    public let isDarkMode: Bool
    public let isStreaming: Bool

    public init(chunks: [ContentChunk], isDarkMode: Bool, isStreaming: Bool) {
        self.chunks = chunks
        self.isDarkMode = isDarkMode
        self.isStreaming = isStreaming
    }

    nonisolated public static func == (lhs: ChunkedContentView, rhs: ChunkedContentView) -> Bool {
        lhs.chunks == rhs.chunks &&
        lhs.isDarkMode == rhs.isDarkMode &&
        lhs.isStreaming == rhs.isStreaming
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(chunks) { chunk in
                ChunkView(chunk: chunk, isDarkMode: isDarkMode, isStreaming: isStreaming)
            }
        }
    }
}

public struct ChunkView: View, Equatable {
    public let chunk: ContentChunk
    public let isDarkMode: Bool
    public let isStreaming: Bool

    public init(chunk: ContentChunk, isDarkMode: Bool, isStreaming: Bool) {
        self.chunk = chunk
        self.isDarkMode = isDarkMode
        self.isStreaming = isStreaming
    }

    nonisolated public static func == (lhs: ChunkView, rhs: ChunkView) -> Bool {
        if lhs.chunk.isComplete && rhs.chunk.isComplete {
            return lhs.chunk.id == rhs.chunk.id && lhs.isDarkMode == rhs.isDarkMode
        }
        return lhs.chunk.id == rhs.chunk.id &&
               lhs.chunk.isComplete == rhs.chunk.isComplete &&
               lhs.chunk.content == rhs.chunk.content &&
               lhs.isDarkMode == rhs.isDarkMode &&
               lhs.isStreaming == rhs.isStreaming
    }

    public var body: some View {
        if chunk.type == .table && isStreaming {
            GeneratingTableView(isDarkMode: isDarkMode)
        } else {
            LaTeXMarkdownView(
                content: chunk.content,
                isDarkMode: isDarkMode,
                isStreaming: chunk.isComplete ? false : isStreaming
            )
            .equatable()
        }
    }
}

public struct GeneratingTableView: View {
    public let isDarkMode: Bool

    public init(isDarkMode: Bool) {
        self.isDarkMode = isDarkMode
    }

    public var body: some View {
        HStack(spacing: 8) {
            Text("Generating table")
                .font(.subheadline.weight(.medium))
                .foregroundColor(isDarkMode ? .white : .black)
            InlineLoadingDotsView(isDarkMode: isDarkMode)
        }
        .frame(height: 48)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isDarkMode ? Color.white.opacity(0.15) : Color.black.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Error Message View

public struct ErrorMessageView: View {
    public let errorMessage: String
    public let isDarkMode: Bool
    public var isRequestError: Bool = false
    public var onRegenerate: (() -> Void)? = nil

    public init(errorMessage: String, isDarkMode: Bool, isRequestError: Bool = false, onRegenerate: (() -> Void)? = nil) {
        self.errorMessage = errorMessage
        self.isDarkMode = isDarkMode
        self.isRequestError = isRequestError
        self.onRegenerate = onRegenerate
    }

    private var accentColor: Color {
        isRequestError ? .red : .orange
    }

    private var isConnectionError: Bool {
        let msg = errorMessage.lowercased()
        return msg.contains("internet connection") || msg.contains("network") || msg.contains("connection was lost") || msg.contains("unable to connect")
    }

    private var headerIcon: String {
        if isConnectionError { return "wifi.exclamationmark" }
        return "exclamationmark.triangle"
    }

    private var headerText: String {
        if isConnectionError { return "Connection Lost" }
        return "Something Went Wrong"
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: headerIcon)
                    .foregroundColor(accentColor)
                    .font(.system(size: 16))

                Text(headerText)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(isDarkMode ? .white : .black)

                Spacer()
            }

            Text(errorMessage)
                .font(.caption)
                .foregroundColor(isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
                .multilineTextAlignment(.leading)

            HStack(spacing: 8) {
                if let onRegenerate = onRegenerate {
                    Button(action: onRegenerate) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 12, weight: .medium))
                            Text("Try again")
                                .font(.subheadline.weight(.medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(accentColor)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(accentColor.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(accentColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - User Message Editing

public struct UserMessageEditView: View {
    @Binding public var content: String
    public let isDarkMode: Bool
    public let onSave: () -> Void
    public let onCancel: () -> Void
    @FocusState private var isFocused: Bool

    public init(content: Binding<String>, isDarkMode: Bool, onSave: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self._content = content
        self.isDarkMode = isDarkMode
        self.onSave = onSave
        self.onCancel = onCancel
    }

    private var textColor: Color {
        isDarkMode ? .white : .black
    }

    private var secondaryTextColor: Color {
        isDarkMode ? .white.opacity(0.5) : .black.opacity(0.5)
    }

    private var buttonBackgroundColor: Color {
        isDarkMode ? .white.opacity(0.1) : .black.opacity(0.1)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Messages below will be deleted and regenerated.")
                .font(.system(size: 12))
                .foregroundColor(secondaryTextColor)

            TextField("Edit message...", text: $content, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.body)
                .foregroundColor(textColor)
                .lineLimit(1...4)
                .focused($isFocused)
                .onAppear {
                    isFocused = true
                }
                .onSubmit {
                    if !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        onSave()
                    }
                }

            HStack(spacing: 8) {
                Spacer()

                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(secondaryTextColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(buttonBackgroundColor)
                        .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    if !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        onSave()
                    }
                }) {
                    Text("Save")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentPrimary)
                        .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// MARK: - Sources Button

public struct SourcesButton: View {
    public let sources: [WebSearchSource]
    public let isDarkMode: Bool
    public let action: () -> Void

    public init(sources: [WebSearchSource], isDarkMode: Bool, action: @escaping () -> Void) {
        self.sources = sources
        self.isDarkMode = isDarkMode
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text("Sources")
                    .font(.system(size: 13, weight: .medium))

                SourceFaviconStack(sources: sources, isDarkMode: isDarkMode, iconSize: 18, overlap: -6)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(isDarkMode ? .white : .black)
    }
}

// MARK: - Tool Presentation Integration

/// Ensures ToolExecutionDisclosure symbol graph and layout availability for message presentation.
public struct AgentMessageToolPresentationView: View {
    public let call: ToolCallInspection
    public let status: ToolExecutionStatus

    public init(call: ToolCallInspection, status: ToolExecutionStatus = .completed) {
        self.call = call
        self.status = status
    }

    public var body: some View {
        ToolExecutionDisclosure(call: call, status: status) {
            HStack(spacing: 6) {
                Image(systemName: "wrench.and.screwdriver")
                    .font(.system(size: 12))
                Text(call.functionName)
                    .font(.system(size: 13, weight: .medium))
            }
        }
    }
}
