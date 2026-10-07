#if canImport(SwiftUI)
import AgentChatCore
import SwiftUI

public struct AgentActivityItemDetailView: View {
    public let item: AgentActivityItem
    @Environment(\.dismiss) private var dismiss

    public init(item: AgentActivityItem) {
        self.item = item
    }

    public var body: some View {
        NavigationStack {
            List {
                Section("Activity Step") {
                    LabeledContent("Title", value: item.title)
                    LabeledContent("Status", value: statusString)
                    if item.elapsed > 0 {
                        LabeledContent("Duration", value: String(format: "%.1f seconds", item.elapsed))
                    }
                }

                if let summary = item.summary, !summary.isEmpty {
                    Section("Summary / Output") {
                        Text(summary)
                            .font(.system(size: 14))
                    }
                }

                if let toolName = item.toolName {
                    Section("Tool Details") {
                        LabeledContent("Tool Name", value: toolName)
                        if let args = item.toolArguments {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Arguments")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(args)
                                    .font(.system(size: 12, design: .monospaced))
                                    .padding(8)
                                    .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        if let resultSummary = item.toolResultSummary {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Result")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(resultSummary)
                                    .font(.system(size: 13))
                            }
                        }
                    }
                }

                if !item.sources.isEmpty {
                    Section("Sources (\(item.sources.count))") {
                        ForEach(item.sources) { source in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(source.title)
                                    .font(.system(size: 14, weight: .semibold))
                                Text(source.domain)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if let snippet = source.snippet {
                                    Text(snippet)
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
            .navigationTitle("Activity Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var statusString: String {
        switch item.status {
        case .pending: return "Pending"
        case .running: return "Running"
        case .completed: return "Completed"
        case .failed: return "Failed"
        }
    }
}
#endif
