//
//  AgentMessageView.swift
//  AgentUI
//
//  Extracted existing message presentation with full visual and geometric parity.
//

import SwiftUI
import UIKit

public struct AgentMessageView: View {
    public let id: String
    public let role: MessageRole
    public let content: String
    public let thoughts: String?
    public let isThinking: Bool
    public let isDarkMode: Bool
    public let isLastMessage: Bool
    public let isLoading: Bool
    public let generationTimeSeconds: Double?
    public let webSearchState: WebSearchState?
    public let urlFetches: [URLFetchState]
    public let attachments: [Attachment]
    public let contentParts: [MessageContentPart]
    public let streamError: String?
    public let isRequestError: Bool
    public let activitySession: AgentActivitySession?

    // Callbacks
    public var onToggleActivity: (() -> Void)?
    public var onCopy: (() -> Void)?
    public var onRegenerate: (() -> Void)?
    public var onSelectImage: ((Attachment) -> Void)?

    @State private var showSourcesSheet = false
    @State private var showThoughtsSheet = false
    @State private var showURLFetchSheet = false
    @State private var showCopyFeedback = false

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
        self.id = id
        self.role = role
        self.content = content
        self.thoughts = thoughts
        self.isThinking = isThinking
        self.isDarkMode = isDarkMode
        self.isLastMessage = isLastMessage
        self.isLoading = isLoading
        self.generationTimeSeconds = generationTimeSeconds
        self.webSearchState = webSearchState
        self.urlFetches = urlFetches
        self.attachments = attachments
        self.contentParts = contentParts
        self.streamError = streamError
        self.isRequestError = isRequestError
        self.activitySession = activitySession
        self.onToggleActivity = onToggleActivity
        self.onCopy = onCopy
        self.onRegenerate = onRegenerate
        self.onSelectImage = onSelectImage
    }

    public var body: some View {
        HStack {
            if role == .user {
                Spacer()
            }

            VStack(alignment: role == .user ? .trailing : .leading, spacing: 4) {
                if role == .user && !attachments.isEmpty {
                    MessageAttachmentIndicator(
                        attachments: attachments,
                        isDarkMode: isDarkMode,
                        onSelectImage: onSelectImage
                    )
                }

                VStack(alignment: role == .user ? .trailing : .leading, spacing: 2) {
                    if role == .assistant, let activitySession {
                        AgentActivityTimelineView(session: activitySession, isDarkMode: isDarkMode) {
                            onToggleActivity?()
                        }
                    }

                    if role == .assistant && content.isEmpty && thoughts == nil && !isThinking && isLoading && isLastMessage {
                        VStack(alignment: .leading, spacing: 4) {
                            if !urlFetches.isEmpty {
                                URLFetchBox(urlFetches: urlFetches, isDarkMode: isDarkMode, onTap: { showURLFetchSheet = true })
                            }
                            if let webSearchState {
                                WebSearchBox(
                                    webSearchState: webSearchState,
                                    isDarkMode: isDarkMode,
                                    isStreaming: true,
                                    onTap: { showSourcesSheet = true }
                                )
                            }
                            if webSearchState == nil || webSearchState?.status != .searching {
                                LoadingDotsView(isDarkMode: isDarkMode)
                                    .padding(.horizontal)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    } else if isThinking || thoughts != nil {
                        VStack(alignment: .leading, spacing: 4) {
                            if !urlFetches.isEmpty {
                                URLFetchBox(urlFetches: urlFetches, isDarkMode: isDarkMode, onTap: { showURLFetchSheet = true })
                            }
                            if let webSearchState {
                                WebSearchBox(
                                    webSearchState: webSearchState,
                                    isDarkMode: isDarkMode,
                                    isStreaming: isThinking && isLoading && isLastMessage,
                                    onTap: { showSourcesSheet = true }
                                )
                            }
                            CollapsibleThinkingBox(
                                thinkingText: thoughts ?? "",
                                isDarkMode: isDarkMode,
                                isStreaming: isThinking && isLoading && isLastMessage,
                                generationTimeSeconds: generationTimeSeconds,
                                thinkingSummary: nil,
                                onTap: { showThoughtsSheet = true }
                            )

                            if !content.isEmpty {
                                messageBody
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            if !urlFetches.isEmpty {
                                URLFetchBox(urlFetches: urlFetches, isDarkMode: isDarkMode, onTap: { showURLFetchSheet = true })
                            }
                            if let webSearchState {
                                WebSearchBox(
                                    webSearchState: webSearchState,
                                    isDarkMode: isDarkMode,
                                    isStreaming: false,
                                    onTap: { showSourcesSheet = true }
                                )
                            }
                            messageBody
                        }
                    }
                }
            }

            if role == .assistant {
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .sheet(isPresented: $showSourcesSheet) {
            if let sources = webSearchState?.sources {
                SourcesSheetView(sources: sources, isDarkMode: isDarkMode)
            }
        }
        .sheet(isPresented: $showURLFetchSheet) {
            URLFetchSheetView(urlFetches: urlFetches, isDarkMode: isDarkMode)
        }
    }

    @ViewBuilder
    private var messageBody: some View {
        if role == .user {
            Text(content)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isDarkMode ? Color.agentUserMessageBackgroundDark : Color.agentUserMessageBackgroundLight)
                .foregroundColor(isDarkMode ? Color.agentUserMessageForegroundDark : Color.agentUserMessageForegroundLight)
                .clipShape(RoundedRectangle(cornerRadius: 18))
        } else {
            VStack(alignment: .leading, spacing: 8) {
                if !contentParts.isEmpty {
                    ForEach(contentParts) { part in
                        switch part.kind {
                        case .markdown:
                            if let text = part.markdown, !text.isEmpty {
                                if part.sources.isEmpty {
                                    LaTeXMarkdownView(content: text, isDarkMode: isDarkMode, isStreaming: false)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    AgentInlineSectionSourcesView(
                                        markdown: text,
                                        sources: part.sources,
                                        isDarkMode: isDarkMode
                                    ) { markdownText in
                                        LaTeXMarkdownView(content: markdownText, isDarkMode: isDarkMode, isStreaming: false)
                                    }
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
                            EmptyView()
                        }
                    }
                } else if !content.isEmpty {
                    LaTeXMarkdownView(content: content, isDarkMode: isDarkMode, isStreaming: false)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let sources = webSearchState?.sources, !sources.isEmpty {
                    SourcesButton(sources: sources, isDarkMode: isDarkMode) {
                        showSourcesSheet = true
                    }
                }

                if !isLoading || !isLastMessage {
                    assistantActions
                }
            }
        }
    }

    @ViewBuilder
    private var assistantActions: some View {
        HStack(spacing: 16) {
            Button {
                UIPasteboard.general.string = content
                showCopyFeedback = true
                onCopy?()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showCopyFeedback = false
                }
            } label: {
                Image(systemName: showCopyFeedback ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isDarkMode ? .white.opacity(0.5) : .black.opacity(0.5))
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if onRegenerate != nil {
                Button {
                    onRegenerate?()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isDarkMode ? .white.opacity(0.5) : .black.opacity(0.5))
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(.vertical, 8)

        Text("AI can make mistakes. Verify important information.")
            .font(.system(size: 11))
            .foregroundColor(isDarkMode ? .white.opacity(0.4) : .black.opacity(0.4))
            .padding(.top, 4)
    }
}

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

                SourceFaviconStack(
                    sources: sources,
                    isDarkMode: isDarkMode,
                    iconSize: 18,
                    overlap: -6
                )
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
                    } else {
                        HStack(spacing: 4) {
                            Text("Thinking")
                                .font(.system(size: 16))
                                .foregroundColor(isDarkMode ? .white : Color.black.opacity(0.8))
                            InlineLoadingDotsView(isDarkMode: isDarkMode)
                        }
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
