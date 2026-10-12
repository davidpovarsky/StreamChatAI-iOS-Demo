import SwiftUI
import AgentChatCore
import AgentChatSources

public struct AgentToolInspectorView: View {
    public let operation: ActivityOperation
    @Environment(\.dismiss) private var dismiss

    public init(operation: ActivityOperation) {
        self.operation = operation
    }

    private var redactedArguments: String {
        guard let raw = operation.argumentsText else { return "No arguments supplied" }
        return redactSensitiveContent(raw)
    }

    private func redactSensitiveContent(_ text: String) -> String {
        var result = text
        let sensitiveKeys = ["api_key", "apiKey", "password", "token", "secret", "authorization", "bearer"]
        for key in sensitiveKeys {
            let pattern = "\"\(key)\"\\s*:\\s*\"[^\"]+\""
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(result.startIndex..., in: result)
                result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "\"\(key)\": \"[REDACTED]\"")
            }
        }
        return result
    }

    public var body: some View {
        NavigationStack {
            List {
                Section("Operation Details") {
                    LabeledContent("Tool", value: operation.toolName)
                    LabeledContent("Status", value: operation.status.rawValue.capitalized)
                    LabeledContent("Call ID", value: operation.callId)
                    LabeledContent("Attempt", value: "\(operation.attempt)")
                    if let dur = operation.duration {
                        LabeledContent("Duration", value: String(format: "%.2f s", dur))
                    }
                }

                if let summary = operation.resultSummary {
                    Section("Result Summary") {
                        Text(summary)
                            .font(.system(size: 13))
                    }
                }

                Section("Arguments (Redacted)") {
                    Text(redactedArguments)
                        .font(.system(.caption, design: .monospaced))
                        .padding(.vertical, 4)
                }

                if let raw = operation.rawPayload, !raw.isEmpty {
                    Section("Raw Output") {
                        Text(redactSensitiveContent(raw))
                            .font(.system(.caption, design: .monospaced))
                            .padding(.vertical, 4)
                    }
                }

                if !operation.sources.isEmpty {
                    Section("Retrieved Sources (\(operation.sources.count))") {
                        ForEach(operation.sources) { src in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(src.title)
                                    .font(.system(size: 13, weight: .medium))
                                Text(src.url)
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Tool Inspector")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
