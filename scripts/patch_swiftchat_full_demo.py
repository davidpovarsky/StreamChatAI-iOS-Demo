from pathlib import Path
import re

root = Path("upstream/SwiftChat")
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

src = src.replace(
    "self.isWebSearchEnabled = SettingsManager.shared.webSearchEnabled\n\n        // Create initial blank chat\n        let newChat = Chat.create(modelType: currentModel)\n        currentChat = newChat\n        chats = [newChat]",
    """self.isWebSearchEnabled = SettingsManager.shared.webSearchEnabled
        AppConfig.shared.apiKey = "__DEMO__"

        // Full offline showcase data. These are real SwiftChat Message/Chat models,
        // rendered by the app's production views without calling any API.
        let markdownChat = Chat.create(
            title: "Markdown, Code & Math",
            titleState: .manual,
            messages: [
                Message(role: .user, content: "Show me a rich answer with Markdown, code and math."),
                Message(
                    role: .assistant,
                    content: """
                    ## Rich response

                    SwiftChat renders **bold**, *italic*, lists, links and code blocks.

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
            textContent: "# Product brief\nA compact AI assistant interface.",
            description: "Markdown product brief",
            fileSize: 52,
            processingState: .completed
        )
        let attachmentChat = Chat.create(
            title: "Images & Documents",
            titleState: .manual,
            messages: [
                Message(
                    role: .user,
                    content: "Use these files as context.",
                    attachments: [imageAttachment, docAttachment]
                ),
                Message(
                    role: .assistant,
                    content: "I can see both attachments. The image provides visual context, while the document can be injected as text context."
                )
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
        currentChat = markdownChat"""
)

needle = "func sendMessage(text: String) {\n        guard !isLoading else { return }"
replacement = """func sendMessage(text: String) {
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
                    content: "This is an **offline demo reply** rendered by SwiftChat's real production message view.\n\nTry the sidebar demo conversations to inspect reasoning, search/citations, attachments, errors, long context, Markdown, code and math.",
                    thoughts: "Demo mode simulated a short reasoning phase locally; no API request was made.",
                    isThinking: false,
                    isCollapsed: true,
                    generationTimeSeconds: 0.6
                )
                self.addMessage(reply)
                self.isLoading = false
            }
            return
        }"""
if needle not in src:
    raise SystemExit("Could not locate sendMessage() insertion point")
src = src.replace(needle, replacement, 1)

if "__DEMO__" not in src:
    raise SystemExit("SwiftChat demo patch did not apply")

vm_path.write_text(src, encoding="utf-8")
print("SwiftChat patched for full offline showcase")
