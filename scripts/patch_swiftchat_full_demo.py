from pathlib import Path

root = Path("upstream/SwiftChat")

# Keep the original SwiftChat UI root and replace only its initial data/runtime with
# deterministic offline demo conversations.
content_view = root / "SwiftChat/ContentView.swift"
content_view.write_text("""import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()

    var body: some View {
        ChatContainer()
            .environmentObject(viewModel)
    }
}
""", encoding="utf-8")

vm_path = root / "SwiftChat/ViewModels/ChatViewModel.swift"
src = vm_path.read_text(encoding="utf-8")

# Dedicated task so the local demo can be cancelled by the normal Stop control.
src = src.replace(
    "    private var currentTask: Task<Void, Error>?\n",
    "    private var currentTask: Task<Void, Error>?\n    private var demoStreamingTask: Task<Void, Never>?\n",
    1,
)

old_init = """        self.isWebSearchEnabled = SettingsManager.shared.webSearchEnabled

        // Create initial blank chat
        let newChat = Chat.create(modelType: currentModel)
        currentChat = newChat
        chats = [newChat]"""

new_init = r'''        self.isWebSearchEnabled = SettingsManager.shared.webSearchEnabled
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
                url: "https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800&auto=format&fit=crop&q=80",
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
                url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
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
                url: "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&auto=format&fit=crop&q=80",
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
        }'''

if old_init not in src:
    raise SystemExit("Could not find SwiftChat init block")
src = src.replace(old_init, new_init, 1)

old_select = """    func selectChat(_ chat: Chat) {
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
    }"""

new_select = """    func selectChat(_ chat: Chat) {
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
    }"""

if old_select not in src:
    raise SystemExit("Could not find selectChat block")
src = src.replace(old_select, new_select, 1)

insert_before_send = """    // MARK: - Message Sending

"""
demo_methods = r'''    // MARK: - Offline demo streaming

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

'''
if insert_before_send not in src:
    raise SystemExit("Message Sending marker not found")
src = src.replace(insert_before_send, demo_methods + insert_before_send, 1)

old_send_prefix = """    func sendMessage(text: String) {
        guard !isLoading else { return }
        let hasText = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasAttachments = !pendingAttachments.isEmpty
        guard hasText || hasAttachments else { return }

        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        isLoading = true

        let messageAttachments = pendingAttachments
        clearPendingAttachments()

        let userMessage = Message(role: .user, content: text, attachments: messageAttachments)
        addMessage(userMessage)

        generateResponse()
    }"""

new_send = r'''    func sendMessage(text: String) {
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
    }'''

if old_send_prefix not in src:
    raise SystemExit("Could not find sendMessage block")
src = src.replace(old_send_prefix, new_send, 1)

old_cancel = """    func cancelGeneration() {
        currentTask?.cancel()
        currentTask = nil
        isLoading = false"""
new_cancel = """    func cancelGeneration() {
        currentTask?.cancel()
        currentTask = nil
        demoStreamingTask?.cancel()
        demoStreamingTask = nil
        isLoading = false"""
if old_cancel not in src:
    raise SystemExit("Could not find cancelGeneration prefix")
src = src.replace(old_cancel, new_cancel, 1)

vm_path.write_text(src, encoding="utf-8")
print("SwiftChat offline demo patched: guaranteed live stream + 10 showcase conversations")
