from pathlib import Path

root = Path("upstream/SwiftChat")
content_view = root / "SwiftChat/ContentView.swift"
content_view.write_text('''import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()

    var body: some View {
        ChatContainer()
            .environmentObject(viewModel)
    }
}
''', encoding="utf-8")

vm_path = root / "SwiftChat/ViewModels/ChatViewModel.swift"
src = vm_path.read_text(encoding="utf-8")

old_init = '''self.isWebSearchEnabled = SettingsManager.shared.webSearchEnabled

        // Create initial blank chat
        let newChat = Chat.create(modelType: currentModel)
        currentChat = newChat
        chats = [newChat]'''

new_init = '''self.isWebSearchEnabled = SettingsManager.shared.webSearchEnabled
        AppConfig.shared.apiKey = "__DEMO__"

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

                    \\\\(E = mc^2\\\\)

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

        var searchMessage = Message(
            role: .assistant,
            content: "I found three relevant sources. The newest release adds a redesigned chat surface and richer streaming behavior.",
            webSearchState: WebSearchState(
                query: "latest Swift AI chat UI",
                status: .completed,
                sources: [
                    WebSearchSource(title: "Framework documentation", url: "https://example.com/docs"),
                    WebSearchSource(title: "Release notes", url: "https://example.com/releases"),
                    WebSearchSource(title: "API reference", url: "https://example.com/api")
                ]
            )
        )
        searchMessage.urlFetches = [
            URLFetchState(url: "https://example.com/docs", status: .completed),
            URLFetchState(url: "https://example.com/releases", status: .completed)
        ]
        searchMessage.annotations = [
            Annotation(
                type: "url_citation",
                url_citation: URLCitation(
                    title: "Framework documentation",
                    url: "https://example.com/docs",
                    start_index: 0,
                    end_index: 24
                )
            )
        ]

        let searchChat = Chat.create(
            title: "Web Search & Citations",
            titleState: .manual,
            messages: [
                Message(role: .user, content: "Search the web and cite what you found."),
                searchMessage
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
            textContent: "# Product brief\\nA compact AI assistant interface.",
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

        let longText = String(repeating: "This is a long user document shown with SwiftChat's expandable long-message treatment. ", count: 18)
        let longChat = Chat.create(
            title: "Long Context",
            titleState: .manual,
            messages: [
                Message(role: .user, content: longText),
                Message(role: .assistant, content: "Long prompts can collapse into an attachment-style preview and expand into a detail sheet.")
            ],
            modelType: currentModel
        )

        chats = [markdownChat, reasoningChat, searchChat, attachmentChat, errorChat, longChat]
        currentChat = markdownChat'''

if old_init not in src:
    raise SystemExit("Could not find SwiftChat init block")
src = src.replace(old_init, new_init, 1)

method = '''private func runLiveStreamingDemoIfNeeded() {
        guard AppConfig.shared.apiKey == "__DEMO__",
              currentChat.title == "LIVE Streaming Demo",
              currentChat.messages.count == 1,
              !isLoading else { return }

        let full = """
        ## Building a modern AI chat UI

        A good assistant should become useful **before the answer is finished**. The renderer needs to handle incomplete Markdown without flashing or waiting for the whole response.

        ### Streaming behavior

        As tokens arrive, headings, lists and emphasis should settle naturally. The conversation should keep scrolling only while the reader is already following the newest content.

        ### Rich content

        The same message can contain prose, **Markdown**, lists and structured sections while the response is still streaming.

        ### Interaction

        The user should always be able to stop generation, copy the completed response, regenerate it, or immediately type the next message.

        This entire answer was streamed locally so you can inspect SwiftChat's live rendering without an API key.
        """

        var reply = Message(role: .assistant, content: "")
        reply.isStreaming = true
        currentChat.messages.append(reply)
        isLoading = true

        Task { @MainActor [weak self] in
            guard let self else { return }
            for character in full {
                guard self.isLoading,
                      self.currentChat.title == "LIVE Streaming Demo",
                      !self.currentChat.messages.isEmpty else { return }
                let last = self.currentChat.messages.count - 1
                self.currentChat.messages[last].content.append(character)
                try? await Task.sleep(for: .milliseconds(character == "\\n" ? 34 : 11))
            }
            if !self.currentChat.messages.isEmpty {
                let last = self.currentChat.messages.count - 1
                self.currentChat.messages[last].isStreaming = false
                self.currentChat.messages[last].generationTimeSeconds = 6.8
            }
            self.isLoading = false
        }
    }

'''
needle = '''func sendMessage(text: String) {
        guard !isLoading else { return }'''
replacement = '''func sendMessage(text: String) {
        guard !isLoading else { return }

        if AppConfig.shared.apiKey == "__DEMO__" {
            let hasText = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let hasAttachments = !pendingAttachments.isEmpty
            guard hasText || hasAttachments else { return }

            let messageAttachments = pendingAttachments
            clearPendingAttachments()
            addMessage(Message(role: .user, content: text, attachments: messageAttachments))
            isLoading = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) { [weak self] in
                guard let self else { return }
                let reply = Message(
                    role: .assistant,
                    content: "This is an **offline demo reply** rendered by SwiftChat's real production message view.\\n\\nTry the sidebar conversations to inspect reasoning, search/citations, attachments, errors, long context, Markdown, code and math.",
                    thoughts: "Demo mode simulated a short reasoning phase locally; no API request was made.",
                    isThinking: false,
                    isCollapsed: true,
                    generationTimeSeconds: 0.6
                )
                self.addMessage(reply)
                self.isLoading = false
            }
            return
        }'''

if needle not in src:
    raise SystemExit("Could not locate sendMessage insertion point")
src = src.replace(needle, method + replacement, 1)

vm_path.write_text(src, encoding="utf-8")
print("SwiftChat patched for full offline showcase")
