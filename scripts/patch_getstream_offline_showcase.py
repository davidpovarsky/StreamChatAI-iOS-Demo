from pathlib import Path

root = Path("upstream/chat-ai-samples/ios/AIComponents")

(root / "AIComponentsApp.swift").write_text(r'''import SwiftUI

@main
struct AIComponentsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
''', encoding="utf-8")

(root / "ContentView.swift").write_text(r'''import SwiftUI
import StreamChatAI

struct DemoConversation: Identifiable, Hashable {
    let id: UUID
    var title: String
    var messages: [DemoMessage]

    init(title: String, messages: [DemoMessage]) {
        self.id = UUID()
        self.title = title
        self.messages = messages
    }
}

struct DemoMessage: Identifiable, Hashable {
    enum Role: Hashable { case user, assistant }
    enum Kind: Hashable {
        case text
        case reasoning(String)
        case search([DemoSource])
        case tool(name: String, detail: String, result: String)
        case approval(name: String, detail: String)
        case attachments([DemoAttachment])
        case genUI
        case error(String)
    }

    let id: UUID
    let role: Role
    var text: String
    var kind: Kind
    var isGenerating: Bool

    init(role: Role, text: String, kind: Kind = .text, isGenerating: Bool = false) {
        self.id = UUID()
        self.role = role
        self.text = text
        self.kind = kind
        self.isGenerating = isGenerating
    }
}

struct DemoSource: Hashable {
    let title: String
    let host: String
}

struct DemoAttachment: Hashable {
    let name: String
    let detail: String
    let icon: String
}

struct ContentView: View {
    @State private var conversations: [DemoConversation] = DemoData.conversations
    @State private var selection: UUID?
    @StateObject private var composer = ComposerViewModel()
    @State private var isGenerating = false
    @State private var activeTask: Task<Void, Never>?
    @State private var approvalState: [UUID: Bool] = [:]

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            conversationPane
        }
        .onAppear {
            if selection == nil {
                selection = conversations.first?.id
            }
            composer.chatOptions = DemoData.chatOptions(composer: composer)
        }
    }

    private var sidebar: some View {
        List(selection: $selection) {
            Section {
                Button {
                    newChat()
                } label: {
                    Label("New chat", systemImage: "square.and.pencil")
                }
                .buttonStyle(.plain)
            }

            Section("Conversations") {
                ForEach(conversations) { conversation in
                    Label(conversation.title, systemImage: "message")
                        .lineLimit(1)
                        .tag(Optional(conversation.id))
                }
            }
        }
        .navigationTitle("Stream AI")
    }

    @ViewBuilder
    private var conversationPane: some View {
        if let index = selectedIndex {
            VStack(spacing: 0) {
                header(for: conversations[index])
                Divider()

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 18) {
                            ForEach(conversations[index].messages) { message in
                                messageView(message, conversationIndex: index)
                                    .id(message.id)
                            }

                            if isGenerating && conversations[index].messages.last?.isGenerating != true {
                                HStack {
                                    AITypingIndicatorView(text: "Thinking")
                                    Spacer()
                                }
                                .padding(.horizontal, 22)
                            }
                        }
                        .padding(.vertical, 18)
                    }
                    .onChange(of: conversations[index].messages.count) { _, _ in
                        if let last = conversations[index].messages.last?.id {
                            withAnimation {
                                proxy.scrollTo(last, anchor: .bottom)
                            }
                        }
                    }
                }

                Divider()

                ComposerView(
                    viewModel: composer,
                    isGenerating: isGenerating,
                    onMessageSend: { data in
                        send(data.text)
                    },
                    onStopGenerating: {
                        stopGenerating()
                    }
                )
            }
        } else {
            ContentUnavailableView(
                "Choose a conversation",
                systemImage: "bubble.left.and.bubble.right",
                description: Text("Select a demo chat from the sidebar.")
            )
        }
    }

    private func header(for conversation: DemoConversation) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(conversation.title)
                    .font(.headline)
                Text("Offline full chat demo • real StreamChatAI components")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Menu {
                Button("Clear chat", role: .destructive) {
                    clearCurrentChat()
                }
                Button("Duplicate demo") {
                    duplicateCurrentChat()
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func messageView(_ message: DemoMessage, conversationIndex: Int) -> some View {
        switch message.role {
        case .user:
            HStack {
                Spacer(minLength: 80)
                Text(message.text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.secondary.opacity(0.14), in: RoundedRectangle(cornerRadius: 18))
            }
            .padding(.horizontal, 22)

        case .assistant:
            VStack(alignment: .leading, spacing: 12) {
                switch message.kind {
                case .text:
                    StreamingMessageView(
                        content: message.text,
                        isGenerating: message.isGenerating
                    )

                case .reasoning(let reasoning):
                    StreamingReasoningView(
                        text: reasoning,
                        isThinking: message.isGenerating,
                        duration: 4.7
                    )
                    StreamingMessageView(
                        content: message.text,
                        isGenerating: message.isGenerating
                    )

                case .search(let sources):
                    statusRow(icon: "globe", title: "Searched the web", detail: "\(sources.count) sources")
                    ForEach(Array(sources.enumerated()), id: \.offset) { _, source in
                        sourceRow(source)
                    }
                    StreamingMessageView(
                        content: message.text,
                        isGenerating: message.isGenerating
                    )

                case .tool(let name, let detail, let result):
                    statusRow(icon: "wrench.and.screwdriver", title: name, detail: detail)
                    resultCard(title: "Tool result", body: result)
                    StreamingMessageView(
                        content: message.text,
                        isGenerating: message.isGenerating
                    )

                case .approval(let name, let detail):
                    approvalCard(messageID: message.id, name: name, detail: detail)

                case .attachments(let attachments):
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 10)], spacing: 10) {
                        ForEach(Array(attachments.enumerated()), id: \.offset) { _, item in
                            attachmentCard(item)
                        }
                    }
                    StreamingMessageView(
                        content: message.text,
                        isGenerating: message.isGenerating
                    )

                case .genUI:
                    generativeUICard
                    StreamingMessageView(
                        content: message.text,
                        isGenerating: message.isGenerating
                    )

                case .error(let detail):
                    StreamingMessageView(
                        content: message.text,
                        isGenerating: false
                    )
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Generation stopped", systemImage: "exclamationmark.triangle.fill")
                            .font(.headline)
                        Text(detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button {
                            retryMessage(conversationIndex: conversationIndex)
                        } label: {
                            Label("Retry response", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(14)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(.horizontal, 22)
            .frame(maxWidth: 840, alignment: .leading)
        }
    }

    private func statusRow(icon: String, title: String, detail: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .frame(width: 26)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold())
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
        .padding(12)
        .background(.secondary.opacity(0.07), in: RoundedRectangle(cornerRadius: 14))
    }

    private func sourceRow(_ source: DemoSource) -> some View {
        HStack {
            Image(systemName: "link.circle.fill")
            VStack(alignment: .leading, spacing: 1) {
                Text(source.title).font(.subheadline.bold())
                Text(source.host).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "arrow.up.right")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 3)
    }

    private func resultCard(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            Text(body)
                .font(.subheadline)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.secondary.opacity(0.07), in: RoundedRectangle(cornerRadius: 14))
    }

    private func approvalCard(messageID: UUID, name: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Agent wants to run \(name)", systemImage: "checkmark.shield")
                .font(.headline)
            Text(detail)
                .font(.callout.monospaced())
                .foregroundStyle(.secondary)

            if let approved = approvalState[messageID] {
                Label(
                    approved ? "Allowed" : "Declined",
                    systemImage: approved ? "checkmark.circle.fill" : "xmark.circle.fill"
                )
                .font(.headline)
            } else {
                HStack {
                    Button("Allow") { approvalState[messageID] = true }
                        .buttonStyle(.borderedProminent)
                    Button("Decline") { approvalState[messageID] = false }
                        .buttonStyle(.bordered)
                }
            }
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func attachmentCard(_ item: DemoAttachment) -> some View {
        HStack(spacing: 10) {
            Image(systemName: item.icon)
                .font(.title3)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name).font(.subheadline.bold()).lineLimit(1)
                Text(item.detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(.secondary.opacity(0.07), in: RoundedRectangle(cornerRadius: 14))
    }

    private var generativeUICard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Jerusalem → London")
                        .font(.title3.bold())
                    Text("Agent-generated interface")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "airplane")
                    .font(.title2)
            }

            Divider()

            HStack {
                metric("Duration", "5h 20m")
                Spacer()
                metric("Weather", "18°")
                Spacer()
                metric("Stops", "Nonstop")
            }

            Button("Choose this option") {}
                .buttonStyle(.borderedProminent)
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private func metric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.headline)
        }
    }

    private var selectedIndex: Int? {
        guard let selection else { return nil }
        return conversations.firstIndex(where: { $0.id == selection })
    }

    private func send(_ raw: String) {
        guard let index = selectedIndex, !isGenerating else { return }
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        conversations[index].messages.append(.init(role: .user, text: text))
        composer.cleanUpData()
        isGenerating = true

        activeTask?.cancel()
        activeTask = Task {
            try? await Task.sleep(for: .milliseconds(650))
            guard !Task.isCancelled else { return }

            await MainActor.run {
                conversations[index].messages.append(.init(
                    role: .assistant,
                    text: "",
                    kind: .reasoning("I am interpreting the request, checking the current conversation state, and choosing the best response format."),
                    isGenerating: true
                ))
            }

            let reply = """
            ## Demo response

            This reply is being streamed through **GetStream's real StreamingMessageView** inside a complete chat interface.

            You can inspect the other conversations in the sidebar for:

            - reasoning
            - search + sources
            - tool calls and results
            - approvals
            - attachments
            - generated UI
            - retry/error states
            """

            for char in reply {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    if let last = conversations[index].messages.indices.last {
                        conversations[index].messages[last].text.append(char)
                    }
                }
                try? await Task.sleep(for: .milliseconds(9))
            }

            await MainActor.run {
                if let last = conversations[index].messages.indices.last {
                    conversations[index].messages[last].isGenerating = false
                }
                isGenerating = false
                activeTask = nil
            }
        }
    }

    private func stopGenerating() {
        activeTask?.cancel()
        activeTask = nil
        isGenerating = false

        if let index = selectedIndex,
           let last = conversations[index].messages.indices.last {
            conversations[index].messages[last].isGenerating = false
        }
    }

    private func retryMessage(conversationIndex: Int) {
        conversations[conversationIndex].messages.append(.init(
            role: .assistant,
            text: "Retry succeeded. The response resumed normally.",
            kind: .text
        ))
    }

    private func newChat() {
        let chat = DemoConversation(
            title: "New conversation",
            messages: [
                .init(
                    role: .assistant,
                    text: "What can I help you with?",
                    kind: .text
                )
            ]
        )
        conversations.insert(chat, at: 0)
        selection = chat.id
        composer.cleanUpData()
    }

    private func clearCurrentChat() {
        guard let index = selectedIndex else { return }
        conversations[index].messages = [
            .init(role: .assistant, text: "Chat cleared. Send a new message.", kind: .text)
        ]
    }

    private func duplicateCurrentChat() {
        guard let index = selectedIndex else { return }
        let duplicate = DemoConversation(
            title: conversations[index].title + " Copy",
            messages: conversations[index].messages
        )
        conversations.insert(duplicate, at: 0)
        selection = duplicate.id
    }
}

enum DemoData {
    static let conversations: [DemoConversation] = [
        DemoConversation(
            title: "Markdown & Streaming",
            messages: [
                .init(role: .user, text: "Show me a rich answer with Markdown, code and a table."),
                .init(
                    role: .assistant,
                    text: """
                    ## Rich answer

                    This uses **StreamingMessageView** inside the actual chat timeline.

                    | Feature | Status |
                    | --- | --- |
                    | Markdown | ✅ |
                    | Tables | ✅ |
                    | Code | ✅ |

                    ```swift
                    struct AssistantMessage: View {
                        let text: String
                        var body: some View { Text(text) }
                    }
                    ```
                    """,
                    kind: .text
                )
            ]
        ),
        DemoConversation(
            title: "Reasoning & Thinking",
            messages: [
                .init(role: .user, text: "Compare two architectures and explain your conclusion."),
                .init(
                    role: .assistant,
                    text: "The second architecture is cleaner because the agent runtime stays independent from the presentation layer.",
                    kind: .reasoning("First I separate UI state from transport state. Then I compare cancellation, persistence, tool execution and how easily each layer can be replaced. The second architecture has fewer cross-layer dependencies.")
                )
            ]
        ),
        DemoConversation(
            title: "Web Research & Sources",
            messages: [
                .init(role: .user, text: "Search the web and summarize what changed."),
                .init(
                    role: .assistant,
                    text: "I found several relevant sources. The useful pattern is to expose search progress separately from the final answer.",
                    kind: .search([
                        .init(title: "GetStream AI Components", host: "getstream.io"),
                        .init(title: "Release notes", host: "github.com"),
                        .init(title: "SwiftUI documentation", host: "developer.apple.com")
                    ])
                )
            ]
        ),
        DemoConversation(
            title: "Agent Tool Calls",
            messages: [
                .init(role: .user, text: "Find my note about MCP and summarize it."),
                .init(
                    role: .assistant,
                    text: "The note describes MCP as the boundary between the model and external capabilities.",
                    kind: .tool(
                        name: "search_notes",
                        detail: "query: MCP",
                        result: "Found 3 matching notes. Opened Notes/AI/MCP.md."
                    )
                )
            ]
        ),
        DemoConversation(
            title: "Tool Approval",
            messages: [
                .init(role: .user, text: "Save this summary to my workspace."),
                .init(
                    role: .assistant,
                    text: "",
                    kind: .approval(
                        name: "write_file",
                        detail: "Notes/AI/summary.md"
                    )
                )
            ]
        ),
        DemoConversation(
            title: "Images & Files",
            messages: [
                .init(role: .user, text: "Analyze these attachments."),
                .init(
                    role: .assistant,
                    text: "The image provides visual context and the document supplies the requirements.",
                    kind: .attachments([
                        .init(name: "reference.jpg", detail: "Image • 2.4 MB", icon: "photo"),
                        .init(name: "brief.pdf", detail: "PDF • 8 pages", icon: "doc.text")
                    ])
                )
            ]
        ),
        DemoConversation(
            title: "Generative UI",
            messages: [
                .init(role: .user, text: "Build me an interactive trip option."),
                .init(
                    role: .assistant,
                    text: "The agent can return a richer interface instead of plain text.",
                    kind: .genUI
                )
            ]
        ),
        DemoConversation(
            title: "Errors & Retry",
            messages: [
                .init(role: .user, text: "Generate a report."),
                .init(
                    role: .assistant,
                    text: "I started generating the report, but the stream was interrupted.",
                    kind: .error("Network connection was interrupted.")
                )
            ]
        )
    ]

    static func chatOptions(composer: ComposerViewModel) -> [ChatOption] {
        var options = [
            ChatOption(id: "image", title: "Create image", description: "Visualize anything", icon: "paintpalette", shortTitle: "Image"),
            ChatOption(id: "research", title: "Deep research", description: "Get a detailed report", icon: "binoculars.circle", shortTitle: "Research"),
            ChatOption(id: "search", title: "Web search", description: "Find real-time info", icon: "network", shortTitle: "Search"),
            ChatOption(id: "study", title: "Study and learn", description: "Learn a concept", icon: "book", shortTitle: "Study"),
            ChatOption(id: "agent", title: "Agent mode", description: "Get work done", icon: "dot.circle.and.cursorarrow", shortTitle: "Agent"),
            ChatOption(id: "files", title: "Add files", description: "Analyze or summarize", icon: "doc", shortTitle: "Files")
        ]

        for index in options.indices {
            options[index].action = { [weak composer] in
                composer?.selectedChatOption = options[index]
                composer?.sheetShown = false
            }
        }

        return options
    }
}
''', encoding="utf-8")

for name in [
    "A2uiInteractionForwarder.swift",
    "A2uiPayload.swift",
    "AIComponentsFactory.swift",
    "AgentService.swift",
    "ClientToolActionHandler.swift",
    "ConversationListView.swift",
    "GenUIView.swift",
    "StreamChatClientTools.swift",
    "TypingIndicatorHandler.swift",
]:
    (root / name).write_text("import Foundation\n", encoding="utf-8")

print("Patched official GetStream sample into a full offline chat application")
