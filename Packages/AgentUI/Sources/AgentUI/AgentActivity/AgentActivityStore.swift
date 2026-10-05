//
//  AgentActivityStore.swift
//  AgentUI
//

import Combine
import Foundation

@MainActor
public final class AgentActivityStore: ObservableObject {
    public static let shared = AgentActivityStore()
    @Published public private(set) var sessions: [String: AgentActivitySession] = [:]

    public init() {}

    public func session(for messageID: String) -> AgentActivitySession? { sessions[messageID] }

    public func begin(messageID: String) {
        guard sessions[messageID] == nil else { return }
        sessions[messageID] = AgentActivitySession(
            messageID: messageID,
            startedAt: Date(),
            items: [],
            answerStarted: false,
            isExpanded: true
        )
    }

    public func addStatus(messageID: String, title: String, summary: String? = nil) {
        mutate(messageID) { session in
            session.items.append(AgentActivityItem(kind: .status, status: .completed, title: title, summary: summary))
            session.items[session.items.count - 1].completedAt = Date()
        }
    }

    public func beginReasoning(messageID: String, summary: String = "Thinking") {
        begin(messageID: messageID)
        guard index(in: messageID, matching: { $0.kind == .reasoning }) == nil else { return }
        mutate(messageID) { $0.items.append(AgentActivityItem(kind: .reasoning, title: summary)) }
    }

    public func updateReasoningSummary(messageID: String, summary: String) {
        guard !summary.isEmpty else { return }
        updateItem(messageID, matching: { $0.kind == .reasoning }) { item in
            item.title = summary
            item.summary = nil
        }
    }

    public func beginWebSearch(messageID: String) {
        begin(messageID: messageID)
        guard index(in: messageID, matching: { $0.kind == .webSearch }) == nil else { return }
        mutate(messageID) { $0.items.append(AgentActivityItem(kind: .webSearch, title: "Searching the web")) }
    }

    public func addSearchSource(messageID: String, source: WebSearchSource) {
        updateItem(messageID, matching: { $0.kind == .webSearch }) { item in
            if !item.sources.contains(where: { $0.url == source.url }) { item.sources.append(source) }
            item.title = "Searched \(item.sources.count) \(item.sources.count == 1 ? "website" : "websites")"
        }
    }

    public func completeWebSearch(messageID: String) {
        completeItem(messageID, matching: { $0.kind == .webSearch })
    }

    public func beginTool(
        messageID: String,
        id: String = UUID().uuidString,
        service: String?,
        title: String,
        toolName: String?,
        arguments: String?
    ) {
        begin(messageID: messageID)
        mutate(messageID) {
            $0.items.append(AgentActivityItem(
                id: id,
                kind: .toolCall(service: service),
                title: title,
                toolName: toolName,
                toolArguments: arguments
            ))
        }
    }

    public func updateTool(messageID: String, id: String, summary: String) {
        updateItem(messageID, matching: { $0.id == id }) { $0.summary = summary }
    }

    public func completeTool(messageID: String, id: String, resultSummary: String?) {
        updateItem(messageID, matching: { $0.id == id }) {
            $0.status = .completed
            $0.completedAt = Date()
            $0.toolResultSummary = resultSummary
        }
    }

    public func failTool(messageID: String, id: String, summary: String?) {
        updateItem(messageID, matching: { $0.id == id }) {
            $0.status = .failed
            $0.completedAt = Date()
            $0.toolResultSummary = summary
        }
    }

    public func markAnswerStarted(messageID: String) {
        mutate(messageID) { session in
            guard !session.answerStarted else { return }
            session.answerStarted = true
            session.isExpanded = false
            for index in session.items.indices where session.items[index].status == .running {
                session.items[index].status = .completed
                session.items[index].completedAt = Date()
            }
        }
    }

    public func finish(messageID: String) {
        mutate(messageID) { session in
            session.completedAt = Date()
            for index in session.items.indices where session.items[index].status == .running {
                session.items[index].status = .completed
                session.items[index].completedAt = Date()
            }
        }
    }

    public func setExpanded(_ expanded: Bool, messageID: String) {
        mutate(messageID) { $0.isExpanded = expanded }
    }

    private func mutate(_ messageID: String, _ change: (inout AgentActivitySession) -> Void) {
        guard var session = sessions[messageID] else { return }
        change(&session)
        sessions[messageID] = session
    }

    private func index(in messageID: String, matching predicate: (AgentActivityItem) -> Bool) -> Int? {
        sessions[messageID]?.items.firstIndex(where: predicate)
    }

    private func updateItem(
        _ messageID: String,
        matching predicate: (AgentActivityItem) -> Bool,
        change: (inout AgentActivityItem) -> Void
    ) {
        mutate(messageID) { session in
            guard let index = session.items.firstIndex(where: predicate) else { return }
            change(&session.items[index])
        }
    }

    private func completeItem(_ messageID: String, matching predicate: (AgentActivityItem) -> Bool) {
        updateItem(messageID, matching: predicate) {
            $0.status = .completed
            $0.completedAt = Date()
        }
    }
}
