import os
import shutil
from pathlib import Path

root = Path("upstream/SwiftChat")

# 1. Bundle deterministic offline demo image into Assets.xcassets
asset_dir = root / "SwiftChat/Assets.xcassets/demo-architecture.imageset"
asset_dir.mkdir(parents=True, exist_ok=True)

# Copy resource png
src_img = Path("resources/demo-architecture.png")
if src_img.exists():
    shutil.copyfile(src_img, asset_dir / "demo-architecture.png")

# Write Contents.json
contents_json = """{
  "images" : [
    {
      "filename" : "demo-architecture.png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
"""
(asset_dir / "Contents.json").write_text(contents_json, encoding="utf-8")
print("Bundled demo-architecture.imageset into SwiftChat Assets.xcassets")

# 2. Keep clean ContentView
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

# 3. Patch ChatViewModel.swift with showcase conversations & streaming runtime
vm_path = root / "SwiftChat/ViewModels/ChatViewModel.swift"
src = vm_path.read_text(encoding="utf-8")

# Add demoStreamingTask property
target_task = "    private var currentTask: Task<Void, Error>?\n"
repl_task = "    private var currentTask: Task<Void, Error>?\n    private var demoStreamingTask: Task<Void, Never>?\n"
if target_task in src:
    src = src.replace(target_task, repl_task, 1)

old_init = """        self.isWebSearchEnabled = SettingsManager.shared.webSearchEnabled

        // Create initial blank chat
        let newChat = Chat.create(modelType: currentModel)
        currentChat = newChat
        chats = [newChat]"""

new_init = r'''        self.isWebSearchEnabled = SettingsManager.shared.webSearchEnabled
        AppConfig.shared.apiKey = "__DEMO__"

        // MARK: - Showcase 1: LIVE Streaming Demo
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

        // Sources for showcases
        let sAppleDocs = WebSearchSource(title: "TextKit 2 and NSTextAttachment - Apple Developer", url: "https://developer.apple.com/documentation/uikit/nstextattachment")
        let sHIG = WebSearchSource(title: "Human Interface Guidelines - Apple", url: "https://developer.apple.com/design/human-interface-guidelines")
        let sSwiftChat = WebSearchSource(title: "SwiftChat Open Source Client", url: "https://github.com/sachaservan/SwiftChat")
        let sOpenAI = WebSearchSource(title: "OpenAI Developer Platform", url: "https://platform.openai.com/docs")
        let sMaterials = WebSearchSource(title: "Materials & Liquid Glass - Apple HIG", url: "https://developer.apple.com/design/human-interface-guidelines/materials")

        // MARK: - Showcase 2: Agent Activity & Tools (ChatGPT-style timeline)
        let agentAct1 = AgentActivityItem(
            kind: .reasoning,
            status: .completed,
            title: "Thinking",
            summary: "Reviewing task requirements and codebase architecture",
            startedAt: Date().addingTimeInterval(-38),
            completedAt: Date().addingTimeInterval(-35)
        )
        let agentAct2 = AgentActivityItem(
            kind: .github,
            status: .completed,
            title: "Interacted with GitHub",
            summary: "Searched repository for citation and message view components",
            startedAt: Date().addingTimeInterval(-35),
            completedAt: Date().addingTimeInterval(-28),
            toolName: "search_code",
            toolArgumentsJSON: "{\n  \"repository\": \"sachaservan/SwiftChat\",\n  \"query\": \"struct SourcesButton\"\n}",
            toolResultSummary: "Found MessageView.swift, SourcesSheetView, and WebSearchBox.swift"
        )
        let agentAct3 = AgentActivityItem(
            kind: .reasoning,
            status: .completed,
            title: "Inspecting repository structure",
            summary: "Analyzing MessageView, MessageTableView, and ChatModels hierarchy",
            startedAt: Date().addingTimeInterval(-28),
            completedAt: Date().addingTimeInterval(-20)
        )
        let agentAct4 = AgentActivityItem(
            kind: .webSearch,
            status: .completed,
            title: "Searched 1 website",
            summary: "developer.apple.com",
            startedAt: Date().addingTimeInterval(-20),
            completedAt: Date().addingTimeInterval(-12),
            sources: [sAppleDocs]
        )
        let agentAct5 = AgentActivityItem(
            kind: .github,
            status: .completed,
            title: "Inspected SwiftChat UI, models, rendering, and build workflow",
            summary: "Verified NavigationSplitView and Liquid Glass integration",
            startedAt: Date().addingTimeInterval(-12),
            completedAt: Date().addingTimeInterval(-2),
            toolName: "get_file_contents",
            toolArgumentsJSON: "{\n  \"path\": \"SwiftChat/Views/ChatView.swift\"\n}",
            toolResultSummary: "Identified NavigationSplitView structure and cell sizing mechanisms"
        )

        let agentParts: [MessageContentPart] = [
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ## SwiftChat Architectural Synthesis

                Following comprehensive codebase inspection and documentation review, the client architecture demonstrates four key principles for high-performance generative interfaces:
                """
            ),
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ### 1. Baseline Inline Citations

                Section citations are laid out directly at the sentence baseline using TextKit 2 text attachments. When horizontal line width allows, favicons sit naturally on the same final line of the paragraph without reserving artificial vertical height.
                """,
                sources: [sAppleDocs, sHIG]
            ),
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ### 2. Native Liquid Glass Menu

                On iOS 26, the composer '+' control uses the system Liquid Glass style, morphing fluidly into the action menu without modal disruption.
                """,
                sources: [sMaterials]
            ),
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ### 3. Nested Tool Execution Timeline

                Reasoning, web search, and GitHub tool invocations are tracked in a unified activity timeline that automatically collapses upon answer completion while remaining fully inspectable.
                """,
                sources: [sSwiftChat]
            )
        ]

        let agentActivityChat = Chat.create(
            title: "Agent Activity & Tools",
            titleState: .manual,
            messages: [
                Message(
                    role: .user,
                    content: "Investigate how SwiftChat handles streaming responses and citations, then summarize the architectural improvements."
                ),
                Message(
                    role: .assistant,
                    content: agentParts.compactMap(\.markdown).joined(separator: "\n\n"),
                    generationTimeSeconds: 38.0,
                    contentParts: agentParts,
                    activityItems: [agentAct1, agentAct2, agentAct3, agentAct4, agentAct5],
                    activityStartedAt: Date().addingTimeInterval(-38),
                    activityCompletedAt: Date().addingTimeInterval(-2)
                )
            ],
            modelType: currentModel
        )

        // MARK: - Showcase 3: Web Research + Inline Sources
        let researchParts: [MessageContentPart] = [
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ## Modern AI Chat Client Architecture

                A first-class AI chat client prioritizes layout stability and responsiveness during live token arrival. By decoupling network streaming from high-fidelity rendering, interfaces avoid jarring reflows as headings, lists, and formatted code arrive.
                """,
                sources: [sAppleDocs]
            ),
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ### Section-Level Evidence & Citations

                In comprehensive research answers, gathering all references in a single footer disconnects claims from their evidence. Presenting quiet, section-specific source indicators directly at the paragraph end preserves reading flow while enabling on-demand verification.
                """,
                sources: [sSwiftChat, sHIG]
            ),
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ### Progressive Multimodal Streaming

                Modern LLMs output structured responses that interleave narrative explanation with search results, tool calls, and media embeds. A typed content-part model allows the user interface to stream and place rich components safely without relying on fragile string parsing or pseudo-Markdown syntax.
                """,
                sources: [sOpenAI]
            ),
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ### Fluid System Integration with Liquid Glass

                On iOS 26, system presentations emerging from Liquid Glass controls seamlessly morph from the invoking button into the expanded menu. Adhering to Apple's native presentation behaviors ensures the application feels completely integrated with the latest system conventions.
                """,
                sources: [sMaterials]
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
                        sources: [sAppleDocs, sSwiftChat, sHIG, sOpenAI, sMaterials]
                    ),
                    contentParts: researchParts
                )
            ],
            modelType: currentModel
        )

        // MARK: - Showcase 4: Images in AI Responses (bundled deterministic asset)
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
                url: "https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800",
                title: "SwiftChat Client Architecture",
                caption: "Fig 1. Generative client layout architecture with 16:9 aspect ratio.",
                assetName: "demo-architecture"
            ),
            MessageContentPart(
                kind: .markdown,
                markdown: """
                The diagram above is bundled locally within the application bundle. Notice how text continues smoothly beneath the graphic with stable geometry without requiring manual layout shifts.
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

        // MARK: - Showcase 5: Video & YouTube (verified Apple HLS & verified embeddable YouTube)
        let videoParts: [MessageContentPart] = [
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ### Video Media Integration

                Below is a playable native video stream powered by AVKit with standard playback controls and stable 16:9 geometry.
                """
            ),
            MessageContentPart(
                kind: .video,
                url: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8",
                title: "Apple 16:9 Sample HLS Stream",
                caption: "Official Apple HLS reference stream rendered with AVPlayer and VideoPlayer."
            ),
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ### Video Presentations & YouTube

                In addition to direct file streams, assistants can embed interactive YouTube presentations directly in the conversation flow with native WKWebView presentation.
                """
            ),
            MessageContentPart(
                kind: .youtube,
                url: "https://www.youtube.com/watch?v=M7lc1UVf-VE",
                title: "YouTube Developers - Getting Started",
                subtitle: "YouTube Developers Official Reference Player",
                youtubeVideoID: "M7lc1UVf-VE"
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

        // MARK: - Showcase 6: Rich Links
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

        // MARK: - Showcase 7: Mixed Media Research
        let mixedParts: [MessageContentPart] = [
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ### Multimodal Architecture for Apple Intelligence

                Modern assistant clients blend reasoning, live web retrieval, and rich interactive media into a single continuous stream.
                """,
                sources: [sAppleDocs, sHIG]
            ),
            MessageContentPart(
                kind: .image,
                url: "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800",
                title: "Design System Architecture",
                caption: "Fig 1. Spatial computing materials and layout flow.",
                assetName: "demo-architecture"
            ),
            MessageContentPart(
                kind: .markdown,
                markdown: """
                ### Audio & Video Playback Integration

                Media playback components maintain a fixed 16:9 aspect ratio to avoid jumpy row-height calculations during incremental streaming.
                """,
                sources: [sSwiftChat]
            ),
            MessageContentPart(
                kind: .youtube,
                url: "https://www.youtube.com/watch?v=M7lc1UVf-VE",
                title: "YouTube Developers - Reference Presentation",
                subtitle: "YouTube Developers • Official Embed",
                youtubeVideoID: "M7lc1UVf-VE"
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
                sources: [sAppleDocs, sSwiftChat]
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
                        sources: [sAppleDocs, sSwiftChat, sHIG]
                    ),
                    contentParts: mixedParts
                )
            ],
            modelType: currentModel
        )

        // MARK: - Showcase 8: Markdown, Code & Math
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

        // MARK: - Showcase 9: Reasoning / Thinking
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

        // MARK: - Showcase 10: Images & Documents
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

        // MARK: - Showcase 11: Errors & Regenerate
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
            agentActivityChat,
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
    raise SystemExit("Could not find SwiftChat init block in ChatViewModel.swift")
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

        if AppConfig.shared.apiKey == "__DEMO__" {
            if chat.title == "LIVE Streaming Demo" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                    self?.restartLiveStreamingDemo()
                }
            } else if chat.title == "Agent Activity & Tools" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                    self?.restartAgentActivityDemo()
                }
            }
        }
    }"""

if old_select not in src:
    raise SystemExit("Could not find selectChat block in ChatViewModel.swift")
src = src.replace(old_select, new_select, 1)

insert_before_send = """    // MARK: - Message Sending

"""
demo_methods = r'''    // MARK: - Offline demo streaming

    private func restartAgentActivityDemo() {
        guard AppConfig.shared.apiKey == "__DEMO__",
              var chat = currentChat,
              chat.title == "Agent Activity & Tools" else { return }

        demoStreamingTask?.cancel()

        let prompt = Message(
            role: .user,
            content: "Investigate how SwiftChat handles streaming responses and citations, then summarize the architectural improvements."
        )

        let initialAssistant = Message(
            role: .assistant,
            content: "",
            activityItems: [],
            activityStartedAt: Date()
        )
        chat.messages = [prompt, initialAssistant]
        chat.hasActiveStream = true
        replaceChat(chat)
        currentChat = chat
        isLoading = true

        let chatID = chat.id
        demoStreamingTask = Task { @MainActor [weak self] in
            guard let self else { return }

            let sApple = WebSearchSource(title: "TextKit 2 and NSTextAttachment - Apple Developer", url: "https://developer.apple.com/documentation/uikit/nstextattachment")
            let sHIG = WebSearchSource(title: "Human Interface Guidelines - Apple", url: "https://developer.apple.com/design/human-interface-guidelines")
            let sSwiftChat = WebSearchSource(title: "SwiftChat Open Source Client", url: "https://github.com/sachaservan/SwiftChat")
            let sMaterials = WebSearchSource(title: "Materials & Liquid Glass - Apple HIG", url: "https://developer.apple.com/design/human-interface-guidelines/materials")

            // Event 1: Thinking
            try? await Task.sleep(for: .milliseconds(400))
            guard var c1 = self.currentChat, c1.id == chatID, !c1.messages.isEmpty else { return }
            var item1 = AgentActivityItem(kind: .reasoning, status: .running, title: "Thinking", summary: "Reviewing task requirements and codebase architecture", startedAt: Date())
            c1.messages[c1.messages.count - 1].activityItems = [item1]
            self.replaceChat(c1)
            self.currentChat = c1

            // Event 2: GitHub interaction
            try? await Task.sleep(for: .milliseconds(650))
            guard var c2 = self.currentChat, c2.id == chatID, !c2.messages.isEmpty else { return }
            item1.status = .completed
            item1.completedAt = Date()
            var item2 = AgentActivityItem(
                kind: .github,
                status: .running,
                title: "Interacted with GitHub",
                summary: "Searching repository for citation components",
                startedAt: Date(),
                toolName: "search_code",
                toolArgumentsJSON: "{\n  \"repository\": \"sachaservan/SwiftChat\",\n  \"query\": \"struct SourcesButton\"\n}",
                toolResultSummary: "Found MessageView.swift, SourcesSheetView, and WebSearchBox.swift"
            )
            c2.messages[c2.messages.count - 1].activityItems = [item1, item2]
            self.replaceChat(c2)
            self.currentChat = c2

            // Event 3: Inspecting repository structure
            try? await Task.sleep(for: .milliseconds(650))
            guard var c3 = self.currentChat, c3.id == chatID, !c3.messages.isEmpty else { return }
            item2.status = .completed
            item2.completedAt = Date()
            var item3 = AgentActivityItem(kind: .reasoning, status: .running, title: "Inspecting repository structure", summary: "Analyzing MessageView, MessageTableView, and ChatModels", startedAt: Date())
            c3.messages[c3.messages.count - 1].activityItems = [item1, item2, item3]
            self.replaceChat(c3)
            self.currentChat = c3

            // Event 4: Web Search
            try? await Task.sleep(for: .milliseconds(600))
            guard var c4 = self.currentChat, c4.id == chatID, !c4.messages.isEmpty else { return }
            item3.status = .completed
            item3.completedAt = Date()
            var item4 = AgentActivityItem(
                kind: .webSearch,
                status: .completed,
                title: "Searched 1 website",
                summary: "developer.apple.com",
                startedAt: Date(),
                completedAt: Date(),
                sources: [sApple]
            )
            c4.messages[c4.messages.count - 1].activityItems = [item1, item2, item3, item4]
            self.replaceChat(c4)
            self.currentChat = c4

            // Event 5: Final GitHub inspect
            try? await Task.sleep(for: .milliseconds(500))
            guard var c5 = self.currentChat, c5.id == chatID, !c5.messages.isEmpty else { return }
            var item5 = AgentActivityItem(
                kind: .github,
                status: .completed,
                title: "Inspected SwiftChat UI, models, rendering, and build workflow",
                summary: "Verified NavigationSplitView and Liquid Glass integration",
                startedAt: Date(),
                completedAt: Date(),
                toolName: "get_file_contents",
                toolArgumentsJSON: "{\n  \"path\": \"SwiftChat/Views/ChatView.swift\"\n}",
                toolResultSummary: "Identified NavigationSplitView structure and cell sizing mechanisms"
            )
            let lastIdx = c5.messages.count - 1
            c5.messages[lastIdx].activityItems = [item1, item2, item3, item4, item5]
            c5.messages[lastIdx].activityCompletedAt = Date()
            self.replaceChat(c5)
            self.currentChat = c5

            // Stream final answer content parts
            let finalParts: [MessageContentPart] = [
                MessageContentPart(
                    kind: .markdown,
                    markdown: """
                    ## SwiftChat Architectural Synthesis

                    Following comprehensive codebase inspection and documentation review, the client architecture demonstrates four key principles for high-performance generative interfaces:
                    """
                ),
                MessageContentPart(
                    kind: .markdown,
                    markdown: """
                    ### 1. Baseline Inline Citations

                    Section citations are laid out directly at the sentence baseline using TextKit 2 text attachments. When horizontal line width allows, favicons sit naturally on the same final line of the paragraph without reserving artificial vertical height.
                    """,
                    sources: [sApple, sHIG]
                ),
                MessageContentPart(
                    kind: .markdown,
                    markdown: """
                    ### 2. Native Liquid Glass Menu

                    On iOS 26, the composer '+' control uses the system Liquid Glass style, morphing fluidly into the action menu without modal disruption.
                    """,
                    sources: [sMaterials]
                ),
                MessageContentPart(
                    kind: .markdown,
                    markdown: """
                    ### 3. Nested Tool Execution Timeline

                    Reasoning, web search, and GitHub tool invocations are tracked in a unified activity timeline that automatically collapses upon answer completion while remaining fully inspectable.
                    """,
                    sources: [sSwiftChat]
                )
            ]

            try? await Task.sleep(for: .milliseconds(400))
            guard var c6 = self.currentChat, c6.id == chatID, !c6.messages.isEmpty else { return }
            let lIdx = c6.messages.count - 1
            c6.messages[lIdx].contentParts = finalParts
            c6.messages[lIdx].content = finalParts.compactMap(\.markdown).joined(separator: "\n\n")
            c6.messages[lIdx].generationTimeSeconds = 38.0
            c6.hasActiveStream = false
            self.replaceChat(c6)
            self.currentChat = c6
            self.isLoading = false
            self.demoStreamingTask = nil
        }
    }

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
    raise SystemExit("Message Sending marker not found in ChatViewModel.swift")
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
    raise SystemExit("Could not find sendMessage block in ChatViewModel.swift")
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
    raise SystemExit("Could not find cancelGeneration prefix in ChatViewModel.swift")
src = src.replace(old_cancel, new_cancel, 1)

vm_path.write_text(src, encoding="utf-8")
print("SwiftChat offline demo patched: guaranteed live stream + Agent Activity + 10 showcase conversations")
