#if canImport(SwiftUI)
import AgentChatCore
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct ToolCallInspectionView: View {
    public let call: ToolCallInspection
    public let status: ToolExecutionStatus

    @State private var copiedArguments = false
    @State private var copiedOutput = false

    public init(call: ToolCallInspection, status: ToolExecutionStatus = .completed) {
        self.call = call
        self.status = status
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Divider()

            HStack {
                Text(call.toolName)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))

                if let service = call.service {
                    Text("(\(service))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if call.duration > 0 {
                    Text(String(format: "%.2fs", call.duration))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Arguments")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        copyToClipboard(call.arguments)
                        copiedArguments = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            copiedArguments = false
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: copiedArguments ? "checkmark" : "doc.on.doc")
                            Text(copiedArguments ? "Copied" : "Copy")
                        }
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                Text(call.arguments)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.primary)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 8))
            }

            if let output = call.rawOutput, !output.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Output")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button {
                            copyToClipboard(output)
                            copiedOutput = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                copiedOutput = false
                            }
                        } label: {
                            HStack(spacing: 3) {
                                Image(systemName: copiedOutput ? "checkmark" : "doc.on.doc")
                                Text(copiedOutput ? "Copied" : "Copy")
                            }
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }

                    Text(output)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(status == .failed ? .red : .primary)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func copyToClipboard(_ text: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = text
        #endif
    }
}
#endif
