// Sources/AgentUI/Sources/AgentSourcesSheet.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentSourcesSheet: View {
    public let title: String
    public let sources: [AgentSource]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.agentUITheme) private var theme

    public init(title: String = "Sources", sources: [AgentSource]) {
        self.title = title
        self.sources = sources
    }

    public var body: some View {
        NavigationStack {
            List {
                ForEach(sources) { source in
                    AgentSourceRow(source: source)
                }
            }
            .navigationTitle(title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.subheadline.weight(.semibold))
                }
            }
        }
    }
}
#endif
