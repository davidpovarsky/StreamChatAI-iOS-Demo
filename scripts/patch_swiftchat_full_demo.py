from pathlib import Path

root = Path("upstream/SwiftChat")

# Keep the original SwiftChat UI and replace only its initial data/runtime with
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

        var researchMessage = Message(
            role: .assistant,
            content: """
            ## What makes a modern AI chat interface feel excellent

            A strong AI interface becomes useful **while the answer is still arriving**. Progressive rendering should keep headings, lists and emphasis stable instead of making the page jump as new text appears. [1](#cite-1~https%3A%2F%2Fdeveloper.apple.com%2Fxcode%2Fswiftui~SwiftUI)

            ### 1. Live streaming must feel calm

            The conversation should follow the newest text only while the reader is already near the bottom. If the reader scrolls upward, the app should respect that choice. The stop control should remain immediately reachable during generation. [2](#cite-2~https%3A%2F%2Fgithub.com%2Fsachaservan%2FSwiftChat~SwiftChat) [3](#cite-3~https%3A%2F%2Fdeveloper.apple.com%2Fdocumentation%2Fswiftui%2Fscrollview~ScrollView)

            ### 2. Citations belong beside the claims they support

            In a long research answer, collecting every source only at the bottom makes provenance difficult to follow. Citations work better when they are woven through the relevant sections, so a reader can inspect a source without leaving the paragraph they are reading. [4](#cite-4~https%3A%2F%2Fplatform.openai.com%2Fdocs~OpenAI%20Docs)

            That matters even more when different parts of the same answer rely on different evidence. Framework behavior may come from platform documentation, while an implementation pattern may come from an open-source project or SDK sample. [5](#cite-5~https%3A%2F%2Fgithub.com%2FGetStream%2Fchat-ai-samples~GetStream%20AI%20Samples)

            ### 3. Agent activity should remain visible but quiet

            Searches, file reads, tool calls and approvals should appear as lightweight conversation events. The user needs enough visibility to understand what the agent is doing, but the activity UI should never compete with the final answer. [6](#cite-6~https%3A%2F%2Fgithub.com%2FGetStream%2Fstream-chat-swift-ai~StreamChatAI)

            ### 4. The composer is part of the agent experience

            Attachments and secondary actions should stay connected to the message field. On iPad, a source-anchored popover can remain visually attached to the **+** button rather than replacing the conversation with a sheet. [7](#cite-7~https%3A%2F%2Fdeveloper.apple.com%2Fdocumentation%2Fswiftui%2Fview%2Fpopover%28ispresented%3Aattachmentanchor%3Aarrowedge%3Acontent%3A%29~SwiftUI%20Popover)

            ### 5. Rich rendering needs to survive the stream

            Markdown, code, math and links should remain readable before generation completes. That is where an AI-specific renderer differs from simply dropping a finished string into a normal text view. [8](#cite-8~https%3A%2F%2Fdeveloper.apple.com%2Fdesign%2Fhuman-interface-guidelines~Human%20Interface%20Guidelines)

            ### Bottom line

            The strongest experience combines **stable live streaming, section-level citations, inline source inspection, rich rendering and an anchored composer menu**. Each detail is small, but together they determine whether the assistant feels polished. [2](#cite-2~https%3A%2F%2Fgithub.com%2Fsachaservan%2FSwiftChat~SwiftChat) [7](#cite-7~https%3A%2F%2Fdeveloper.apple.com%2Fdocumentation%2Fswiftui%2Fview%2Fpopover%28ispresented%3Aattachmentanchor%3Aarrowedge%3Acontent%3A%29~SwiftUI%20Popover)
            """,
            webSearchState: WebSearchState(
                query: "modern AI chat UI streaming citations composer",
                status: .completed,
                sources: [
                    WebSearchSource(title: "SwiftUI", url: "https://developer.apple.com/xcode/swiftui"),
                    WebSearchSource(title: "SwiftChat", url: "https://github.com/sachaservan/SwiftChat"),
                    WebSearchSource(title: "SwiftUI ScrollView", url: "https://developer.apple.com/documentation/swiftui/scrollview"),
                    WebSearchSource(title: "OpenAI developer documentation", url: "https://platform.openai.com/docs"),
                    WebSearchSource(title: "GetStream AI samples", url: "https://github.com/GetStream/chat-ai-samples"),
                    WebSearchSource(title: "StreamChatAI", url: "https://github.com/GetStream/stream-chat-swift-ai"),
                    WebSearchSource(title: "SwiftUI Popover", url: "https://developer.apple.com/documentation/swiftui/view/popover(isPresented:attachmentAnchor:arrowEdge:content:)"),
                    WebSearchSource(title: "Human Interface Guidelines", url: "https://developer.apple.com/design/human-interface-guidelines")
                ]
            )
        )

        let researchChat = Chat.create(
            title: "Web Research + Inline Sources",
            titleState: .manual,
            messages: [
                Message(
                    role: .user,
                    content: "Research what makes a modern AI chat interface feel excellent. Cite the relevant sources throughout the answer."
                ),
                researchMessage
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

        chats = [liveStreamingChat, researchChat, markdownChat, reasoningChat, attachmentChat, errorChat]
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
print("SwiftChat offline demo patched: guaranteed live stream + long multi-section research")
