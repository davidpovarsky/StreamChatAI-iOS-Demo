#if canImport(AgentChatCore)
import AgentChatCore
#endif
#if canImport(Combine)
import Combine
#endif
import Foundation

@MainActor
public final class AgentActivityStore: ObservableObject {
    public static let shared = AgentActivityStore()

    #if canImport(Combine)
    @Published public private(set) var sessions: [String: AgentActivitySession] = [:]
    #else
    public private(set) var sessions: [String: AgentActivitySession] = [:]
    #endif

    public init() {}

    public func session(for messageID: String) -> AgentActivitySession? {
        sessions[messageID]
    }

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
            var item = AgentActivityItem(kind: .status, status: .completed, title: title, summary: summary)
            item.completedAt = Date()
            session.items.append(item)
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

    public func beginWebSearch(messageID: String, query: String? = nil) {
        begin(messageID: messageID)
        completeRunningReasoning(messageID: messageID)
        guard index(in: messageID, matching: { $0.kind == .webSearch }) == nil else { return }
        let title = query != nil ? "Searching web for \"\(query!)\"" : "Searching the web"
        mutate(messageID) { $0.items.append(AgentActivityItem(kind: .webSearch, title: title)) }
    }

    public func addSearchSource(messageID: String, source: AgentSource) {
        updateItem(messageID, matching: { $0.kind == .webSearch }) { item in
            if !item.sources.contains(where: { $0.url == source.url }) {
                item.sources.append(source)
            }
            let count = item.sources.count
            item.title = "Searched \(count) \(count == 1 ? "website" : "websites")"
        }
    }

    public func completeWebSearch(messageID: String) {
        completeItem(messageID: messageID, matching: { $0.kind == .webSearch })
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
            session.answerStarted = true
            for idx in session.items.indices where session.items[idx].status == .running {
                session.items[idx].status = .completed
                session.items[idx].completedAt = Date()
            }
        }
    }

    public func completeSession(messageID: String) {
        mutate(messageID) { session in
            session.completedAt = Date()
            session.isExpanded = false
            for idx in session.items.indices where session.items[idx].status == .running {
                session.items[idx].status = .completed
                session.items[idx].completedAt = Date()
            }
        }
    }

    public func setExpanded(messageID: String, isExpanded: Bool) {
        mutate(messageID) { $0.isExpanded = isExpanded }
    }

    public func reset(messageID: String) {
        sessions.removeValue(forKey: messageID)
    }

    private func completeRunningReasoning(messageID: String) {
        updateItem(messageID, matching: { $0.kind == .reasoning && $0.status == .running }) {
            $0.status = .completed
            $0.completedAt = Date()
        }
    }

    private func completeItem(messageID: String, matching predicate: (AgentActivityItem) -> Bool) {
        updateItem(messageID, matching: predicate) {
            $0.status = .completed
            $0.completedAt = Date()
        }
    }

    private func index(in messageID: String, matching predicate: (AgentActivityItem) -> Bool) -> Int? {
        sessions[messageID]?.items.firstIndex(where: predicate)
    }

    private func updateItem(
        _ messageID: String,
        matching predicate: (AgentActivityItem) -> Bool,
        mutateBlock: (inout AgentActivityItem) -> Void
    ) {
        guard var session = sessions[messageID],
              let idx = session.items.firstIndex(where: predicate) else { return }
        mutateBlock(&session.items[idx])
        sessions[messageID] = session
    }

    private func mutate(_ messageID: String, block: (inout AgentActivitySession) -> Void) {
        guard var session = sessions[messageID] else { return }
        block(&session)
        sessions[messageID] = session
    }
}
