//
//  ToolExecutionDemoStore.swift
//  SwiftChat
//
//  Mock store managing demonstration tool execution instances for showcase chat.
//

import Foundation
import Combine
import AgentUI

enum ToolDemoKind: Equatable {
    case gitHub(repo: String, count: Int)
    case webSearch(count: Int, query: String)
    case fileRead(file: String, lines: String)
    case calendar(count: Int, timeframe: String)
    case running(title: String, subtitle: String)
    case failed(title: String, subtitle: String)
}

struct ToolExecutionDemoItem: Identifiable, Equatable {
    let id: String
    let call: ToolCallInspection
    let status: ToolExecutionStatus
    let kind: ToolDemoKind

    init(id: String = UUID().uuidString, call: ToolCallInspection, status: ToolExecutionStatus, kind: ToolDemoKind) {
        self.id = id
        self.call = call
        self.status = status
        self.kind = kind
    }
}

@MainActor
final class ToolExecutionDemoStore: ObservableObject {
    static let shared = ToolExecutionDemoStore()

    static let demoAssistantMessageID = "tool-demo-showcase-assistant-msg"

    @Published private var itemsByMessageID: [String: [ToolExecutionDemoItem]] = [:]

    init() {
        registerShowcaseData()
    }

    func hasExecutions(for messageID: String) -> Bool {
        !(itemsByMessageID[messageID]?.isEmpty ?? true)
    }

    func executions(for messageID: String) -> [ToolExecutionDemoItem] {
        itemsByMessageID[messageID] ?? []
    }

    func createDemoChat(modelType: ModelType) -> Chat {
        registerShowcaseData()

        let userMessage = Message(
            role: .user,
            content: "Show me several tool executions with custom UI."
        )

        let assistantMessage = Message(
            id: Self.demoAssistantMessageID,
            role: .assistant,
            content: "I executed the requested tools across the workspace, web, and calendar. Below are the execution steps highlighting the custom UI presentations and expandable inspection details:"
        )

        return Chat.create(
            title: "Tool UI Components",
            titleState: .manual,
            messages: [userMessage, assistantMessage],
            modelType: modelType
        )
    }

    private func registerShowcaseData() {
        let items: [ToolExecutionDemoItem] = [
            // A. GitHub Search (Completed)
            ToolExecutionDemoItem(
                id: "tool-item-github",
                call: ToolCallInspection(
                    service: "sachaservan/SwiftChat",
                    toolName: "search_code",
                    callID: "call_gh_01",
                    arguments: .json("{\n  \"query\": \"SourcesButton\"\n}"),
                    resultSummary: "Found 4 occurrences across 2 files"
                ),
                status: .completed,
                kind: .gitHub(repo: "SwiftChat repository", count: 4)
            ),

            // B. Web Search (Completed)
            ToolExecutionDemoItem(
                id: "tool-item-websearch",
                call: ToolCallInspection(
                    service: "Web Search",
                    toolName: "web_search",
                    callID: "call_ws_02",
                    arguments: .json("{\n  \"query\": \"SwiftUI Liquid Glass menu\"\n}"),
                    resultSummary: "Retrieved 3 documentation pages"
                ),
                status: .completed,
                kind: .webSearch(count: 3, query: "SwiftUI Liquid Glass menu")
            ),

            // C. File Read (Completed)
            ToolExecutionDemoItem(
                id: "tool-item-fileread",
                call: ToolCallInspection(
                    service: "sachaservan/SwiftChat",
                    toolName: "read_file",
                    callID: "call_fr_03",
                    arguments: .json("{\n  \"path\": \"SwiftChat/Views/MessageView.swift\",\n  \"start_line\": 300,\n  \"end_line\": 410\n}"),
                    resultSummary: "Read 110 lines successfully"
                ),
                status: .completed,
                kind: .fileRead(file: "MessageView.swift", lines: "Lines 300–410")
            ),

            // D. Calendar / Generic Tool (Completed)
            ToolExecutionDemoItem(
                id: "tool-item-calendar",
                call: ToolCallInspection(
                    service: "System Calendar",
                    toolName: "search_events",
                    callID: "call_cal_04",
                    arguments: .json("{\n  \"date\": \"tomorrow\"\n}"),
                    resultSummary: "Found 3 events for tomorrow"
                ),
                status: .completed,
                kind: .calendar(count: 3, timeframe: "Tomorrow")
            ),

            // E. Running State Demo
            ToolExecutionDemoItem(
                id: "tool-item-running",
                call: ToolCallInspection(
                    service: "sachaservan/SwiftChat",
                    toolName: "index_repository",
                    callID: "call_idx_05",
                    arguments: .json("{\n  \"branch\": \"main\",\n  \"depth\": 1\n}")
                ),
                status: .running,
                kind: .running(title: "Indexing repository", subtitle: "branch: main")
            ),

            // F. Failed State Demo
            ToolExecutionDemoItem(
                id: "tool-item-failed",
                call: ToolCallInspection(
                    service: "GitHub API",
                    toolName: "fetch_pull_request",
                    callID: "call_pr_06",
                    arguments: .json("{\n  \"pr_number\": 999\n}"),
                    errorMessage: "404 Not Found: Pull request #999 does not exist in repository sachaservan/SwiftChat"
                ),
                status: .failed,
                kind: .failed(title: "Fetch pull request #999", subtitle: "sachaservan/SwiftChat")
            )
        ]

        itemsByMessageID[Self.demoAssistantMessageID] = items
    }
}
