// Sources/AgentUI/Session/AgentUISession.swift
import Foundation
import Observation

@MainActor
@Observable
public final class AgentUISession {
    public var conversations: [AgentConversation]
    public var activeConversationID: AgentConversationID?
    public var messages: [AgentMessage]
    public var currentDraft: AgentDraft
    public var selectedModel: AgentModelDescriptor
    public var availableModels: [AgentModelDescriptor]
    public var isWebSearchEnabled: Bool
    public var isStreaming: Bool
    public var currentRequestID: AgentRequestID?
    public var activitySessions: [AgentMessageID: AgentActivitySession]

    public var runtime: (any AgentUIRuntimeAdapter)?
    private var streamingTask: Task<Void, Never>?

    public init(
        runtime: (any AgentUIRuntimeAdapter)? = nil,
        models: [AgentModelDescriptor] = [.default],
        selectedModel: AgentModelDescriptor = .default,
        conversations: [AgentConversation] = [],
        messages: [AgentMessage] = []
    ) {
        self.runtime = runtime
        self.availableModels = models.isEmpty ? [.default] : models
        self.selectedModel = selectedModel
        self.currentDraft = AgentDraft()
        self.isWebSearchEnabled = true
        self.isStreaming = false
        self.currentRequestID = nil
        self.activitySessions = [:]

        if conversations.isEmpty {
            let initial = AgentConversation(title: "New Chat")
            self.conversations = [initial]
            self.activeConversationID = initial.id
            self.messages = messages
        } else {
            self.conversations = conversations
            self.activeConversationID = conversations.first?.id
            self.messages = messages
        }
    }

    public func apply(_ event: AgentUIEvent) {
        switch event {
        case .requestStarted(let requestID):
            self.currentRequestID = requestID
            self.isStreaming = true

        case .assistantMessageStarted(let messageID):
            if !messages.contains(where: { $0.id == messageID }) {
                let message = AgentMessage(
                    id: messageID,
                    role: .assistant,
                    blocks: [],
                    isStreaming: true
                )
                messages.append(message)
            }

        case .assistantTextDelta(let messageID, let text):
            // Check one-time auto-collapse on first answer token
            if var activity = activitySessions[messageID], !activity.hasAutoCollapsed {
                activity.answerStarted = true
                activity.isExpanded = false
                activity.hasAutoCollapsed = true
                activitySessions[messageID] = activity
            }

            if let index = messages.firstIndex(where: { $0.id == messageID }) {
                messages[index].appendOrUpdateMarkdown(delta: text)
                messages[index].isStreaming = true
            }

        case .assistantTextCompleted(let messageID, let fullText):
            if let index = messages.firstIndex(where: { $0.id == messageID }) {
                messages[index].blocks.removeAll(where: {
                    if case .markdown = $0 { return true }
                    return false
                })
                messages[index].blocks.append(.markdown(id: UUID().uuidString, content: fullText))
            }

        case .reasoningSummaryStarted(let messageID, let itemID, let title):
            let item = AgentActivityItem(
                id: itemID,
                kind: .reasoning,
                status: .running,
                title: title
            )
            recordActivity(messageID: messageID, item: item)

        case .reasoningSummaryUpdated(let messageID, let itemID, let summary):
            updateActivity(messageID: messageID, itemID: itemID) { item in
                item.summary = summary
            }

        case .reasoningSummaryCompleted(let messageID, let itemID):
            updateActivity(messageID: messageID, itemID: itemID) { item in
                item.status = .completed
                item.completedAt = Date()
            }

        case .activityStarted(let messageID, let item):
            recordActivity(messageID: messageID, item: item)

        case .activityUpdated(let messageID, let item):
            updateActivity(messageID: messageID, itemID: item.id) { existing in
                existing = item
            }

        case .activityCompleted(let messageID, let itemID):
            updateActivity(messageID: messageID, itemID: itemID) { item in
                item.status = .completed
                item.completedAt = Date()
            }

        case .toolStarted(let messageID, let execution):
            if let index = messages.firstIndex(where: { $0.id == messageID }) {
                messages[index].blocks.append(.toolExecution(id: execution.id.rawValue, execution: execution))
            }
            let activity = AgentActivityItem(
                id: AgentActivityID(rawValue: execution.id.rawValue),
                kind: .genericTool(toolName: execution.inspection.toolName),
                status: .running,
                title: "Executing \(execution.inspection.toolName)",
                toolName: execution.inspection.toolName,
                toolArguments: execution.inspection.arguments
            )
            recordActivity(messageID: messageID, item: activity)

        case .toolProgress(let messageID, let toolCallID, _, let message):
            updateToolExecution(messageID: messageID, callID: toolCallID) { exec in
                exec.status = .running
            }
            if let message {
                updateActivity(messageID: messageID, itemID: AgentActivityID(rawValue: toolCallID.rawValue)) { act in
                    act.summary = message
                }
            }

        case .toolPresentationUpdated(let messageID, let execution):
            updateToolExecution(messageID: messageID, callID: execution.id) { exec in
                exec = execution
            }

        case .toolCompleted(let messageID, let toolCallID, let resultSummary):
            updateToolExecution(messageID: messageID, callID: toolCallID) { exec in
                exec.status = .completed
                exec.completedAt = Date()
                if let resultSummary {
                    exec = AgentToolExecution(
                        id: exec.id,
                        handlerID: exec.handlerID,
                        inspection: ToolCallInspection(
                            callID: exec.inspection.callID,
                            service: exec.inspection.service,
                            toolName: exec.inspection.toolName,
                            arguments: exec.inspection.arguments,
                            resultSummary: resultSummary,
                            errorMessage: nil
                        ),
                        status: .completed,
                        startedAt: exec.startedAt,
                        completedAt: Date(),
                        isExpanded: exec.isExpanded
                    )
                }
            }
            updateActivity(messageID: messageID, itemID: AgentActivityID(rawValue: toolCallID.rawValue)) { act in
                act.status = .completed
                act.completedAt = Date()
                act.toolResultSummary = resultSummary
            }

        case .toolFailed(let messageID, let toolCallID, let errorMessage):
            updateToolExecution(messageID: messageID, callID: toolCallID) { exec in
                exec.status = .failed
                exec.completedAt = Date()
                exec = AgentToolExecution(
                    id: exec.id,
                    handlerID: exec.handlerID,
                    inspection: ToolCallInspection(
                        callID: exec.inspection.callID,
                        service: exec.inspection.service,
                        toolName: exec.inspection.toolName,
                        arguments: exec.inspection.arguments,
                        resultSummary: exec.inspection.resultSummary,
                        errorMessage: errorMessage
                    ),
                    status: .failed,
                    startedAt: exec.startedAt,
                    completedAt: Date(),
                    isExpanded: exec.isExpanded
                )
            }
            updateActivity(messageID: messageID, itemID: AgentActivityID(rawValue: toolCallID.rawValue)) { act in
                act.status = .failed
                act.completedAt = Date()
                act.summary = errorMessage
            }

        case .sourceDiscovered(let messageID, let source):
            if let index = messages.firstIndex(where: { $0.id == messageID }) {
                if !messages[index].allSources.contains(where: { $0.id == source.id || $0.url == source.url }) {
                    messages[index].allSources.append(source)
                }
            }

        case .sectionSourcesUpdated(let messageID, let sectionID, let sources):
            if let index = messages.firstIndex(where: { $0.id == messageID }) {
                messages[index].sectionSources[sectionID] = sources
                for s in sources {
                    if !messages[index].allSources.contains(where: { $0.id == s.id || $0.url == s.url }) {
                        messages[index].allSources.append(s)
                    }
                }
            }

        case .contentBlockAdded(let messageID, let block):
            if let index = messages.firstIndex(where: { $0.id == messageID }) {
                messages[index].blocks.append(block)
            }

        case .contentBlockUpdated(let messageID, let block):
            if let index = messages.firstIndex(where: { $0.id == messageID }),
               let bIndex = messages[index].blocks.firstIndex(where: { $0.id == block.id }) {
                messages[index].blocks[bIndex] = block
            }

        case .embeddedResultAdded(let messageID, let descriptor):
            if let index = messages.firstIndex(where: { $0.id == messageID }) {
                messages[index].blocks.append(.embeddedResult(id: descriptor.id.rawValue, descriptor: descriptor))
            }

        case .requestCompleted(let requestID):
            if currentRequestID == requestID {
                isStreaming = false
                currentRequestID = nil
                for i in messages.indices {
                    messages[i].isStreaming = false
                }
            }

        case .requestFailed(let requestID, let error):
            if currentRequestID == requestID {
                isStreaming = false
                currentRequestID = nil
                if let lastIndex = messages.indices.last {
                    messages[lastIndex].isStreaming = false
                    messages[lastIndex].error = error
                }
            }
        }
    }

    public func send(prompt: String, attachments: [AgentAttachment] = []) {
        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !attachments.isEmpty else {
            return
        }

        let userMessage = AgentMessage(
            role: .user,
            blocks: [.markdown(id: UUID().uuidString, content: prompt)],
            isStreaming: false
        )
        messages.append(userMessage)
        currentDraft.clear()

        guard let runtime else { return }

        let requestID = AgentRequestID()
        let request = AgentSendRequest(
            requestID: requestID,
            conversationID: activeConversationID ?? AgentConversationID(),
            prompt: prompt,
            attachments: attachments,
            model: selectedModel,
            enableWebSearch: isWebSearchEnabled
        )

        currentRequestID = requestID
        isStreaming = true

        streamingTask?.cancel()
        streamingTask = Task { [weak self, runtime] in
            do {
                let stream = runtime.send(request)
                for try await event in stream {
                    if Task.isCancelled { break }
                    self?.apply(event)
                }
                self?.apply(.requestCompleted(requestID: requestID))
            } catch {
                if !Task.isCancelled {
                    let agentErr = (error as? AgentUIError) ?? AgentUIError(
                        code: "send_failed",
                        message: error.localizedDescription
                    )
                    self?.apply(.requestFailed(requestID: requestID, error: agentErr))
                }
            }
        }
    }

    public func stopStreaming() {
        guard isStreaming, let reqID = currentRequestID else { return }
        streamingTask?.cancel()
        streamingTask = nil
        isStreaming = false
        currentRequestID = nil
        Task { [runtime] in
            await runtime?.cancel(requestID: reqID)
        }
    }

    private func recordActivity(messageID: AgentMessageID, item: AgentActivityItem) {
        if var session = activitySessions[messageID] {
            if let idx = session.items.firstIndex(where: { $0.id == item.id }) {
                session.items[idx] = item
            } else {
                session.items.append(item)
            }
            activitySessions[messageID] = session
        } else {
            activitySessions[messageID] = AgentActivitySession(
                messageID: messageID,
                items: [item]
            )
        }
    }

    private func updateActivity(messageID: AgentMessageID, itemID: AgentActivityID, update: (inout AgentActivityItem) -> Void) {
        if var session = activitySessions[messageID],
           let idx = session.items.firstIndex(where: { $0.id == itemID }) {
            update(&session.items[idx])
            activitySessions[messageID] = session
        }
    }

    private func updateToolExecution(messageID: AgentMessageID, callID: AgentToolCallID, update: (inout AgentToolExecution) -> Void) {
        if let mIndex = messages.firstIndex(where: { $0.id == messageID }) {
            for bIndex in messages[mIndex].blocks.indices {
                if case .toolExecution(let id, var exec) = messages[mIndex].blocks[bIndex], exec.id == callID {
                    update(&exec)
                    messages[mIndex].blocks[bIndex] = .toolExecution(id: id, execution: exec)
                    break
                }
            }
        }
    }
}
