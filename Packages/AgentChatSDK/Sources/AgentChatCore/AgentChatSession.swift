import Foundation
#if canImport(Combine)
import Combine
#endif

@MainActor
public final class AgentChatSession: ObservableObject {
    @Published public var conversations: [Conversation]
    @Published public var selectedConversationId: ConversationID?
    @Published public var configuration: AgentChatConfiguration
    @Published public var isStreaming: Bool = false
    @Published public var draftText: String = ""
    @Published public var attachments: [Attachment] = []
    @Published public var selectedModel: AgentModel

    public var runtimeProvider: AgentChatRuntimeProvider?
    private var activeStreamTask: Task<Void, Never>?

    public init(
        configuration: AgentChatConfiguration = AgentChatConfiguration(),
        runtimeProvider: AgentChatRuntimeProvider? = nil
    ) {
        self.configuration = configuration
        self.runtimeProvider = runtimeProvider
        self.selectedModel = configuration.defaultModel

        let initialConv = Conversation(
            id: UUID().uuidString.lowercased(),
            title: "New Chat",
            messages: [],
            selectedModel: configuration.defaultModel
        )
        self.conversations = [initialConv]
        self.selectedConversationId = initialConv.id
    }

    // MARK: - Current Conversation Access

    public var currentConversation: Conversation {
        get {
            if let id = selectedConversationId,
               let conv = conversations.first(where: { $0.id == id }) {
                return conv
            }
            if let first = conversations.first {
                return first
            }
            let fresh = Conversation(selectedModel: selectedModel)
            conversations.append(fresh)
            selectedConversationId = fresh.id
            return fresh
        }
        set {
            if let idx = conversations.firstIndex(where: { $0.id == newValue.id }) {
                conversations[idx] = newValue
            } else {
                conversations.append(newValue)
            }
        }
    }

    public var messages: [ChatMessage] {
        currentConversation.messages
    }

    public var runs: [RunID: AgentRun] {
        currentConversation.runs
    }

    // MARK: - Message Actions

    public func sendMessage(_ text: String, attachments: [Attachment] = [], model: AgentModel? = nil) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || !attachments.isEmpty else { return }

        let targetModel = model ?? selectedModel
        var conv = currentConversation

        // 1. Append user message
        let userMsgId = UUID().uuidString.lowercased()
        let userMsg = ChatMessage(
            id: userMsgId,
            conversationId: conv.id,
            role: .user,
            segments: [.init(kind: .markdown(trimmed))],
            attachments: attachments
        )
        conv.messages.append(userMsg)

        // Generate title if first message
        if conv.messages.count == 1 {
            let words = trimmed.components(separatedBy: .whitespacesAndNewlines).prefix(4).joined(separator: " ")
            conv.title = words.isEmpty ? "Chat \(conv.id.prefix(4))" : words
        }

        // 2. Prepare assistant message
        let assistantMsgId = UUID().uuidString.lowercased()
        let runId = UUID().uuidString.lowercased()
        var assistantMsg = ChatMessage(
            id: assistantMsgId,
            conversationId: conv.id,
            role: .assistant,
            segments: [],
            runIds: [runId],
            isStreaming: true
        )
        conv.messages.append(assistantMsg)

        // 3. Create initial run (collapsed by default!)
        conv.runs[runId] = AgentRun(
            id: runId,
            messageId: assistantMsgId,
            status: .running,
            startedAt: Date(),
            groups: [],
            approvals: [],
            isExpanded: false // DEFAULTS TO FALSE
        )

        currentConversation = conv
        isStreaming = true

        // 4. Dispatch to runtime or deterministic generator
        if let runtime = runtimeProvider {
            activeStreamTask = Task { @MainActor in
                do {
                    let stream = try await runtime.sendMessage(
                        chatId: conv.id,
                        content: trimmed,
                        model: targetModel,
                        attachments: attachments
                    )
                    for await event in stream {
                        self.apply(event: event)
                    }
                } catch {
                    self.apply(event: .error(
                        messageId: assistantMsgId,
                        error: AgentChatError(code: "RUNTIME_ERROR", message: error.localizedDescription)
                    ))
                }
                self.isStreaming = false
            }
        } else {
            // Offline fallback streaming reply
            activeStreamTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 300_000_000)
                self.apply(event: .groupStarted(
                    runId: runId,
                    groupId: "research",
                    stage: .research,
                    title: "Researching topic"
                ))
                self.apply(event: .toolRequested(
                    runId: runId,
                    groupId: "research",
                    operationId: "web-search-1",
                    tool: "web_search",
                    title: "Searched 3 websites",
                    arguments: "{\"query\": \"\(trimmed)\"}"
                ))
                try? await Task.sleep(nanoseconds: 400_000_000)
                self.apply(event: .toolCompleted(
                    runId: runId,
                    operationId: "web-search-1",
                    resultSummary: "Retrieved documentation",
                    payload: "{\"status\": \"ok\"}",
                    sources: [
                        WebSearchSource(title: "Apple Developer", url: "https://developer.apple.com"),
                        WebSearchSource(title: "Swift.org", url: "https://swift.org")
                    ]
                ))
                try? await Task.sleep(nanoseconds: 300_000_000)
                self.apply(event: .runFinished(runId: runId, status: .completed))

                let reply = "Here is the response to your request:\n\n**Processed query:** `\(trimmed)`\n\nThe AgentChatSDK architecture is operating offline in deterministic mode."
                for chunk in reply.components(separatedBy: " ") {
                    try? await Task.sleep(nanoseconds: 50_000_000)
                    self.apply(event: .contentDelta(messageId: assistantMsgId, text: chunk + " "))
                }
                self.apply(event: .finished)
                self.isStreaming = false
            }
        }
    }

    public func cancel() {
        activeStreamTask?.cancel()
        activeStreamTask = nil
        isStreaming = false
        if let lastRunId = currentConversation.messages.last?.runIds.last,
           var run = currentConversation.runs[lastRunId] {
            run.status = .cancelled
            run.completedAt = Date()
            currentConversation.runs[lastRunId] = run
        }
        if let lastIdx = currentConversation.messages.indices.last {
            currentConversation.messages[lastIdx].isStreaming = false
        }
    }

    // MARK: - Reducer Dispatch

    public func apply(event: AgentChatStreamEvent) {
        var conv = currentConversation
        AgentEventReducer.reduce(conversation: &conv, event: event)
        currentConversation = conv
    }

    public func handleUserAction(_ action: AgentChatUserAction) {
        switch action.kind {
        case .approve(let reqId):
            apply(event: .approvalResolved(requestId: reqId, status: .approved))
            if let runId = action.context.runId {
                apply(event: .resultProduced(result: AgentResult(
                    runId: runId,
                    messageId: action.context.messageId,
                    kind: .approval,
                    title: "Permission Approved (Simulated — No Real Action Executed)",
                    payload: AgentResultPayload(subtitle: "Request \(reqId) approved.")
                )))
            }
        case .deny(let reqId):
            apply(event: .approvalResolved(requestId: reqId, status: .denied))
        case .retry:
            if let lastUserMsg = currentConversation.messages.last(where: { $0.role == .user }) {
                sendMessage(lastUserMsg.plainTextContent, attachments: lastUserMsg.attachments)
            }
        case .cancel(let runId):
            if let rId = runId {
                apply(event: .runFinished(runId: rId, status: .cancelled))
            } else {
                cancel()
            }
        default:
            break
        }
    }

    // MARK: - Expansion Controls

    public func toggleRunExpansion(runId: RunID) {
        if var run = currentConversation.runs[runId] {
            run.isExpanded.toggle()
            currentConversation.runs[runId] = run
        }
    }

    public func toggleGroupExpansion(runId: RunID, groupId: ActivityGroupID) {
        if var run = currentConversation.runs[runId],
           let gIdx = run.groups.firstIndex(where: { $0.id == groupId }) {
            run.groups[gIdx].isExpanded.toggle()
            currentConversation.runs[runId] = run
        }
    }

    public func toggleOperationExpansion(runId: RunID, operationId: OperationID) {
        if var run = currentConversation.runs[runId] {
            for gIdx in run.groups.indices {
                if let opIdx = run.groups[gIdx].operations.firstIndex(where: { $0.id == operationId }) {
                    run.groups[gIdx].operations[opIdx].isExpanded.toggle()
                    currentConversation.runs[runId] = run
                    return
                }
            }
        }
    }

    // MARK: - Conversation Management

    public func newConversation() {
        cancel()
        let fresh = Conversation(
            title: "New Chat",
            messages: [],
            selectedModel: selectedModel
        )
        conversations.insert(fresh, at: 0)
        selectedConversationId = fresh.id
    }

    public func deleteConversation(id: ConversationID) {
        if let idx = conversations.firstIndex(where: { $0.id == id }) {
            conversations.remove(at: idx)
            if selectedConversationId == id {
                selectedConversationId = conversations.first?.id
            }
        }
        if conversations.isEmpty {
            newConversation()
        }
    }

    public func clearMessages() {
        cancel()
        var conv = currentConversation
        conv.messages.removeAll()
        conv.runs.removeAll()
        currentConversation = conv
    }
}
