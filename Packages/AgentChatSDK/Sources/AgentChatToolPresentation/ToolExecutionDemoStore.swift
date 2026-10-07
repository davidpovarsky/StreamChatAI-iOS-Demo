//
//  ToolExecutionDemoStore.swift
//  AgentChatToolPresentation
//
//  Store managing demonstration tool execution instances for showcase chat.
//

import Foundation
#if canImport(Combine)
import Combine
public typealias ToolExecutionDemoStoreBase = ObservableObject
#else
public protocol ToolExecutionDemoStoreBase: AnyObject {}
#endif
import AgentChatCore

public enum ToolDemoKind: Equatable, Sendable {
    case gitHub(repo: String, count: Int)
    case webSearch(count: Int, query: String)
    case fileRead(file: String, lines: String)
    case calendar(count: Int, timeframe: String)
    case running(title: String, subtitle: String)
    case failed(title: String, subtitle: String)
}

public struct ToolExecutionDemoItem: Identifiable, Equatable, Sendable {
    public let id: String
    public let call: ToolCallInspection
    public let status: ToolExecutionStatus
    public let kind: ToolDemoKind

    public init(id: String = UUID().uuidString, call: ToolCallInspection, status: ToolExecutionStatus, kind: ToolDemoKind) {
        self.id = id
        self.call = call
        self.status = status
        self.kind = kind
    }
}

@MainActor
public final class ToolExecutionDemoStore: ToolExecutionDemoStoreBase {
    public static let shared = ToolExecutionDemoStore()
    public static let demoAssistantMessageID = "tool-demo-showcase-assistant-msg"

    #if canImport(Combine)
    @Published public var status: ToolExecutionStatus = .completed
    @Published public private(set) var itemsByMessageID: [String: [ToolExecutionDemoItem]] = [:]
    #else
    public var status: ToolExecutionStatus = .completed
    public private(set) var itemsByMessageID: [String: [ToolExecutionDemoItem]] = [:]
    #endif

    public init() {
        registerShowcaseData()
    }

    public func hasExecutions(for messageID: String) -> Bool {
        !(itemsByMessageID[messageID]?.isEmpty ?? true)
    }

    public func executions(for messageID: String) -> [ToolExecutionDemoItem] {
        itemsByMessageID[messageID] ?? []
    }

    public func createDemoChat(modelType: ModelType) -> Chat {
        registerShowcaseData()

        let userMessage = Message(
            role: .user,
            content: "Show me several tool executions with custom UI."
        )

        let assistantMessage = Message(
            id: Self.demoAssistantMessageID,
            role: .assistant,
            content: "I ran several developer and productivity tools to inspect the environment. Tap each tool card below to inspect arguments, payloads, and execution results."
        )

        return Chat.create(
            title: "Tool Execution UI Showcase",
            titleState: .manual,
            messages: [userMessage, assistantMessage],
            modelType: modelType
        )
    }

    public func registerShowcaseData() {
        let msgID = Self.demoAssistantMessageID

        let gitHubInspection = ToolCallInspection(
            service: "GitHub",
            toolName: "github_search_repositories",
            callID: "call_gh_98231",
            arguments: .json("""
            {
              "query": "repo:sachaservan/SwiftChat language:swift",
              "sort": "updated",
              "per_page": 5
            }
            """),
            resultSummary: "Fetched repository metadata, default branch (main), 12 closed issues, 4 active PRs."
        )

        let webInspection = ToolCallInspection(
            service: "Web Search",
            toolName: "brave_web_search",
            callID: "call_web_44120",
            arguments: .fields([
                ToolCallField(key: "query", value: "SwiftUI Liquid Glass HIG 2026"),
                ToolCallField(key: "freshness", value: "past_week"),
                ToolCallField(key: "count", value: "3")
            ]),
            resultSummary: "Retrieved 3 authoritative documentation sources and design guideline notes."
        )

        let fileInspection = ToolCallInspection(
            service: "Local Files",
            toolName: "read_source_file",
            callID: "call_fs_11204",
            arguments: .fields([
                ToolCallField(key: "path", value: "SwiftChat/Views/MessageView.swift"),
                ToolCallField(key: "lines", value: "50-120")
            ]),
            resultSummary: "Successfully read 71 lines from MessageView.swift."
        )

        let calInspection = ToolCallInspection(
            service: "Calendar",
            toolName: "calendar_get_events",
            callID: "call_cal_77610",
            arguments: .fields([
                ToolCallField(key: "timeMin", value: "2026-10-08T09:00:00Z"),
                ToolCallField(key: "timeMax", value: "2026-10-08T18:00:00Z")
            ]),
            resultSummary: "Found 2 upcoming meetings: Design Sync (10:00 AM) and Code Review (3:30 PM)."
        )

        let runInspection = ToolCallInspection(
            service: "Cloud Build",
            toolName: "trigger_fastlane_pipeline",
            callID: "call_run_33201",
            arguments: .json("""
            {
              "lane": "build_adhoc_ipa",
              "destination": "generic/platform=iOS"
            }
            """),
            resultSummary: nil
        )

        let failInspection = ToolCallInspection(
            service: "Database",
            toolName: "sql_query_execute",
            callID: "call_db_88912",
            arguments: .fields([
                ToolCallField(key: "database", value: "analytics_prod"),
                ToolCallField(key: "query", value: "SELECT * FROM daily_metrics LIMIT 10")
            ]),
            resultSummary: nil,
            errorMessage: "Connection timeout after 3000ms: database host unreachable."
        )

        itemsByMessageID[msgID] = [
            ToolExecutionDemoItem(call: gitHubInspection, status: .completed, kind: .gitHub(repo: "sachaservan/SwiftChat", count: 1)),
            ToolExecutionDemoItem(call: webInspection, status: .completed, kind: .webSearch(count: 3, query: "SwiftUI Liquid Glass HIG 2026")),
            ToolExecutionDemoItem(call: fileInspection, status: .completed, kind: .fileRead(file: "MessageView.swift", lines: "50-120")),
            ToolExecutionDemoItem(call: calInspection, status: .completed, kind: .calendar(count: 2, timeframe: "Today")),
            ToolExecutionDemoItem(call: runInspection, status: .running, kind: .running(title: "Building iOS IPA", subtitle: "Running fastlane adhoc build...")),
            ToolExecutionDemoItem(call: failInspection, status: .failed, kind: .failed(title: "Query Database", subtitle: "Connection timeout"))
        ]
    }
}
