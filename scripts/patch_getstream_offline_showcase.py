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

private enum DemoSection: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case streaming = "Streaming + Markdown"
    case reasoning = "Reasoning"
    case search = "Search + Sources"
    case tools = "Tool Calls"
    case approval = "Tool Approval"
    case attachments = "Attachments"
    case genui = "Generative UI"
    case errors = "Errors + Retry"
    case composer = "Composer + Modes"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .overview: "sparkles"
        case .streaming: "text.bubble"
        case .reasoning: "brain.head.profile"
        case .search: "globe"
        case .tools: "wrench.and.screwdriver"
        case .approval: "checkmark.shield"
        case .attachments: "paperclip"
        case .genui: "rectangle.3.group"
        case .errors: "exclamationmark.triangle"
        case .composer: "plus.bubble"
        }
    }
}

struct ContentView: View {
    @State private var selection: DemoSection? = .overview
    @StateObject private var composer = ComposerViewModel()
    @State private var isGenerating = false
    @State private var streamedText = ""
    @State private var demoLog: [String] = []
    @State private var toolApproved: Bool? = nil

    private let fullAnswer = """
    ## A streamed AI response

    This is rendered by GetStream's real **StreamingMessageView**.

    It supports Markdown, links, lists, tables and syntax-highlighted code.

    | Feature | Status |
    | --- | --- |
    | Markdown | ✅ |
    | Code | ✅ |
    | Tables | ✅ |
    | Streaming animation | ✅ |

    ```swift
    let assistant = AIChatAssistant()
    await assistant.stream("Hello")
    ```

    You can keep your own backend or agent runtime and use these UI pieces standalone.
    """

    var body: some View {
        NavigationSplitView {
            List(DemoSection.allCases, selection: $selection) { item in
                Label(item.rawValue, systemImage: item.icon)
                    .tag(Optional(item))
            }
            .navigationTitle("Stream AI")
        } detail: {
            detail
                .navigationTitle(selection?.rawValue ?? "Stream AI")
                .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            composer.chatOptions = chatOptions()
        }
    }

    @ViewBuilder
    private var detail: some View {
        switch selection ?? .overview {
        case .overview: overview
        case .streaming: streamingDemo
        case .reasoning: reasoningDemo
        case .search: searchDemo
        case .tools: toolsDemo
        case .approval: approvalDemo
        case .attachments: attachmentsDemo
        case .genui: genUIDemo
        case .errors: errorDemo
        case .composer: composerDemo
        }
    }

    private var overview: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                hero("Official GetStream AI UI Showcase",
                     subtitle: "Offline showcase built from the official iOS sample's StreamChatAI package. No API key or backend required.")
                feature("StreamingMessageView", "Markdown, code, tables, images and character-by-character streaming.", "text.cursor")
                feature("StreamingReasoningView", "Collapsible reasoning / thinking presentation.", "brain")
                feature("ComposerView", "Attachments, modes, speech input, send and stop-generation controls.", "plus.bubble")
                feature("SuggestionsView", "Conversation starters for empty-state AI experiences.", "sparkles.rectangle.stack")
                feature("AITypingIndicatorView", "Thinking, searching and external-source states.", "ellipsis.message")
                feature("Agent / tool patterns", "Tool call progress, approvals, client actions and results.", "wrench.and.screwdriver")
                feature("GenUI / A2UI sample integration", "Rich interactive UI payloads produced by an agent.", "rectangle.3.group")
            }
            .padding(24)
            .frame(maxWidth: 820, alignment: .leading)
        }
    }

    private var streamingDemo: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    userBubble("Show me a rich streamed response with code and a table.")
                    StreamingMessageView(content: streamedText.isEmpty ? fullAnswer : streamedText, isGenerating: isGenerating)
                    if isGenerating { AITypingIndicatorView(text: "Generating") }
                }
                .padding(24)
                .frame(maxWidth: 820, alignment: .leading)
            }
            HStack {
                Button { startStreaming() } label: {
                    Label(isGenerating ? "Restart" : "Run streaming demo", systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent)
                if isGenerating {
                    Button("Stop") { isGenerating = false }
                        .buttonStyle(.bordered)
                }
            }
            .padding()
        }
    }

    private var reasoningDemo: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                userBubble("Which architecture should I choose for an AI reader app?")
                StreamingReasoningView(
                    text: "I am comparing state ownership, stream cancellation, tool execution boundaries, persistence, and how easily each layer can be replaced without disturbing the reader UI.",
                    isThinking: false,
                    duration: 4.8
                )
                StreamingMessageView(
                    content: "### Recommendation\nKeep the **agent runtime separate from the chat presentation layer**. That lets you replace models, tools or transport without rewriting the conversation UI.",
                    isGenerating: false
                )
            }
            .padding(24)
            .frame(maxWidth: 820, alignment: .leading)
        }
    }

    private var searchDemo: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                userBubble("Search the web and tell me what changed.")
                statusCard(icon: "globe", title: "Searched the web", detail: "4 sources • completed")
                sourceRow("GetStream AI Components", "getstream.io")
                sourceRow("Swift AI SDK release notes", "github.com")
                sourceRow("Apple SwiftUI documentation", "developer.apple.com")
                StreamingMessageView(
                    content: "I found several relevant sources. **The important pattern is that search state is shown separately from the final answer**, so the user can understand what the agent is doing while streaming.",
                    isGenerating: false
                )
            }
            .padding(24)
            .frame(maxWidth: 820, alignment: .leading)
        }
    }

    private var toolsDemo: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                userBubble("Find my note about MCP and summarize it.")
                statusCard(icon: "magnifyingglass", title: "search_notes", detail: "query: MCP")
                resultCard(title: "Tool result", body: "Found 3 matches in your workspace.")
                statusCard(icon: "doc.text", title: "read_note", detail: "Notes/AI/MCP.md")
                resultCard(title: "Tool result", body: "Loaded 1,482 characters.")
                StreamingMessageView(
                    content: "I found the note. It describes **MCP as the boundary between the model and external capabilities**, with authorization handled separately from discovery.",
                    isGenerating: false
                )
            }
            .padding(24)
            .frame(maxWidth: 820, alignment: .leading)
        }
    }

    private var approvalDemo: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                userBubble("Save this summary to my workspace.")
                VStack(alignment: .leading, spacing: 12) {
                    Label("Agent wants to run write_file", systemImage: "checkmark.shield")
                        .font(.headline)
                    Text("Path: Notes/AI/summary.md")
                        .font(.callout.monospaced())
                        .foregroundStyle(.secondary)
                    Text("This action changes data on your device and requires approval.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if let toolApproved {
                        Label(toolApproved ? "Allowed" : "Declined",
                              systemImage: toolApproved ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.headline)
                    } else {
                        HStack {
                            Button("Allow") { self.toolApproved = true }.buttonStyle(.borderedProminent)
                            Button("Decline") { self.toolApproved = false }.buttonStyle(.bordered)
                        }
                    }
                }
                .padding(16)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
                if toolApproved == true {
                    resultCard(title: "write_file completed", body: "Saved Notes/AI/summary.md")
                }
            }
            .padding(24)
            .frame(maxWidth: 820, alignment: .leading)
        }
    }

    private var attachmentsDemo: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                userBubble("Analyze these attachments.")
                HStack(spacing: 12) {
                    attachmentCard(icon: "photo", name: "reference.jpg", meta: "Image • 2.4 MB")
                    attachmentCard(icon: "doc.text", name: "brief.pdf", meta: "PDF • 8 pages")
                }
                AITypingIndicatorView(text: "Reading attachments")
                StreamingMessageView(
                    content: "The image establishes the visual direction, while the PDF supplies the requirements. The composer in the official sample supports **photo picker, camera and file-oriented modes**.",
                    isGenerating: false
                )
            }
            .padding(24)
            .frame(maxWidth: 820, alignment: .leading)
        }
    }

    private var genUIDemo: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                userBubble("Build me a compact trip planner card.")
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Jerusalem → London").font(.title3.bold())
                            Text("Interactive agent-generated UI").foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "airplane").font(.title2)
                    }
                    Divider()
                    HStack {
                        stat("Duration", "5h 20m")
                        Spacer()
                        stat("Weather", "18°")
                        Spacer()
                        stat("Stops", "Nonstop")
                    }
                    Button("Choose this option") { demoLog.append("GenUI action: choose_trip") }
                        .buttonStyle(.borderedProminent)
                }
                .padding(18)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22))
                Text("The official GetStream sample includes **GenUI / A2UI plumbing** for forwarding interactions from generated interface payloads back to the agent.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ForEach(demoLog, id: \.self) { Text($0).font(.caption.monospaced()) }
            }
            .padding(24)
            .frame(maxWidth: 820, alignment: .leading)
        }
    }

    private var errorDemo: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                userBubble("Generate a report.")
                StreamingMessageView(
                    content: "I started generating the report, but the stream was interrupted after the first section.",
                    isGenerating: false
                )
                VStack(alignment: .leading, spacing: 10) {
                    Label("Generation stopped", systemImage: "exclamationmark.triangle.fill").font(.headline)
                    Text("Network connection was interrupted.").foregroundStyle(.secondary)
                    Button {
                        startStreaming()
                        selection = .streaming
                    } label: {
                        Label("Retry response", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.bordered)
                }
                .padding(16)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
            }
            .padding(24)
            .frame(maxWidth: 820, alignment: .leading)
        }
    }

    private var composerDemo: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    hero("Full composer", subtitle: "Tap + to inspect the modes. Type anything and Send to receive a local simulated response.")
                    SuggestionsView(
                        suggestions: [
                            "Research the latest SwiftUI changes",
                            "Analyze a document",
                            "Use agent mode to plan a task",
                            "Create an image prompt"
                        ],
                        onMessageSend: { data in localSend(data.text) }
                    )
                    ForEach(demoLog, id: \.self) { entry in
                        resultCard(title: "Conversation event", body: entry)
                    }
                }
                .padding(24)
                .frame(maxWidth: 820, alignment: .leading)
            }
            Divider()
            ComposerView(
                viewModel: composer,
                isGenerating: isGenerating,
                onMessageSend: { data in localSend(data.text) },
                onStopGenerating: { isGenerating = false }
            )
        }
    }

    private func chatOptions() -> [ChatOption] {
        [
            ChatOption(id: "image", title: "Create image", description: "Visualize anything", icon: "paintpalette", shortTitle: "Image"),
            ChatOption(id: "research", title: "Deep research", description: "Get a detailed report", icon: "binoculars.circle", shortTitle: "Research"),
            ChatOption(id: "search", title: "Web search", description: "Find real-time info", icon: "network", shortTitle: "Search"),
            ChatOption(id: "study", title: "Study and learn", description: "Learn a concept", icon: "book", shortTitle: "Study"),
            ChatOption(id: "agent", title: "Agent mode", description: "Get work done", icon: "dot.circle.and.cursorarrow", shortTitle: "Agent"),
            ChatOption(id: "files", title: "Add files", description: "Analyze or summarize", icon: "doc", shortTitle: "Files")
        ]
    }

    private func startStreaming() {
        streamedText = ""
        isGenerating = true
        Task {
            for char in fullAnswer {
                guard isGenerating else { return }
                await MainActor.run { streamedText.append(char) }
                try? await Task.sleep(for: .milliseconds(10))
            }
            await MainActor.run { isGenerating = false }
        }
    }

    private func localSend(_ text: String) {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        demoLog.append("You: \(clean)")
        isGenerating = true
        Task {
            try? await Task.sleep(for: .milliseconds(650))
            await MainActor.run {
                demoLog.append("AI: Local demo response — no backend was called.")
                isGenerating = false
            }
        }
        composer.cleanUpData()
    }

    private func hero(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.largeTitle.bold())
            Text(subtitle).font(.title3).foregroundStyle(.secondary)
        }
    }

    private func feature(_ title: String, _ body: String, _ icon: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon).font(.title2).frame(width: 32)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.headline)
                Text(body).foregroundStyle(.secondary)
            }
        }
    }

    private func userBubble(_ text: String) -> some View {
        HStack {
            Spacer(minLength: 80)
            Text(text)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.secondary.opacity(0.13), in: RoundedRectangle(cornerRadius: 18))
        }
    }

    private func statusCard(icon: String, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).frame(width: 28)
            VStack(alignment: .leading) {
                Text(title).font(.headline)
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func resultCard(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.caption.bold()).foregroundStyle(.secondary)
            Text(body)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
    }

    private func sourceRow(_ title: String, _ host: String) -> some View {
        HStack {
            Image(systemName: "link.circle.fill")
            VStack(alignment: .leading) {
                Text(title).font(.subheadline.bold())
                Text(host).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "arrow.up.right")
        }
        .padding(.vertical, 4)
    }

    private func attachmentCard(icon: String, name: String, meta: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon).font(.title2)
            Text(name).font(.headline).lineLimit(1)
            Text(meta).font(.caption).foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func stat(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.headline)
        }
    }
}
''', encoding="utf-8")

print("Patched official GetStream iOS sample into offline full showcase")
