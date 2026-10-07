#if canImport(AsyncAlgorithms)
import AsyncAlgorithms
#endif
#if canImport(Collections)
import Collections
#endif
#if canImport(Combine)
import Combine
#endif
import Foundation

@MainActor
public final class AgentChatSession: ObservableObject {
    #if canImport(Combine)
    @Published public private(set) var messages: [AgentMessage] = []
    @Published public private(set) var isGenerating: Bool = false
    @Published public private(set) var currentActivity: AgentActivitySession?
    @Published public private(set) var errorBanner: String?
    @Published public var configuration: AgentChatConfiguration
    #else
    public private(set) var messages: [AgentMessage] = []
    public private(set) var isGenerating: Bool = false
    public private(set) var currentActivity: AgentActivitySession?
    public private(set) var errorBanner: String?
    public var configuration: AgentChatConfiguration
    #endif

    private var activeTask: Task<Void, Never>?

    #if canImport(Collections)
    private var eventBuffer = Deque<AgentActivityEvent>()
    #else
    private var eventBuffer = [AgentActivityEvent]()
    #endif

    #if canImport(Combine)
    private let eventSubject = PassthroughSubject<AgentActivityEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    #endif

    public var onMessageSent: ((AgentMessage) -> Void)?
    public var onGenerationCompleted: ((AgentMessage) -> Void)?

    public init(
        initialMessages: [AgentMessage] = [],
        configuration: AgentChatConfiguration = AgentChatConfiguration()
    ) {
        self.messages = initialMessages
        self.configuration = configuration
        setupEventHandling()
    }

    private func setupEventHandling() {
        #if canImport(Combine)
        eventSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.handleInternalEvent(event)
            }
            .store(in: &cancellables)
        #endif
    }

    public func appendUserMessage(text: String, attachments: [AgentAttachment] = []) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || !attachments.isEmpty else { return }

        let userMessage = AgentMessage(
            role: .user,
            rawText: trimmed,
            generationState: .completed,
            attachments: attachments
        )
        messages.append(userMessage)
        onMessageSent?(userMessage)
    }

    public func startAssistantMessage(id: String = UUID().uuidString) -> String {
        isGenerating = true
        errorBanner = nil
        let assistantMessage = AgentMessage(
            id: id,
            role: .assistant,
            blocks: [],
            rawText: "",
            generationState: .thinking
        )
        messages.append(assistantMessage)
        currentActivity = AgentActivitySession(messageID: id, startedAt: Date(), items: [], answerStarted: false, isExpanded: true)
        return id
    }

    public func appendToken(_ token: String, toMessageID id: String) {
        guard let index = messages.firstIndex(where: { $0.id == id }) else { return }
        messages[index].rawText.append(token)
        messages[index].generationState = .streaming
        if var activity = currentActivity, activity.messageID == id, !activity.answerStarted {
            activity.answerStarted = true
            currentActivity = activity
        }
    }

    public func appendBlock(_ block: AgentMessageBlock, toMessageID id: String) {
        guard let index = messages.firstIndex(where: { $0.id == id }) else { return }
        messages[index].blocks.append(block)
    }

    public func updateBlocks(_ blocks: [AgentMessageBlock], forMessageID id: String) {
        guard let index = messages.firstIndex(where: { $0.id == id }) else { return }
        messages[index].blocks = blocks
    }

    public func setRawText(_ text: String, forMessageID id: String) {
        guard let index = messages.firstIndex(where: { $0.id == id }) else { return }
        messages[index].rawText = text
    }

    public func completeAssistantMessage(id: String) {
        isGenerating = false
        if let index = messages.firstIndex(where: { $0.id == id }) {
            messages[index].generationState = .completed
            if messages[index].blocks.isEmpty && !messages[index].rawText.isEmpty {
                messages[index].blocks = [.markdown(id: UUID().uuidString, text: messages[index].rawText)]
            }
            onGenerationCompleted?(messages[index])
        }
        if var activity = currentActivity, activity.messageID == id {
            activity.completedAt = Date()
            currentActivity = activity
        }
        activeTask = nil
    }

    public func failAssistantMessage(id: String, error: String) {
        isGenerating = false
        errorBanner = error
        if let index = messages.firstIndex(where: { $0.id == id }) {
            messages[index].generationState = .failed(error)
        }
        if var activity = currentActivity, activity.messageID == id {
            activity.completedAt = Date()
            currentActivity = activity
        }
        activeTask = nil
    }

    public func stopGeneration() {
        activeTask?.cancel()
        activeTask = nil
        isGenerating = false
        if let last = messages.last, last.role == .assistant, last.isGenerating {
            if let index = messages.indices.last {
                messages[index].generationState = .cancelled
            }
        }
    }

    public func retryLastAssistantMessage() {
        guard !isGenerating else { return }
        if let last = messages.last, last.role == .assistant {
            messages.removeLast()
        }
    }

    public func publishEvent(_ event: AgentActivityEvent) {
        eventBuffer.append(event)
        #if canImport(Combine)
        eventSubject.send(event)
        #else
        handleInternalEvent(event)
        #endif
    }

    private func handleInternalEvent(_ event: AgentActivityEvent) {
        switch event {
        case .sessionStarted(let messageID):
            currentActivity = AgentActivitySession(messageID: messageID, startedAt: Date(), items: [], answerStarted: false, isExpanded: true)

        case .reasoningStarted(let messageID, let summary):
            guard var activity = currentActivity, activity.messageID == messageID else { return }
            let item = AgentActivityItem(kind: .reasoning, status: .running, title: summary)
            activity.items.append(item)
            currentActivity = activity

        case .reasoningUpdated(let messageID, let summary):
            guard var activity = currentActivity, activity.messageID == messageID else { return }
            if let index = activity.items.firstIndex(where: { $0.kind == .reasoning }) {
                activity.items[index].title = summary
                currentActivity = activity
            }

        case .webSearchStarted(let messageID, let query):
            guard var activity = currentActivity, activity.messageID == messageID else { return }
            if let rIndex = activity.items.firstIndex(where: { $0.kind == .reasoning && $0.status == .running }) {
                activity.items[rIndex].status = .completed
                activity.items[rIndex].completedAt = Date()
            }
            let title = query != nil ? "Searching web for \"\(query!)\"" : "Searching the web"
            let item = AgentActivityItem(kind: .webSearch, status: .running, title: title)
            activity.items.append(item)
            currentActivity = activity

        case .sourceDiscovered(let messageID, let source):
            guard var activity = currentActivity, activity.messageID == messageID else { return }
            if let index = activity.items.firstIndex(where: { $0.kind == .webSearch }) {
                if !activity.items[index].sources.contains(where: { $0.url == source.url }) {
                    activity.items[index].sources.append(source)
                    let count = activity.items[index].sources.count
                    activity.items[index].title = "Searched \(count) \(count == 1 ? "source" : "sources")"
                }
                currentActivity = activity
            }

        case .webSearchCompleted(let messageID):
            guard var activity = currentActivity, activity.messageID == messageID else { return }
            if let index = activity.items.firstIndex(where: { $0.kind == .webSearch }) {
                activity.items[index].status = .completed
                activity.items[index].completedAt = Date()
                currentActivity = activity
            }

        case .toolStarted(let messageID, let toolID, let toolName, let service, let arguments):
            guard var activity = currentActivity, activity.messageID == messageID else { return }
            let item = AgentActivityItem(
                id: toolID,
                kind: .toolCall(service: service),
                status: .running,
                title: "Calling \(toolName)",
                toolName: toolName,
                toolArguments: arguments
            )
            activity.items.append(item)
            currentActivity = activity

        case .toolProgress(let messageID, let toolID, let summary):
            guard var activity = currentActivity, activity.messageID == messageID else { return }
            if let index = activity.items.firstIndex(where: { $0.id == toolID }) {
                activity.items[index].summary = summary
                currentActivity = activity
            }

        case .toolCompleted(let messageID, let toolID, let resultSummary):
            guard var activity = currentActivity, activity.messageID == messageID else { return }
            if let index = activity.items.firstIndex(where: { $0.id == toolID }) {
                activity.items[index].status = .completed
                activity.items[index].completedAt = Date()
                activity.items[index].toolResultSummary = resultSummary
                currentActivity = activity
            }

        case .toolFailed(let messageID, let toolID, let errorSummary):
            guard var activity = currentActivity, activity.messageID == messageID else { return }
            if let index = activity.items.firstIndex(where: { $0.id == toolID }) {
                activity.items[index].status = .failed
                activity.items[index].completedAt = Date()
                activity.items[index].toolResultSummary = errorSummary
                currentActivity = activity
            }

        case .statusAdded(let messageID, let title, let summary):
            guard var activity = currentActivity, activity.messageID == messageID else { return }
            let item = AgentActivityItem(kind: .status, status: .completed, title: title, summary: summary)
            activity.items.append(item)
            currentActivity = activity

        case .answerStarted(let messageID):
            guard var activity = currentActivity, activity.messageID == messageID else { return }
            activity.answerStarted = true
            currentActivity = activity

        case .sessionCompleted(let messageID):
            guard var activity = currentActivity, activity.messageID == messageID else { return }
            activity.completedAt = Date()
            currentActivity = activity
        }
    }

    public func setTask(_ task: Task<Void, Never>) {
        activeTask?.cancel()
        activeTask = task
    }

    public func clearMessages() {
        stopGeneration()
        messages.removeAll()
        currentActivity = nil
        errorBanner = nil
    }
}
