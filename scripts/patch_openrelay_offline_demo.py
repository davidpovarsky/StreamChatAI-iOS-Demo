from pathlib import Path

root = Path("upstream/Open-Relay/Open UI")

(root / "App/Open_UIApp.swift").write_text(r'''import SwiftUI

@main
struct Open_UIApp: App {
    var body: some Scene {
        WindowGroup {
            OpenRelayOfflineDemoView()
        }
    }
}
''', encoding="utf-8")

(root / "App/OpenRelayOfflineDemoView.swift").write_text(r'''import SwiftUI

private struct DemoChat: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let kind: Kind

    enum Kind: Hashable {
        case streaming
        case reasoning
        case tools
        case rich
        case markdown
    }
}

struct OpenRelayOfflineDemoView: View {
    @State private var chats: [DemoChat] = [
        .init(title: "Live streaming", kind: .streaming),
        .init(title: "Reasoning", kind: .reasoning),
        .init(title: "Tool calls", kind: .tools),
        .init(title: "Rich UI", kind: .rich),
        .init(title: "Markdown + code", kind: .markdown)
    ]
    @State private var selection: DemoChat.ID?
    @State private var prompt = ""
    @State private var streamed = ""
    @State private var isStreaming = false
    @State private var task: Task<Void, Never>?
    @State private var showAddMenu = false

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Section {
                    Button {
                        let chat = DemoChat(title: "New chat", kind: .streaming)
                        chats.insert(chat, at: 0)
                        selection = chat.id
                    } label: {
                        Label("New chat", systemImage: "square.and.pencil")
                    }
                    .buttonStyle(.plain)
                }
                Section("Chats") {
                    ForEach(chats) { chat in
                        Label(chat.title, systemImage: icon(for: chat.kind))
                            .tag(Optional(chat.id))
                    }
                }
            }
            .navigationTitle("Open Relay")
        } detail: {
            VStack(spacing: 0) {
                header
                Divider()
                conversation
                Divider()
                composer
            }
        }
        .onAppear {
            if selection == nil { selection = chats.first?.id }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                if selected?.kind == .streaming { runStream() }
            }
        }
        .onChange(of: selection) { _, _ in
            stopStream()
            if selected?.kind == .streaming {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { runStream() }
            }
        }
    }

    private var selected: DemoChat? {
        chats.first(where: { $0.id == selection })
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(selected?.title ?? "Open Relay")
                    .font(.headline)
                Text("Offline UI demo • original Open Relay renderers")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Menu {
                Button("Restart demo") {
                    if selected?.kind == .streaming { runStream() }
                }
                Button("Clear") { streamed = "" }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private var conversation: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                switch selected?.kind {
                case .streaming:
                    ChatMessageBubble(role: .user) {
                        Text("Show me how Open Relay renders a long AI answer while it is still streaming.")
                    }

                    ChatMessageBubble(role: .assistant) {
                        VStack(alignment: .leading, spacing: 10) {
                            if streamed.isEmpty && isStreaming {
                                BlinkingCursorIndicator()
                            } else {
                                StreamingMarkdownView(
                                    content: streamed,
                                    isStreaming: isStreaming
                                )
                            }
                        }
                    }

                case .reasoning:
                    ChatMessageBubble(role: .user) {
                        Text("Compare two architectures for an AI assistant.")
                    }

                    ChatMessageBubble(role: .assistant) {
                        VStack(alignment: .leading, spacing: 12) {
                            DisclosureGroup {
                                ReasoningText(
                                    text: "I compared the presentation layer, streaming pipeline, tool execution boundary, persistence model, cancellation semantics, and how easily each layer can be replaced without disturbing the rest of the app."
                                )
                                .padding(.top, 8)
                            } label: {
                                Label("Thought for 4.8 seconds", systemImage: "brain")
                                    .font(.subheadline.weight(.medium))
                            }

                            StreamingMarkdownView(
                                content: "## Recommendation\nKeep the **agent runtime independent from the chat presentation layer**. It makes model changes, tool calls and cancellation easier to evolve without rewriting the interface.",
                                isStreaming: false
                            )
                        }
                    }

                case .tools:
                    ChatMessageBubble(role: .user) {
                        Text("Find my project notes and summarize them.")
                    }

                    ChatMessageBubble(role: .assistant) {
                        VStack(alignment: .leading, spacing: 10) {
                            toolCard("search_files", detail: "query: project notes", result: "Found 4 matching files")
                            toolCard("read_file", detail: "Projects/AI/notes.md", result: "Loaded 2,418 characters")
                            StreamingMarkdownView(
                                content: "I found the notes. The main recommendation is to keep **tool execution explicit and inspectable** inside the conversation.",
                                isStreaming: false
                            )
                        }
                    }

                case .rich:
                    ChatMessageBubble(role: .user) {
                        Text("Give me a compact travel option as an interactive card.")
                    }

                    ChatMessageBubble(role: .assistant) {
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Jerusalem → London")
                                            .font(.title3.bold())
                                        Text("Agent-generated rich UI")
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
                                    metric("Stops", "Nonstop")
                                    Spacer()
                                    metric("Weather", "18°")
                                }
                                Button("Choose this option") {}
                                    .buttonStyle(.borderedProminent)
                            }
                            .padding(16)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))

                            StreamingMarkdownView(
                                content: "Open Relay also supports **interactive HTML tool results**, charts, dashboards and inline rich content.",
                                isStreaming: false
                            )
                        }
                    }

                case .markdown:
                    ChatMessageBubble(role: .user) {
                        Text("Show Markdown, a table and code.")
                    }

                    ChatMessageBubble(role: .assistant) {
                        StreamingMarkdownView(
                            content: """
                            ## Rich rendering

                            Open Relay supports **Markdown**, tables, math and code.

                            | Feature | Status |
                            | --- | --- |
                            | Markdown | ✅ |
                            | Tables | ✅ |
                            | Streaming | ✅ |

                            ```swift
                            struct AssistantReply: View {
                                let content: String
                                var body: some View {
                                    StreamingMarkdownView(
                                        content: content,
                                        isStreaming: true
                                    )
                                }
                            }
                            ```
                            """,
                            isStreaming: false
                        )
                    }

                case nil:
                    ContentUnavailableView("Choose a chat", systemImage: "message")
                }
            }
            .padding(.vertical, 18)
        }
    }

    private var composer: some View {
        VStack(spacing: 8) {
            HStack(alignment: .bottom, spacing: 10) {
                Button {
                    showAddMenu.toggle()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 34, height: 34)
                        .background(.thinMaterial, in: Circle())
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showAddMenu, attachmentAnchor: .rect(.bounds), arrowEdge: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        addRow("camera", "Camera")
                        addRow("photo", "Photos")
                        addRow("doc", "Files")
                        addRow("globe", "Web search")
                        addRow("terminal", "Terminal")
                    }
                    .padding(8)
                    .frame(width: 220)
                    .presentationCompactAdaptation(.popover)
                }

                TextField("Message", text: $prompt, axis: .vertical)
                    .lineLimit(1...7)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22))

                Button {
                    if isStreaming {
                        stopStream()
                    } else {
                        if !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            prompt = ""
                            runStream()
                        }
                    }
                } label: {
                    Image(systemName: isStreaming ? "stop.fill" : "arrow.up")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(Color.accentColor, in: Circle())
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 10) {
                Label("Web", systemImage: "globe")
                Label("Tools", systemImage: "wrench.and.screwdriver")
                Label("Voice", systemImage: "waveform")
                Spacer()
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func runStream() {
        stopStream()
        streamed = ""
        isStreaming = true

        let answer = """
        ## Open Relay live streaming

        This answer is being appended **character by character** so you can inspect the app's real streaming Markdown renderer.

        ### Why it feels polished

        The assistant content stays full-width, while user messages remain compact and right-aligned. The renderer keeps the same hierarchy from the streaming state into the completed state, which avoids the visible flash that many chat implementations suffer from.

        ### Rich content during generation

        Lists, headings, emphasis and code can all settle while the response is still arriving.

        ```swift
        for await token in stream {
            content += token
        }
        ```

        The final interface also supports reasoning blocks, tool activity, files, terminal features, rich HTML embeds and voice interactions.

        **This entire conversation is local** — no Open WebUI server is required for this demo.
        """

        task = Task {
            for ch in answer {
                guard !Task.isCancelled else { return }
                await MainActor.run { streamed.append(ch) }
                try? await Task.sleep(for: .milliseconds(ch == "\n" ? 28 : 9))
            }
            await MainActor.run { isStreaming = false }
        }
    }

    private func stopStream() {
        task?.cancel()
        task = nil
        isStreaming = false
    }

    private func icon(for kind: DemoChat.Kind) -> String {
        switch kind {
        case .streaming: "waveform.path"
        case .reasoning: "brain"
        case .tools: "wrench.and.screwdriver"
        case .rich: "rectangle.3.group"
        case .markdown: "text.badge.checkmark"
        }
    }

    private func toolCard(_ name: String, detail: String, result: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "wrench.and.screwdriver")
                Text(name).font(.subheadline.bold())
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
            Text(detail).font(.caption.monospaced()).foregroundStyle(.secondary)
            Divider()
            Text(result).font(.subheadline)
        }
        .padding(12)
        .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
    }

    private func metric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.headline)
        }
    }

    private func addRow(_ icon: String, _ title: String) -> some View {
        Button {
            showAddMenu = false
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon).frame(width: 22)
                Text(title)
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
''', encoding="utf-8")

print("Open Relay patched into a fully offline UI demo")
