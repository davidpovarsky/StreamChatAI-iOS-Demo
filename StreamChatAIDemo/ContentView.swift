import SwiftUI
import StreamChatAI

struct DemoMessage: Identifiable, Equatable {
    enum Role { case user, assistant }
    let id = UUID()
    let role: Role
    var text: String
    var isGenerating = false
}

struct ContentView: View {
    @StateObject private var composer = ComposerViewModel()
    @State private var messages: [DemoMessage] = [
        DemoMessage(role: .assistant, text: "# StreamChatAI 👋\n\nThis is the **real GetStream AI UI package** running natively on iOS.\n\nSend a message below to see streamed Markdown, code highlighting, the AI typing indicator, and the built-in composer.")
    ]
    @State private var isGenerating = false
    @State private var generationTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 18) {
                            ForEach(messages) { message in
                                messageRow(message).id(message.id)
                            }
                            if isGenerating && messages.last?.role == .user {
                                HStack {
                                    AITypingIndicatorView(text: "Thinking")
                                    Spacer()
                                }.padding(.horizontal)
                            }
                        }.padding(.vertical)
                    }
                    .onChange(of: messages) { _ in
                        if let id = messages.last?.id {
                            withAnimation { proxy.scrollTo(id, anchor: .bottom) }
                        }
                    }
                }
                Divider()
                ComposerView(
                    viewModel: composer,
                    isGenerating: isGenerating,
                    onMessageSend: { message in send(message.text) },
                    onStopGenerating: { stopGenerating() }
                )
            }
            .navigationTitle("StreamChatAI")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private func messageRow(_ message: DemoMessage) -> some View {
        if message.role == .user {
            HStack {
                Spacer(minLength: 48)
                Text(message.text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.secondary.opacity(0.14), in: RoundedRectangle(cornerRadius: 18))
            }.padding(.horizontal)
        } else {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "sparkles").font(.title3).frame(width: 28, height: 28)
                StreamingMessageView(content: message.text, isGenerating: message.isGenerating)
                Spacer(minLength: 8)
            }.padding(.horizontal)
        }
    }

    private func stopGenerating() {
        generationTask?.cancel()
        generationTask = nil
        isGenerating = false
        if let index = messages.indices.last, messages[index].role == .assistant {
            messages[index].isGenerating = false
        }
    }

    private func send(_ rawText: String) {
        let text = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isGenerating else { return }
        messages.append(DemoMessage(role: .user, text: text))
        isGenerating = true
        generationTask?.cancel()
        generationTask = Task {
            try? await Task.sleep(nanoseconds: 850_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run { messages.append(DemoMessage(role: .assistant, text: "", isGenerating: true)) }
            let reply = "## Streaming reply\n\nYou wrote:\n\n> \(text)\n\nThis response is being fed into GetStream's **StreamingMessageView** a little at a time.\n\n```swift\nStreamingMessageView(\n    content: text,\n    isGenerating: true\n)\n```\n\nThe composer below is also GetStream's real **ComposerView**. No AI API is being called in this demo; the reply is generated locally so you can test the UI safely."
            for character in reply {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    guard let index = messages.indices.last else { return }
                    messages[index].text.append(character)
                }
                try? await Task.sleep(nanoseconds: 12_000_000)
            }
            guard !Task.isCancelled else { return }
            await MainActor.run {
                if let index = messages.indices.last { messages[index].isGenerating = false }
                isGenerating = false
                generationTask = nil
            }
        }
    }
}
