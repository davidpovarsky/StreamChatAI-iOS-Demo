//
//  ChatViewModel.swift
//  SwiftChat
//
//  Created on 03/25/26.
//  Copyright © 2026 Sacha Servan-Schreiber. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
#if canImport(OpenAI)
import OpenAI
@_spi(Generated) import OpenAPIRuntime
#endif
import AgentChatCore
import AgentChatActivity
import AgentChatToolPresentation

@MainActor
public class ChatViewModel: ObservableObject {
    public var runtimeProvider: AgentChatRuntimeProvider?
    private static let citationMarkerRegex = try? NSRegularExpression(pattern: "【(\\d+)[^】]*】", options: [])

    // Published properties for UI updates
    @Published public var chats: [Chat] = []
    @Published public var currentChat: Chat?
    @Published public var isLoading: Bool = false
    @Published var thinkingSummary: String = ""
    @Published var webSearchSummary: String = ""
    @Published var scrollTargetMessageId: String? = nil
    @Published var scrollTargetOffset: CGFloat = 0
    @Published var shouldFocusInput: Bool = false
    @Published var isScrollInteractionActive: Bool = false
    @Published var isAtBottom: Bool = true
    @Published var scrollToBottomTrigger: UUID = UUID()
    @Published var scrollToUserMessageTrigger: UUID = UUID()
    @Published var isWebSearchEnabled: Bool = false
    @Published var imageViewerImages: [Attachment] = []
    @Published var imageViewerIndex: Int = 0
    @Published var showImageViewer: Bool = false
    @Published var editRequestedForMessageIndex: Int? = nil

    // Model properties
    @Published public var currentModel: ModelType

    // Attachment properties
    @Published public var pendingAttachments: [Attachment] = []
    @Published public var isProcessingAttachment: Bool = false
    @Published public var attachmentError: String? = nil
    @Published public var pendingImageThumbnails: [String: String] = [:]

    public var messages: [Message] {
        currentChat?.messages ?? []
    }

    // Private properties
    private var client: OpenAI?
    private var currentTask: Task<Void, Never>?
    private var demoStreamingTask: Task<Void, Never>?
    private var pendingStreamUpdate: Chat?
    private var networkStatusCancellable: AnyCancellable?

    public init() {
        guard let model = AppConfig.shared.currentModel ?? AppConfig.shared.availableModels.first else {
            fatalError("ChatViewModel cannot be initialized without available models.")
        }
        self.currentModel = model
        self.isWebSearchEnabled = SettingsManager.shared.webSearchEnabled
        AppConfig.shared.apiKey = "__DEMO__"

        let liveStreamingChat = Chat.create(
            title: "LIVE Streaming Demo",
            titleState: .manual,
            messages: [
                Message(
                    role: .user,
                    content: "Explain what makes a modern AI chat interface feel excellent. Stream the answer live."
                )
            ],
            modelType: currentModel
        )

        // Sources for Web Research
        let s1 = WebSearchSource(title: "SwiftUI Documentation - Apple", url: "https://developer.apple.com/documentation/swiftui")
        let s2 = WebSearchSource(title: "SwiftChat Open Source Client", url: "https://github.com/sachaservan/SwiftChat")
        let s3 = WebSearchSource(title: "Human Interface Guidelines - Apple", url: "https://developer.apple.com/design/human-interface-guidelines")
        let s4 = WebSearchSource(title: "OpenAI Developer Platform", url: "https://platform.openai.com/docs")
        let s5 = WebSearchSource(title: "GetStream StreamChatAI SDK", url: "https://github.com/GetStream/stream-chat-swift-ai")
        let s6 = WebSearchSource(title: "Materials & Liquid Glass - Apple HIG", url: "https://developer.apple.com/design/human-interface-guidelines/materials")

        let researchParts: [MessageContentPart] = [
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ## Modern AI Chat Client Architecture

                A first-class AI chat client prioritizes layout stability and responsiveness during live token arrival. By decoupling network streaming from high-fidelity rendering, interfaces avoid jarring reflows as headings, lists, and formatted code arrive.
                """,
                sources: [s1]
            ),
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ### Section-Level Evidence & Citations

                In comprehensive research answers, gathering all references in a single footer disconnects claims from their evidence. Presenting quiet, section-specific source indicators directly beside the relevant paragraphs preserves reading flow while enabling on-demand verification.
                """,
                sources: [s2, s3]
            ),
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ### Progressive Multimodal Streaming

                Modern LLMs output structured responses that interleave narrative explanation with search results, tool calls, and media embeds. A typed content-part model allows the user interface to stream and place rich components safely without relying on fragile string parsing or pseudo-Markdown syntax.
                """,
                sources: [s4, s5]
            ),
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ### Fluid System Integration with Liquid Glass

                On iOS 26, system presentations emerging from Liquid Glass controls seamlessly morph from the invoking button into the expanded menu. Adhering to Apple's native presentation behaviors ensures the application feels completely integrated with the latest system conventions.
                """,
                sources: [s6]
            ),
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ### Performance & Table View Optimization

                Rendering rich chats on iOS requires careful cell lifecycle management. Combining UITableView caching with fixed-aspect media surfaces prevents geometric jitter during asynchronous loading and scrolling.
                """,
                sources: [s2]
            )
        ]

        let researchChat = Chat.create(
            title: "Web Research + Inline Sources",
            titleState: .manual,
            messages: [
                Message(
                    role: .user,
                    content: "Research what makes a modern AI chat interface feel excellent. Cite the relevant sources throughout the answer."
                ),
                Message(
                    role: .assistant,
                    content: researchParts.compactMap(\.markdown).joined(separator: "\n\n"),
                    webSearchState: WebSearchState(
                        query: "modern AI chat client streaming inline citations Liquid Glass",
                        status: .completed,
                        sources: [s1, s2, s3, s4, s5, s6]
                    ),
                    contentParts: researchParts
                )
            ],
            modelType: currentModel
        )

        let imagesParts: [MessageContentPart] = [
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ### Visualizing Generative Design Systems

                Modern AI interfaces combine structured typography with rich inline visual assets to communicate complex architectures at a glance.
                """
            ),
            MessageContentPart(
                kind: .image,
                url: "bundle://demo-architecture",
                title: "Interface Architecture",
                caption: "Fig 1. Generative canvas rendering with stable 16:9 aspect ratio."
            ),
            MessageContentPart(
                kind: .markdown,
                markdown: """
                The image above is rendered inline with rounded corners and consistent padding. Notice how text continues smoothly beneath the graphic without requiring manual layout shifts.
                """
            )
        ]

        let imagesChat = Chat.create(
            title: "Images in AI Responses",
            titleState: .manual,
            messages: [
                Message(role: .user, content: "Show me an example of an AI response with inline images."),
                Message(
                    role: .assistant,
                    content: imagesParts.compactMap(\.markdown).joined(separator: "\n\n"),
                    contentParts: imagesParts
                )
            ],
            modelType: currentModel
        )

        let videoParts: [MessageContentPart] = [
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ### Video Media Integration

                Below is a playable native video stream powered by AVKit with standard playback controls and stable geometry.
                """
            ),
            MessageContentPart(
                kind: .video,
                url: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8",
                title: "Sample Video Stream",
                caption: "High-definition MP4 stream rendered with standard AVKit player controls."
            ),
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ### Video Presentations & YouTube

                In addition to direct file streams, assistants can embed interactive YouTube presentations directly in the conversation flow.
                """
            ),
            MessageContentPart(
                kind: .youtube,
                url: "https://www.youtube.com/watch?v=kocbm7kO198",
                title: "Explore SwiftUI animations and transitions",
                subtitle: "Apple Developer • WWDC",
                youtubeVideoID: "kocbm7kO198"
            ),
            MessageContentPart(
                kind: .markdown,
                markdown: """
                The embedded player renders inline with a 16:9 aspect ratio and does not interrupt the surrounding conversation.
                """
            )
        ]

        let videoChat = Chat.create(
            title: "Video & YouTube",
            titleState: .manual,
            messages: [
                Message(role: .user, content: "Demonstrate video playback and embedded YouTube videos."),
                Message(
                    role: .assistant,
                    content: videoParts.compactMap(\.markdown).joined(separator: "\n\n"),
                    contentParts: videoParts
                )
            ],
            modelType: currentModel
        )

        let linkParts: [MessageContentPart] = [
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ### Curated Developer References

                Here are the primary developer documentation portals for SwiftUI and native chat architectures:
                """
            ),
            MessageContentPart(
                kind: .linkPreview,
                url: "https://developer.apple.com/xcode/swiftui/",
                title: "SwiftUI - Apple Developer",
                subtitle: "Build better apps across all Apple platforms with the power of Swift.",
                thumbnailURL: "https://developer.apple.com/favicon.ico"
            ),
            MessageContentPart(
                kind: .linkPreview,
                url: "https://github.com/sachaservan/SwiftChat",
                title: "sachaservan/SwiftChat",
                subtitle: "An elegant open-source AI chat client built with Swift and SwiftUI.",
                thumbnailURL: "https://github.githubassets.com/favicons/favicon.png"
            ),
            MessageContentPart(
                kind: .markdown,
                markdown: """
                Both resources provide comprehensive documentation, design guidelines, and reproducible reference samples.
                """
            )
        ]

        let richLinksChat = Chat.create(
            title: "Rich Links",
            titleState: .manual,
            messages: [
                Message(role: .user, content: "Provide rich link previews for SwiftUI and SwiftChat."),
                Message(
                    role: .assistant,
                    content: linkParts.compactMap(\.markdown).joined(separator: "\n\n"),
                    contentParts: linkParts
                )
            ],
            modelType: currentModel
        )

        let mixedParts: [MessageContentPart] = [
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ### Multimodal Architecture for Apple Intelligence

                Modern assistant clients blend reasoning, live web retrieval, and rich interactive media into a single continuous stream.
                """,
                sources: [s1, s3]
            ),
            MessageContentPart(
                kind: .image,
                url: "bundle://demo-architecture",
                title: "Design System Architecture",
                caption: "Fig 1. Spatial computing materials and layout flow."
            ),
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ### Audio & Video Playback Integration

                Media playback components maintain a fixed 16:9 aspect ratio to avoid jumpy row-height calculations during incremental streaming.
                """,
                sources: [s2, s5]
            ),
            MessageContentPart(
                kind: .youtube,
                url: "https://www.youtube.com/watch?v=kocbm7kO198",
                title: "What's new in SwiftUI | WWDC",
                subtitle: "Apple Developer • 24 min",
                youtubeVideoID: "kocbm7kO198"
            ),
            MessageContentPart(
                kind: .linkPreview,
                url: "https://developer.apple.com/documentation/swiftui",
                title: "SwiftUI Documentation - Apple Developer",
                subtitle: "Declarative framework for building apps across Apple platforms.",
                thumbnailURL: "https://developer.apple.com/favicon.ico"
            ),
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ### Conclusion & Synthesis

                Combining structured content parts with native Liquid Glass controls ensures the client remains responsive, accessible, and aligned with iOS 26 conventions.
                """,
                sources: [s1, s2]
            )
        ]

        let mixedMediaChat = Chat.create(
            title: "Mixed Media Research",
            titleState: .manual,
            messages: [
                Message(role: .user, content: "Synthesize multimodal research with inline sources, images, YouTube, and rich links."),
                Message(
                    role: .assistant,
                    content: mixedParts.compactMap(\.markdown).joined(separator: "\n\n"),
                    webSearchState: WebSearchState(
                        query: "multimodal Apple intelligence SwiftUI rich media",
                        status: .completed,
                        sources: [s1, s2, s3, s5]
                    ),
                    contentParts: mixedParts
                )
            ],
            modelType: currentModel
        )

        let markdownChat = Chat.create(
            title: "Markdown, Code & Math",
            titleState: .manual,
            messages: [
                Message(role: .user, content: "Show me a rich answer with Markdown, code and math."),
                Message(
                    role: .assistant,
                    content: """
                    ## Rich response

                    SwiftChat renders **bold**, *italic*, lists, links and code.

                    - Streaming-friendly Markdown
                    - Syntax-highlighted code
                    - Native LaTeX rendering

                    \\(E = mc^2\\)

                    ```swift
                    struct AgentReply: View {
                        let text: String
                        var body: some View { Text(text) }
                    }
                    ```
                    """,
                    generationTimeSeconds: 1.4
                )
            ],
            modelType: currentModel
        )

        let reasoningChat = Chat.create(
            title: "Reasoning / Thinking",
            titleState: .manual,
            messages: [
                Message(role: .user, content: "Compare two approaches and explain the conclusion."),
                Message(
                    role: .assistant,
                    content: "The second approach is preferable because it keeps the UI responsive while isolating network state.",
                    thoughts: """
                    I first separated the UI problem from the transport problem.

                    Then I compared state ownership, cancellation behavior, and how each option behaves during a long streamed response.

                    The second approach has fewer cross-layer dependencies, so it is the cleaner default.
                    """,
                    isThinking: false,
                    isCollapsed: false,
                    generationTimeSeconds: 5.2
                )
            ],
            modelType: currentModel
        )

        let tinyPNG = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9Wl2nKQAAAAASUVORK5CYII="
        let imageAttachment = Attachment(
            type: .image,
            fileName: "design-reference.png",
            mimeType: "image/png",
            base64: tinyPNG,
            thumbnailBase64: tinyPNG,
            description: "A visual reference attached to the prompt.",
            fileSize: 68,
            processingState: .completed
        )
        let docAttachment = Attachment(
            type: .document,
            fileName: "brief.md",
            mimeType: "text/markdown",
            textContent: "# Product brief\nA compact AI assistant interface.",
            description: "Markdown product brief",
            fileSize: 52,
            processingState: .completed
        )
        let attachmentChat = Chat.create(
            title: "Images & Documents",
            titleState: .manual,
            messages: [
                Message(role: .user, content: "Use these files as context.", attachments: [imageAttachment, docAttachment]),
                Message(role: .assistant, content: "I can see both attachments. The image provides visual context, while the document can be injected as text context.")
            ],
            modelType: currentModel
        )

        var errorReply = Message(role: .assistant, content: "A partial response arrived before the request failed.")
        errorReply.streamError = "Demo error: connection interrupted while streaming."
        errorReply.isRequestError = true
        let errorChat = Chat.create(
            title: "Errors & Regenerate",
            titleState: .manual,
            messages: [
                Message(role: .user, content: "Demonstrate an interrupted generation."),
                errorReply
            ],
            modelType: currentModel
        )

        chats = [
            liveStreamingChat,
            researchChat,
            ToolExecutionDemoStore.shared.createDemoChat(modelType: currentModel),
            imagesChat,
            videoChat,
            richLinksChat,
            mixedMediaChat,
            markdownChat,
            reasoningChat,
            attachmentChat,
            errorChat
        ]
        currentChat = liveStreamingChat

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
            self?.restartLiveStreamingDemo()
        }

        setupClient()
        setupNetworkStatusObserver()
    }

    // MARK: - Client Setup

    private func setupClient() {
        client = AppConfig.shared.makeClient()
    }

    func retryClientSetup() {
        guard client == nil else { return }
        guard !isLoading else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.retryClientSetup()
            }
            return
        }
        setupClient()
    }

    private func setupNetworkStatusObserver() {
        networkStatusCancellable = AppConfig.shared.networkMonitor.$isConnected
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] isConnected in
                guard let self = self, isConnected else { return }
                guard self.client == nil else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    self?.retryClientSetup()
                }
            }
    }

    // MARK: - Chat Management

    func createNewChat(language: String? = nil, modelType: ModelType? = nil, focusInput: Bool = true) {
        if isLoading { cancelGeneration() }

        // Check if we already have a blank chat
        if let existing = chats.first(where: { $0.isBlankChat }) {
            selectChat(existing)
            shouldFocusInput = focusInput
            return
        }

        let newChat = Chat.create(modelType: modelType ?? currentModel, language: language)
        chats.insert(newChat, at: 0)
        selectChat(newChat)
        shouldFocusInput = focusInput
    }

    func selectChat(_ chat: Chat) {
        if isLoading { cancelGeneration() }

        if let index = chats.firstIndex(where: { $0.id == chat.id }) {
            currentChat = chats[index]
        } else {
            currentChat = chat
            chats.append(chat)
        }

        if currentModel != chat.modelType {
            changeModel(to: chat.modelType, shouldUpdateChat: false)
        }

        if AppConfig.shared.apiKey == "__DEMO__" && chat.title == "LIVE Streaming Demo" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                self?.restartLiveStreamingDemo()
            }
        }
    }

    func deleteChat(_ id: String) {
        if let index = chats.firstIndex(where: { $0.id == id }) {
            chats.remove(at: index)
        }

        if currentChat?.id == id {
            if let first = chats.first {
                currentChat = first
            } else {
                createNewChat()
            }
        }
    }

    func updateChatTitle(_ id: String, newTitle: String) {
        guard let index = chats.firstIndex(where: { $0.id == id }) else { return }
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            chats[index].title = Chat.placeholderTitle
            chats[index].titleState = .placeholder
        } else {
            chats[index].title = trimmed
            chats[index].titleState = .manual
        }
        if currentChat?.id == id {
            currentChat = chats[index]
        }
    }

    // MARK: - Offline demo streaming

    private func restartLiveStreamingDemo() {
        guard AppConfig.shared.apiKey == "__DEMO__",
              var chat = currentChat,
              chat.title == "LIVE Streaming Demo" else { return }

        demoStreamingTask?.cancel()

        let prompt = Message(
            role: .user,
            content: "Explain what makes a modern AI chat interface feel excellent. Stream the answer live."
        )
        let emptyAssistant = Message(role: .assistant, content: "")
        chat.messages = [prompt, emptyAssistant]
        chat.hasActiveStream = true
        replaceChat(chat)
        currentChat = chat
        isLoading = true
        AgentActivityDemoDriver.start(messageID: emptyAssistant.id)

        let chatID = chat.id
        let full = """
        ## A modern AI chat should feel alive

        The answer should become useful **before generation finishes**. Instead of showing a spinner and suddenly replacing it with a finished wall of text, the interface should reveal the response progressively.

        ### Stable streaming

        New text should arrive continuously while the message keeps a stable layout. Headings, emphasis and lists need to settle naturally as Markdown becomes complete.

        ### Respect the reader

        Auto-scroll should follow the stream only while the reader is already near the bottom. If they scroll upward, the application should stop pulling them back down.

        ### Rich content while generating

        A real AI renderer has to cope with partially complete Markdown, links and structured sections while the model is still speaking.

        ### A responsive composer

        The stop button must remain available during the stream, and the user should be able to continue naturally as soon as generation ends.

        **This paragraph is the end of the local live demo.** No network model is being called; SwiftChat is receiving the text incrementally so you can judge its actual streaming renderer.
        """

        demoStreamingTask = Task { @MainActor [weak self] in
            guard let self else { return }

            try? await Task.sleep(for: .milliseconds(550))
            AgentActivityStore.shared.markAnswerStarted(messageID: emptyAssistant.id)

            for character in full {
                guard !Task.isCancelled else { return }
                guard var activeChat = self.currentChat,
                      activeChat.id == chatID,
                      !activeChat.messages.isEmpty else {
                    self.isLoading = false
                    return
                }

                let last = activeChat.messages.count - 1
                activeChat.messages[last].content.append(character)
                self.replaceChat(activeChat)
                self.currentChat = activeChat

                let delay: UInt64 = character == "\n" ? 34 : 12
                try? await Task.sleep(for: .milliseconds(delay))
            }

            guard var finishedChat = self.currentChat,
                  finishedChat.id == chatID,
                  !finishedChat.messages.isEmpty else {
                self.isLoading = false
                return
            }

            let last = finishedChat.messages.count - 1
            finishedChat.messages[last].generationTimeSeconds = 8.0
            finishedChat.hasActiveStream = false
            self.replaceChat(finishedChat)
            self.currentChat = finishedChat
            self.isLoading = false
            self.demoStreamingTask = nil
            AgentActivityStore.shared.finish(messageID: emptyAssistant.id)
        }
    }

    private func streamOfflineDemoReply(_ full: String, chatID: String) {
        demoStreamingTask?.cancel()
        demoStreamingTask = Task { @MainActor [weak self] in
            guard let self else { return }

            for character in full {
                guard !Task.isCancelled else { return }
                guard var chat = self.currentChat,
                      chat.id == chatID,
                      !chat.messages.isEmpty else {
                    self.isLoading = false
                    return
                }

                let last = chat.messages.count - 1
                chat.messages[last].content.append(character)
                self.replaceChat(chat)
                self.currentChat = chat
                try? await Task.sleep(for: .milliseconds(character == "\n" ? 28 : 10))
            }

            if var chat = self.currentChat, chat.id == chatID, !chat.messages.isEmpty {
                chat.hasActiveStream = false
                self.replaceChat(chat)
                self.currentChat = chat
            }
            self.isLoading = false
            self.demoStreamingTask = nil
        }
    }

    // MARK: - Message Sending

    public func sendMessage(_ text: String) {
        sendMessage(text: text)
    }

    public func sendMessage(text: String) {
        guard !isLoading else { return }
        let hasText = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasAttachments = !pendingAttachments.isEmpty
        guard hasText || hasAttachments else { return }

        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        let messageAttachments = pendingAttachments
        clearPendingAttachments()

        let userMessage = Message(role: .user, content: text, attachments: messageAttachments)
        addMessage(userMessage)

        if AppConfig.shared.apiKey == "__DEMO__" {
            guard var chat = currentChat else { return }
            chat.messages.append(Message(role: .assistant, content: ""))
            chat.hasActiveStream = true
            replaceChat(chat)
            currentChat = chat
            isLoading = true

            let reply = """
            ## Live local response

            This message is being streamed through SwiftChat's **real conversation renderer**.

            Your message was:

            > \(text)

            The demo deliberately feeds the assistant message incrementally, so you can judge layout stability, Markdown rendering and the Stop control exactly as they behave during a model response.
            """
            streamOfflineDemoReply(reply, chatID: chat.id)
            return
        }

        isLoading = true
        generateResponse()
    }

    // MARK: - Attachment Management

    func addImageAttachment(data: Data, fileName: String) {
        isProcessingAttachment = true
        attachmentError = nil

        let attachmentId = UUID().uuidString.lowercased()
        var attachment = Attachment(
            id: attachmentId,
            type: .image,
            fileName: fileName,
            fileSize: Int64(data.count),
            processingState: .processing
        )
        pendingAttachments.append(attachment)

        Task {
            // Simple image processing — resize and compress
            guard let uiImage = UIImage(data: data) else {
                attachment.processingState = .failed
                if let index = pendingAttachments.firstIndex(where: { $0.id == attachmentId }) {
                    pendingAttachments[index] = attachment
                }
                attachmentError = "Failed to load image"
                isProcessingAttachment = false
                return
            }

            let maxDim = Constants.Attachments.maxImageDimension
            let scale = min(maxDim / max(uiImage.size.width, uiImage.size.height), 1.0)
            let newSize = CGSize(width: uiImage.size.width * scale, height: uiImage.size.height * scale)

            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            uiImage.draw(in: CGRect(origin: .zero, size: newSize))
            let resized = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            guard let compressed = resized?.jpegData(compressionQuality: Constants.Attachments.imageCompressionQuality) else {
                attachment.processingState = .failed
                if let index = pendingAttachments.firstIndex(where: { $0.id == attachmentId }) {
                    pendingAttachments[index] = attachment
                }
                attachmentError = "Failed to compress image"
                isProcessingAttachment = false
                return
            }

            attachment.mimeType = Constants.Attachments.defaultImageMimeType
            attachment.base64 = compressed.base64EncodedString()
            attachment.fileSize = Int64(compressed.count)
            attachment.processingState = .completed

            let sizeKB = compressed.count / 1024
            attachment.description = "\(fileName) — \(Int(newSize.width))x\(Int(newSize.height)) JPEG, \(sizeKB) KB"

            // Generate thumbnail
            let thumbMax = Constants.Attachments.thumbnailMaxDimension
            let thumbScale = min(thumbMax / max(newSize.width, newSize.height), 1.0)
            let thumbSize = CGSize(width: newSize.width * thumbScale, height: newSize.height * thumbScale)
            UIGraphicsBeginImageContextWithOptions(thumbSize, false, 1.0)
            resized?.draw(in: CGRect(origin: .zero, size: thumbSize))
            let thumb = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            attachment.thumbnailBase64 = thumb?.jpegData(compressionQuality: 0.6)?.base64EncodedString()

            if let index = pendingAttachments.firstIndex(where: { $0.id == attachmentId }) {
                pendingAttachments[index] = attachment
            }
            if let tb = attachment.thumbnailBase64 {
                pendingImageThumbnails[attachmentId] = tb
            }
            isProcessingAttachment = false
        }
    }

    func addDocumentAttachment(url: URL, fileName: String) {
        isProcessingAttachment = true
        attachmentError = nil

        let attachmentId = UUID().uuidString.lowercased()
        var attachment = Attachment(
            id: attachmentId,
            type: .document,
            fileName: fileName,
            processingState: .processing
        )
        pendingAttachments.append(attachment)

        Task {
            do {
                let accessing = url.startAccessingSecurityScopedResource()
                defer { if accessing { url.stopAccessingSecurityScopedResource() } }

                let text = try String(contentsOf: url, encoding: .utf8)
                let fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0

                attachment.textContent = text
                attachment.fileSize = fileSize
                attachment.processingState = .completed

                if let index = pendingAttachments.firstIndex(where: { $0.id == attachmentId }) {
                    pendingAttachments[index] = attachment
                }
            } catch {
                attachment.processingState = .failed
                if let index = pendingAttachments.firstIndex(where: { $0.id == attachmentId }) {
                    pendingAttachments[index] = attachment
                }
                attachmentError = error.localizedDescription
            }
            isProcessingAttachment = false
        }
    }

    func removePendingAttachment(id: String) {
        pendingAttachments.removeAll { $0.id == id }
        pendingImageThumbnails.removeValue(forKey: id)
        if pendingAttachments.isEmpty { attachmentError = nil }
    }

    func clearPendingAttachments() {
        pendingAttachments.removeAll()
        pendingImageThumbnails.removeAll()
        attachmentError = nil
        isProcessingAttachment = false
    }

    // MARK: - Response Generation

    private func generateResponse() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        isLoading = true

        let assistantMessage = Message(role: .assistant, content: "", isCollapsed: true)
        addMessage(assistantMessage)
        AgentActivityStore.shared.begin(messageID: assistantMessage.id)

        if var chat = currentChat {
            chat.hasActiveStream = true
            replaceChat(chat)
            currentChat = chat
        }

        let streamChatId = currentChat?.id
        let activityMessageID = assistantMessage.id
        currentTask?.cancel()

        currentTask = Task { [weak self] in
            await self?.executeStreamingResponse(streamChatId: streamChatId, activityMessageID: activityMessageID)
        }
    }

    private func executeStreamingResponse(streamChatId: String?, activityMessageID: String) async {
        var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid
            backgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: "CompleteStreamingResponse") {
                UIApplication.shared.endBackgroundTask(backgroundTaskId)
                backgroundTaskId = .invalid
            }
            defer {
                if backgroundTaskId != .invalid {
                    UIApplication.shared.endBackgroundTask(backgroundTaskId)
                }
            }

            var hasRetriedWithFreshKey = false

            retryLoop: do {
                if client == nil { setupClient() }

                guard let client = client else {
                    throw NSError(domain: "ChatApp", code: 1,
                                userInfo: [NSLocalizedDescriptionKey: "Client not initialized. Check your API key."])
                }

                let modelId = currentModel.modelName
                let settingsManager = SettingsManager.shared

                var systemPrompt: String
                if settingsManager.isUsingCustomPrompt && !settingsManager.customSystemPrompt.isEmpty {
                    systemPrompt = settingsManager.customSystemPrompt
                } else {
                    systemPrompt = AppConfig.shared.systemPrompt
                }

                systemPrompt = systemPrompt.replacingOccurrences(of: "{MODEL_NAME}", with: currentModel.fullName)

                let languageToUse = settingsManager.selectedLanguage != "System" ? settingsManager.selectedLanguage : "English"
                systemPrompt = systemPrompt.replacingOccurrences(of: "{LANGUAGE}", with: languageToUse)
                systemPrompt = systemPrompt.replacingOccurrences(of: "{USER_PREFERENCES}", with: "")

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let currentDateTime = dateFormatter.string(from: Date())
                let timezone = TimeZone.current.abbreviation() ?? TimeZone.current.identifier
                systemPrompt = systemPrompt.replacingOccurrences(of: "{CURRENT_DATETIME}", with: currentDateTime)
                systemPrompt = systemPrompt.replacingOccurrences(of: "{TIMEZONE}", with: timezone)

                var processedRules = AppConfig.shared.rules
                if !processedRules.isEmpty {
                    processedRules = processedRules.replacingOccurrences(of: "{MODEL_NAME}", with: currentModel.fullName)
                    processedRules = processedRules.replacingOccurrences(of: "{LANGUAGE}", with: languageToUse)
                    processedRules = processedRules.replacingOccurrences(of: "{USER_PREFERENCES}", with: "")
                    processedRules = processedRules.replacingOccurrences(of: "{CURRENT_DATETIME}", with: currentDateTime)
                    processedRules = processedRules.replacingOccurrences(of: "{TIMEZONE}", with: timezone)
                }

                let chatQuery = ChatQueryBuilder.buildQuery(
                    modelId: modelId,
                    systemPrompt: systemPrompt,
                    rules: processedRules,
                    conversationMessages: self.messages,
                    maxMessages: settingsManager.maxMessages,
                    webSearchEnabled: self.isWebSearchEnabled,
                    isMultimodal: self.currentModel.isMultimodal
                )

                var collectedSources: [WebSearchSource] = []

                let stream: AsyncThrowingStream<ResponseStreamEvent, Error> = client.responses.createResponseStreaming(query: chatQuery)

                var thinkStartTime: Date? = nil
                var thoughtsBuffer = ""
                var isInThinkingMode = false
                var responseContent = ""
                var currentThoughts: String? = nil
                var generationTimeSeconds: TimeInterval? = nil
                let hapticEnabled = SettingsManager.shared.hapticFeedbackEnabled
                var hapticGenerator: UIImpactFeedbackGenerator?
                var lastHapticTime = Date.distantPast
                let minHapticInterval: TimeInterval = 0.1
                let chunker = StreamingMarkdownChunker()
                let thinkingChunker = ThinkingTextChunker()
                var hapticChunkCount = 0
                var hasStartedResponse = false
                var lastUIUpdateTime = Date.distantPast
                let uiUpdateInterval: TimeInterval = 0.033

                await MainActor.run {
                    if let chat = self.currentChat,
                       !chat.messages.isEmpty,
                       let lastIndex = chat.messages.indices.last {
                        responseContent = chat.messages[lastIndex].content
                        currentThoughts = chat.messages[lastIndex].thoughts
                        generationTimeSeconds = chat.messages[lastIndex].generationTimeSeconds
                        isInThinkingMode = chat.messages[lastIndex].isThinking
                    }
                    if hapticEnabled {
                        hapticGenerator = UIImpactFeedbackGenerator(style: .light)
                        hapticGenerator?.prepare()
                    }
                }

                for try await event in stream {
                    if Task.isCancelled { break }

                    // Haptic feedback
                    if hapticEnabled, let generator = hapticGenerator {
                        if hapticChunkCount < 5 {
                            let now = Date()
                            if now.timeIntervalSince(lastHapticTime) >= minHapticInterval {
                                generator.impactOccurred(intensity: 0.5)
                                lastHapticTime = now
                                hapticChunkCount += 1
                            }
                        }
                        if !isInThinkingMode && !hasStartedResponse {
                            hasStartedResponse = true
                            hapticChunkCount = 0
                        }
                    }

                    var didMutateState = false

                    switch event {
                    case .outputText(.delta(let textEvent)):
                        let content = textEvent.delta
                        if !content.isEmpty {
                            AgentActivityStore.shared.markAnswerStarted(messageID: activityMessageID)
                            if isInThinkingMode {
                                if let startTime = thinkStartTime {
                                    generationTimeSeconds = Date().timeIntervalSince(startTime)
                                }
                                isInThinkingMode = false
                                thinkStartTime = nil
                                thinkingChunker.finalize()
                                currentThoughts = thoughtsBuffer.isEmpty ? nil : thoughtsBuffer
                                Task { @MainActor [weak self] in
                                    ThinkingSummaryService.shared.reset()
                                    self?.thinkingSummary = ""
                                }
                            }
                            responseContent += content
                            chunker.appendToken(content)
                            didMutateState = true
                            if !hasStartedResponse {
                                hasStartedResponse = true
                                hapticChunkCount = 0
                            }
                        }

                    case .reasoningText(.delta(let reasoningEvent)):
                        let text = reasoningEvent.delta
                        if !text.isEmpty {
                            AgentActivityStore.shared.beginReasoning(messageID: activityMessageID)
                            if !isInThinkingMode {
                                isInThinkingMode = true
                                thinkStartTime = Date()
                                Task { @MainActor in ThinkingSummaryService.shared.reset() }
                            }
                            thoughtsBuffer += text
                            thinkingChunker.appendToken(text)
                            currentThoughts = thoughtsBuffer.isEmpty ? nil : thoughtsBuffer
                            didMutateState = true
                            let currentThoughtsForSummary = thoughtsBuffer
                            Task { @MainActor [weak self] in
                                ThinkingSummaryService.shared.generateSummary(thoughts: currentThoughtsForSummary) { summary in
                                    self?.thinkingSummary = summary
                                    AgentActivityStore.shared.updateReasoningSummary(messageID: activityMessageID, summary: summary)
                                }
                            }
                        }

                    case .outputTextAnnotation(.added(let annotationEvent)):
                        if let annotation = annotationEvent.annotation,
                           case .urlCitationBody(let citation) = annotation {
                            let url = citation.url
                            let title = citation.title.isEmpty ? url : citation.title
                            let source = WebSearchSource(title: title, url: url)
                            collectedSources.append(source)
                            AgentActivityStore.shared.beginWebSearch(messageID: activityMessageID)
                            AgentActivityStore.shared.addSearchSource(messageID: activityMessageID, source: source)
                            didMutateState = true
                        }

                    case .webSearchCall(.inProgress(_)), .webSearchCall(.searching(_)):
                        AgentActivityStore.shared.beginWebSearch(messageID: activityMessageID)
                        Task { @MainActor [weak self] in
                            guard let self = self else { return }
                            guard var chat = self.currentChat,
                                  !chat.messages.isEmpty,
                                  let lastIndex = chat.messages.indices.last else { return }
                            if chat.messages[lastIndex].webSearchState == nil {
                                chat.messages[lastIndex].webSearchState = WebSearchState(status: .searching)
                            }
                            self.webSearchSummary = "Searching the web..."
                            self.replaceChat(chat)
                            self.currentChat = chat
                        }

                    case .webSearchCall(.completed(_)):
                        AgentActivityStore.shared.completeWebSearch(messageID: activityMessageID)
                        Task { @MainActor [weak self] in
                            guard let self = self else { return }
                            guard var chat = self.currentChat,
                                  !chat.messages.isEmpty,
                                  let lastIndex = chat.messages.indices.last else { return }
                            chat.messages[lastIndex].webSearchState?.status = .completed
                            self.webSearchSummary = ""
                            self.replaceChat(chat)
                            self.currentChat = chat
                        }

                    default:
                        break
                    }

                    // Throttled UI update
                    let now = Date()
                    if didMutateState && now.timeIntervalSince(lastUIUpdateTime) >= uiUpdateInterval {
                        lastUIUpdateTime = now
                        let currentChunks = chunker.getAllChunks()
                        let currentThinkingChunks = thinkingChunker.getAllChunks()
                        let capturedContent = responseContent
                        let capturedThoughts = currentThoughts
                        let capturedThinking = isInThinkingMode
                        let capturedGenTime = generationTimeSeconds
                        let capturedSources = collectedSources

                        Task { @MainActor [weak self] in
                            guard let self = self else { return }
                            guard self.currentChat?.id == streamChatId else { return }
                            guard var chat = self.currentChat,
                                  chat.hasActiveStream,
                                  !chat.messages.isEmpty,
                                  let lastIndex = chat.messages.indices.last else { return }

                            let processedContent = self.processCitationMarkers(capturedContent, sources: capturedSources)
                            let processedChunks = self.processChunksWithCitations(currentChunks, sources: capturedSources)

                            chat.messages[lastIndex].content = processedContent
                            chat.messages[lastIndex].thoughts = capturedThoughts
                            chat.messages[lastIndex].thinkingChunks = currentThinkingChunks
                            chat.messages[lastIndex].isThinking = capturedThinking
                            chat.messages[lastIndex].generationTimeSeconds = capturedGenTime
                            chat.messages[lastIndex].contentChunks = processedChunks

                            if !capturedSources.isEmpty {
                                var searchState = chat.messages[lastIndex].webSearchState ?? WebSearchState(status: .searching)
                                searchState.sources = capturedSources
                                chat.messages[lastIndex].webSearchState = searchState
                            }

                            self.replaceChat(chat)
                            self.currentChat = chat
                        }
                    }
                }

                // Handle remaining thinking content when stream ends
                if isInThinkingMode && !thoughtsBuffer.isEmpty {
                    currentThoughts = thoughtsBuffer.isEmpty ? nil : thoughtsBuffer
                    if responseContent.isEmpty {
                        responseContent = thoughtsBuffer
                        currentThoughts = nil
                    }
                    if let startTime = thinkStartTime { generationTimeSeconds = Date().timeIntervalSince(startTime) }
                    isInThinkingMode = false
                }

                // Finalize message
                await MainActor.run {
                    guard var chat = self.currentChat, chat.id == streamChatId else {
                        self.isLoading = false
                        return
                    }
                    chat.hasActiveStream = false

                    ThinkingSummaryService.shared.reset()
                    self.thinkingSummary = ""
                    self.webSearchSummary = ""

                    if !chat.messages.isEmpty, let lastIndex = chat.messages.indices.last {
                        chunker.finalize()
                        thinkingChunker.finalize()
                        let processedContent = self.processCitationMarkers(responseContent, sources: collectedSources)
                        chat.messages[lastIndex].content = processedContent
                        chat.messages[lastIndex].thoughts = currentThoughts
                        chat.messages[lastIndex].thinkingChunks = thinkingChunker.getAllChunks()
                        chat.messages[lastIndex].isThinking = false
                        chat.messages[lastIndex].generationTimeSeconds = generationTimeSeconds
                        let processedChunks = self.processChunksWithCitations(chunker.getAllChunks(), sources: collectedSources)
                        chat.messages[lastIndex].contentChunks = processedChunks
                        if !collectedSources.isEmpty {
                            var searchState = chat.messages[lastIndex].webSearchState ?? WebSearchState(status: .searching)
                            searchState.sources = collectedSources
                            chat.messages[lastIndex].webSearchState = searchState
                        }
                    }

                    self.replaceChat(chat)
                    self.currentChat = chat
                    self.isLoading = false
                    AgentActivityStore.shared.finish(messageID: activityMessageID)

                    // Generate title if needed
                    if chat.needsGeneratedTitle && chat.messages.count >= 2 {
                        Task {
                            if let generated = await self.generateLLMTitle(from: chat.messages) {
                                if var updatedChat = self.chats.first(where: { $0.id == chat.id }) {
                                    updatedChat.title = generated
                                    updatedChat.titleState = .generated
                                    self.replaceChat(updatedChat)
                                    if self.currentChat?.id == updatedChat.id {
                                        self.currentChat = updatedChat
                                    }
                                    Chat.triggerSuccessFeedback()
                                }
                            }
                        }
                    }
                }
            } catch {
                let shouldRetry = await MainActor.run {
                    if !hasRetriedWithFreshKey && ChatViewModel.isAuthenticationError(error) { return true }
                    return false
                }

                if shouldRetry {
                    hasRetriedWithFreshKey = true
                    await self.refreshClientForRetry()
                    if await MainActor.run(body: { self.client != nil }) {
                        continue retryLoop
                    }
                }

                await MainActor.run {
                    self.isLoading = false
                    self.thinkingSummary = ""
                    self.webSearchSummary = ""
                    AgentActivityStore.shared.finish(messageID: activityMessageID)

                    if var chat = self.currentChat, chat.id == streamChatId {
                        chat.hasActiveStream = false
                        if !chat.messages.isEmpty {
                            let lastIndex = chat.messages.count - 1
                            chat.messages[lastIndex].streamError = self.formatUserFriendlyError(error)
                            chat.messages[lastIndex].isRequestError = self.isRequestError(error)
                        }
                        self.replaceChat(chat)
                        self.currentChat = chat
                    }
                }
            }
    }

    func cancelGeneration() {
        if let messageID = currentChat?.messages.last?.id {
            AgentActivityStore.shared.finish(messageID: messageID)
        }
        currentTask?.cancel()
        currentTask = nil
        demoStreamingTask?.cancel()
        demoStreamingTask = nil
        isLoading = false
        thinkingSummary = ""
        webSearchSummary = ""

        if var chat = currentChat {
            chat.hasActiveStream = false
            replaceChat(chat)
            currentChat = chat
        }
    }

    func regenerateLastResponse() {
        guard let chat = currentChat, !isLoading else { return }
        guard let lastUserMessageIndex = chat.messages.lastIndex(where: { $0.role == .user }) else { return }

        var updatedChat = chat
        updatedChat.messages = Array(chat.messages.prefix(lastUserMessageIndex + 1))
        replaceChat(updatedChat)
        currentChat = updatedChat

        isScrollInteractionActive = false
        scrollToUserMessageTrigger = UUID()
        generateResponse()
    }

    func editMessage(at messageIndex: Int, newContent: String) {
        guard let chat = currentChat,
              !isLoading,
              messageIndex >= 0,
              messageIndex < chat.messages.count,
              chat.messages[messageIndex].role == .user else { return }

        let trimmedContent = newContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else { return }

        var updatedChat = chat
        updatedChat.messages = Array(chat.messages.prefix(messageIndex))
        replaceChat(updatedChat)
        currentChat = updatedChat

        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        isLoading = true

        let userMessage = Message(role: .user, content: trimmedContent)
        addMessage(userMessage)
        generateResponse()
    }

    func regenerateMessage(at messageIndex: Int) {
        guard let chat = currentChat,
              !isLoading,
              messageIndex >= 0,
              messageIndex < chat.messages.count,
              chat.messages[messageIndex].role == .user else { return }

        var updatedChat = chat
        updatedChat.messages = Array(chat.messages.prefix(messageIndex + 1))
        replaceChat(updatedChat)
        currentChat = updatedChat

        isScrollInteractionActive = false
        scrollToUserMessageTrigger = UUID()
        generateResponse()
    }

    // MARK: - Model Management

    public func changeModel(to modelType: ModelType, shouldUpdateChat: Bool = true) {
        guard modelType != currentModel else { return }
        currentTask?.cancel()
        currentTask = nil
        isLoading = false

        self.currentModel = modelType
        AppConfig.shared.currentModel = modelType

        if shouldUpdateChat, var chat = currentChat {
            chat.modelType = modelType
            replaceChat(chat)
            currentChat = chat
        }
    }

    // MARK: - Thoughts Collapse

    func setThoughtsCollapsed(for messageId: String, collapsed: Bool) {
        guard var chat = currentChat,
              let messageIndex = chat.messages.firstIndex(where: { $0.id == messageId }) else { return }
        guard chat.messages[messageIndex].isCollapsed != collapsed else { return }
        chat.messages[messageIndex].isCollapsed = collapsed
        replaceChat(chat)
        currentChat = chat
    }

    // MARK: - Private Helpers

    private func addMessage(_ message: Message) {
        guard var chat = currentChat else { return }
        chat.messages.append(message)
        replaceChat(chat)
        currentChat = chat
    }

    private func replaceChat(_ updatedChat: Chat) {
        if let index = chats.firstIndex(where: { $0.id == updatedChat.id }) {
            chats[index] = updatedChat
        } else if !updatedChat.isBlankChat {
            chats.insert(updatedChat, at: min(1, chats.count))
        }
    }

    private func refreshClientForRetry() async {
        setupClient()
    }

    private func formatUserFriendlyError(_ error: Error) -> String {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet, NSURLErrorDataNotAllowed:
                return "The Internet connection appears to be offline."
            case NSURLErrorNetworkConnectionLost:
                return "Network connection was lost."
            case NSURLErrorTimedOut:
                return "Request timed out. Please try again."
            default:
                return "Network error. Please check your connection."
            }
        }
        if case OpenAIError.statusError(_, let statusCode) = error {
            switch statusCode {
            case 401:
                return "Invalid API key. Please check your key and try again."
            case 429:
                return "Rate limit exceeded. Please wait a moment and try again."
            case 404:
                return "Model not found. The selected model may not be available on your plan."
            case 500...599:
                return "The server encountered an error. Please try again later."
            default:
                return "Request failed (status \(statusCode)). Please try again."
            }
        }
        if let apiError = error as? APIErrorResponse {
            return apiError.error.message
        }
        return "An error occurred. Please try again."
    }

    private func isRequestError(_ error: Error) -> Bool {
        if case OpenAIError.statusError(_, let statusCode) = error,
           (400...499).contains(statusCode), statusCode != 401 { return true }
        return false
    }

    static func isAuthenticationError(_ error: Error) -> Bool {
        if case OpenAIError.statusError(_, let statusCode) = error, statusCode == 401 { return true }
        if let apiError = error as? APIErrorResponse, apiError.error.code == "invalid_api_key" { return true }
        return false
    }

    private func processChunksWithCitations(_ chunks: [ContentChunk], sources: [WebSearchSource]) -> [ContentChunk] {
        chunks.map { chunk in
            ContentChunk(id: chunk.id, type: chunk.type, content: processCitationMarkers(chunk.content, sources: sources), isComplete: chunk.isComplete)
        }
    }

    private func processCitationMarkers(_ content: String, sources: [WebSearchSource]) -> String {
        guard !sources.isEmpty else { return content }
        guard let regex = Self.citationMarkerRegex else { return content }

        let nsContent = content as NSString
        let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: nsContent.length))
        guard !matches.isEmpty else { return content }

        var result = ""
        var lastEnd = content.startIndex

        for match in matches {
            guard let matchRange = Range(match.range, in: content),
                  let numRange = Range(match.range(at: 1), in: content),
                  let num = Int(content[numRange]) else { continue }

            let index = num - 1
            guard index >= 0, index < sources.count else { continue }
            let source = sources[index]

            let encodedUrl = source.url
                .replacingOccurrences(of: "(", with: "%28")
                .replacingOccurrences(of: ")", with: "%29")
                .replacingOccurrences(of: "|", with: "%7C")
                .replacingOccurrences(of: "~", with: "%7E")
            let encodedTitle = (source.title
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? source.title)
                .replacingOccurrences(of: "(", with: "%28")
                .replacingOccurrences(of: ")", with: "%29")
                .replacingOccurrences(of: "~", with: "%7E")

            result += content[lastEnd..<matchRange.lowerBound]
            result += "[\(num)](#cite-\(num)~\(encodedUrl)~\(encodedTitle))"
            lastEnd = matchRange.upperBound
        }

        result += content[lastEnd...]
        return result
    }
}

// MARK: - LLM Title Generation
extension ChatViewModel {
    fileprivate func generateLLMTitle(from messages: [Message]) async -> String? {
        guard let assistantMessage = messages.first(where: { $0.role == .assistant }),
              !assistantMessage.content.isEmpty else { return nil }

        // Use the title model if available, otherwise skip title generation
        guard let titleModelConfig = AppConfig.shared.titleModel else { return nil }

        let words = assistantMessage.content.split(separator: " ", omittingEmptySubsequences: true)
        let truncatedContent = words.prefix(Constants.TitleGeneration.wordThreshold).joined(separator: " ")

        do {
            guard let client = client else { return nil }

            let query = CreateModelResponseQuery(
                input: .inputItemList([
                    .inputMessage(EasyInputMessage(role: .user, content: .textInput(truncatedContent)))
                ]),
                model: titleModelConfig.modelName,
                instructions: Constants.TitleGeneration.systemPrompt,
                maxOutputTokens: 50,
                stream: true
            )

            var title = ""
            let stream: AsyncThrowingStream<ResponseStreamEvent, Error> = client.responses.createResponseStreaming(query: query)
            for try await event in stream {
                if case .outputText(.delta(let textEvent)) = event {
                    title += textEvent.delta
                }
            }

            let cleaned = title.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\"", with: "")
            return cleaned.isEmpty ? nil : cleaned
        } catch {
            return nil
        }
    }
}
