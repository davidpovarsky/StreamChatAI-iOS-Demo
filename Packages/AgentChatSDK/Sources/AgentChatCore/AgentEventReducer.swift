import Foundation

// MARK: - Deterministic Agent Event Reducer

public struct AgentEventReducer: Sendable {
    public init() {}

    @discardableResult
    public static func reduce(conversation: inout Conversation, event: AgentChatStreamEvent) -> Bool {
        switch event {
        case .runStarted(let runId, let messageId):
            ensureAssistantMessage(in: &conversation, messageId: messageId, runId: runId)
            if conversation.runs[runId] == nil {
                conversation.runs[runId] = AgentRun(
                    id: runId,
                    messageId: messageId,
                    status: .running,
                    startedAt: Date(),
                    groups: [],
                    approvals: [],
                    isExpanded: false // Collapsed by default
                )
            } else {
                conversation.runs[runId]?.status = .running
            }
            conversation.updatedAt = Date()
            return true

        case .runFinished(let runId, let status):
            guard var run = conversation.runs[runId] else { return false }
            run.status = status
            run.completedAt = Date()
            conversation.runs[runId] = run

            // Update corresponding message streaming status
            if let index = conversation.messages.firstIndex(where: { $0.id == run.messageId }) {
                conversation.messages[index].isStreaming = false
            }
            conversation.updatedAt = Date()
            return true

        case .groupStarted(let runId, let groupId, let stage, let title):
            guard var run = conversation.runs[runId] else { return false }
            if let groupIndex = run.groups.firstIndex(where: { $0.id == groupId }) {
                if let title = title {
                    run.groups[groupIndex].title = title
                }
            } else {
                run.groups.append(ActivityGroup(
                    id: groupId,
                    stage: stage,
                    title: title,
                    operations: [],
                    isExpanded: false // Collapsed by default
                ))
            }
            conversation.runs[runId] = run
            return true

        case .toolRequested(let runId, let groupId, let operationId, let tool, let title, let arguments):
            guard var run = conversation.runs[runId] else { return false }
            let operation = ActivityOperation(
                id: operationId,
                callId: operationId,
                toolName: tool,
                title: title ?? tool,
                status: .running,
                startedAt: Date(),
                argumentsText: arguments,
                isExpanded: false
            )

            if let gId = groupId, let groupIndex = run.groups.firstIndex(where: { $0.id == gId }) {
                if !run.groups[groupIndex].operations.contains(where: { $0.id == operationId }) {
                    run.groups[groupIndex].operations.append(operation)
                }
            } else if !run.groups.isEmpty {
                if !run.groups[0].operations.contains(where: { $0.id == operationId }) {
                    run.groups[0].operations.append(operation)
                }
            } else {
                var defaultGroup = ActivityGroup(
                    id: "default-group-\(runId)",
                    stage: .custom,
                    title: "Operations",
                    operations: [operation],
                    isExpanded: false
                )
                run.groups.append(defaultGroup)
            }
            conversation.runs[runId] = run
            return true

        case .toolProgress(let runId, let operationId, let progress, let message):
            guard var run = conversation.runs[runId] else { return false }
            for gIdx in run.groups.indices {
                if let opIdx = run.groups[gIdx].operations.firstIndex(where: { $0.id == operationId }) {
                    run.groups[gIdx].operations[opIdx].progress = progress
                    if let msg = message {
                        run.groups[gIdx].operations[opIdx].title = msg
                    }
                    conversation.runs[runId] = run
                    return true
                }
            }
            return false

        case .toolCompleted(let runId, let operationId, let resultSummary, let payload, let sources):
            guard var run = conversation.runs[runId] else { return false }
            for gIdx in run.groups.indices {
                if let opIdx = run.groups[gIdx].operations.firstIndex(where: { $0.id == operationId }) {
                    run.groups[gIdx].operations[opIdx].status = .completed
                    run.groups[gIdx].operations[opIdx].completedAt = Date()
                    if let start = run.groups[gIdx].operations[opIdx].startedAt as Date? {
                        run.groups[gIdx].operations[opIdx].duration = Date().timeIntervalSince(start)
                    }
                    run.groups[gIdx].operations[opIdx].resultSummary = resultSummary
                    run.groups[gIdx].operations[opIdx].rawPayload = payload
                    if !sources.isEmpty {
                        run.groups[gIdx].operations[opIdx].sources = sources
                    }
                    conversation.runs[runId] = run
                    return true
                }
            }
            return false

        case .toolFailed(let runId, let operationId, let error):
            guard var run = conversation.runs[runId] else { return false }
            for gIdx in run.groups.indices {
                if let opIdx = run.groups[gIdx].operations.firstIndex(where: { $0.id == operationId }) {
                    run.groups[gIdx].operations[opIdx].status = .failed
                    run.groups[gIdx].operations[opIdx].completedAt = Date()
                    run.groups[gIdx].operations[opIdx].resultSummary = error
                    conversation.runs[runId] = run
                    return true
                }
            }
            return false

        case .approvalRequested(let approval):
            guard var run = conversation.runs[approval.runId] else { return false }
            if let idx = run.approvals.firstIndex(where: { $0.id == approval.id }) {
                run.approvals[idx] = approval
            } else {
                run.approvals.append(approval)
            }
            conversation.runs[approval.runId] = run
            return true

        case .approvalResolved(let requestId, let status):
            for (runId, var run) in conversation.runs {
                if let idx = run.approvals.firstIndex(where: { $0.id == requestId }) {
                    run.approvals[idx].status = status
                    run.approvals[idx].resolvedAt = Date()
                    conversation.runs[runId] = run
                    return true
                }
            }
            return false

        case .contentDelta(let messageId, let text):
            appendMarkdownDelta(to: &conversation, messageId: messageId, text: text)
            return true

        case .token(let text):
            if let lastAssistant = conversation.messages.last(where: { $0.role == .assistant }) {
                appendMarkdownDelta(to: &conversation, messageId: lastAssistant.id, text: text)
            } else {
                let newId = UUID().uuidString.lowercased()
                ensureAssistantMessage(in: &conversation, messageId: newId, runId: nil)
                appendMarkdownDelta(to: &conversation, messageId: newId, text: text)
            }
            return true

        case .thinkingToken:
            // Thinking tokens kept out of main prose
            return true

        case .resultProduced(let result):
            ensureAssistantMessage(in: &conversation, messageId: result.messageId, runId: result.runId)
            if let msgIdx = conversation.messages.firstIndex(where: { $0.id == result.messageId }) {
                // Ensure duplicate result isn't appended
                if !conversation.messages[msgIdx].segments.contains(where: { $0.id == result.id }) {
                    conversation.messages[msgIdx].segments.append(
                        ChatMessageSegment(id: result.id, kind: .result(result))
                    )
                }
            }
            conversation.updatedAt = Date()
            return true

        case .richPart(let part):
            let result = adaptMessageContentPart(part, messageId: conversation.messages.last?.id ?? "unknown")
            return reduce(conversation: &conversation, event: .resultProduced(result: result))

        case .webSearch(let state):
            // Backward compatibility
            return true

        case .error(let messageId, let error):
            if let msgIdx = conversation.messages.firstIndex(where: { $0.id == messageId }) {
                conversation.messages[msgIdx].error = error
                conversation.messages[msgIdx].isStreaming = false
            }
            conversation.updatedAt = Date()
            return true

        case .finished:
            for idx in conversation.messages.indices {
                if conversation.messages[idx].isStreaming {
                    conversation.messages[idx].isStreaming = false
                }
            }
            conversation.updatedAt = Date()
            return true
        }
    }

    // MARK: - Private Helpers

    private static func ensureAssistantMessage(in conversation: inout Conversation, messageId: MessageID, runId: RunID?) {
        if let idx = conversation.messages.firstIndex(where: { $0.id == messageId }) {
            if let rId = runId, !conversation.messages[idx].runIds.contains(rId) {
                conversation.messages[idx].runIds.append(rId)
            }
            conversation.messages[idx].isStreaming = true
        } else {
            var newMsg = ChatMessage(
                id: messageId,
                conversationId: conversation.id,
                role: .assistant,
                segments: [],
                runIds: runId.map { [$0] } ?? [],
                isStreaming: true
            )
            conversation.messages.append(newMsg)
        }
    }

    private static func appendMarkdownDelta(to conversation: inout Conversation, messageId: MessageID, text: String) {
        guard let idx = conversation.messages.firstIndex(where: { $0.id == messageId }) else { return }
        conversation.messages[idx].isStreaming = true

        if let lastSegIdx = conversation.messages[idx].segments.indices.last,
           case .markdown(let current) = conversation.messages[idx].segments[lastSegIdx].kind {
            conversation.messages[idx].segments[lastSegIdx].kind = .markdown(current + text)
        } else {
            let segId = UUID().uuidString.lowercased()
            conversation.messages[idx].segments.append(ChatMessageSegment(id: segId, kind: .markdown(text)))
        }
        conversation.updatedAt = Date()
    }

    private static func adaptMessageContentPart(_ part: MessageContentPart, messageId: MessageID) -> AgentResult {
        let kind: AgentResultKind
        var metadata: [String: AnySendable] = [:]
        switch part.kind {
        case .markdown: kind = .markdown
        case .image: kind = .image
        case .video: kind = .video
        case .youtube: kind = .webContentFallback
        case .linkPreview: kind = .richLink
        case .svg:
            kind = .svg
            if let svg = part.svgString { metadata["svgString"] = .string(svg) }
        case .lottie: kind = .artifact
        case .customTool: kind = .toolFallback
        }

        let payload = AgentResultPayload(
            title: part.title,
            subtitle: part.subtitle,
            contentText: part.markdown ?? part.caption,
            urlString: part.url ?? part.thumbnailURL,
            metadata: metadata,
            sources: part.sources
        )

        return AgentResult(
            id: part.id,
            messageId: messageId,
            kind: kind,
            schemaVersion: 1,
            title: part.title,
            payload: payload
        )
    }
}
