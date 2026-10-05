//
//  ToolExecutionDemoBridge.swift
//  SwiftChat
//
//  Lightweight bridge rendering tool execution disclosures for showcase messages.
//

import SwiftUI

public struct ToolExecutionDemoBridge: View {
    public let messageID: String
    public let isDarkMode: Bool
    @ObservedObject private var store = ToolExecutionDemoStore.shared

    public init(messageID: String, isDarkMode: Bool = false) {
        self.messageID = messageID
        self.isDarkMode = isDarkMode
    }

    public var body: some View {
        if store.hasExecutions(for: messageID) {
            ToolExecutionDemoContainerView(messageID: messageID)
        }
    }
}

private struct ToolExecutionDemoContainerView: View {
    let messageID: String
    @ObservedObject private var store = ToolExecutionDemoStore.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(store.executions(for: messageID)) { item in
                demoDisclosure(for: item)
            }
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func demoDisclosure(for item: ToolExecutionDemoItem) -> some View {
        ToolExecutionDisclosure(call: item.call, status: item.status) {
            switch item.kind {
            case .gitHub(let repo, let count):
                GitHubToolPresentationView(repository: repo, resultCount: count)
            case .webSearch(let count, let query):
                WebSearchToolPresentationView(siteCount: count, query: query)
            case .fileRead(let file, let lines):
                FileReadToolPresentationView(fileName: file, lineRange: lines)
            case .calendar(let count, let timeframe):
                CalendarToolPresentationView(eventCount: count, timeframe: timeframe)
            case .running(let title, let subtitle):
                GenericAppToolPresentationView(
                    icon: "arrow.triangle.2.circlepath",
                    title: title,
                    subtitle: subtitle,
                    tintColor: .blue
                )
            case .failed(let title, let subtitle):
                GenericAppToolPresentationView(
                    icon: "arrow.triangle.pull",
                    title: title,
                    subtitle: subtitle,
                    tintColor: .orange
                )
            }
        }
    }
}
