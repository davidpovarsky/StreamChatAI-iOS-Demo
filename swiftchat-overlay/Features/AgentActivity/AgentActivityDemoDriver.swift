import Foundation

@MainActor
enum AgentActivityDemoDriver {
    private static var tasks: [String: Task<Void, Never>] = [:]

    static func start(messageID: String) {
        tasks[messageID]?.cancel()
        let store = AgentActivityStore.shared
        store.begin(messageID: messageID)

        tasks[messageID] = Task { @MainActor in
            store.beginReasoning(messageID: messageID, summary: "Thinking")
            await pause()

            let toolID = "demo-github"
            store.beginTool(
                messageID: messageID,
                id: toolID,
                service: "GitHub",
                title: "Interacted with GitHub",
                toolName: "search",
                arguments: "Repository: sachaservan/SwiftChat\nQuery: struct SourcesButton"
            )
            await pause()
            store.addStatus(messageID: messageID, title: "Inspecting repository structure")
            await pause()

            store.beginWebSearch(messageID: messageID)
            store.addSearchSource(
                messageID: messageID,
                source: WebSearchSource(
                    title: "SwiftUI Documentation - Apple",
                    url: "https://developer.apple.com/documentation/swiftui"
                )
            )
            store.completeWebSearch(messageID: messageID)
            await pause()

            store.addStatus(messageID: messageID, title: "Planning media integration")
            await pause()
            store.completeTool(messageID: messageID, id: toolID, resultSummary: "Result: MessageView.swift")
            store.addStatus(messageID: messageID, title: "Inspected SwiftChat UI/models/rendering")
            tasks[messageID] = nil
        }
    }

    private static func pause() async {
        try? await Task.sleep(for: .milliseconds(70))
    }
}
