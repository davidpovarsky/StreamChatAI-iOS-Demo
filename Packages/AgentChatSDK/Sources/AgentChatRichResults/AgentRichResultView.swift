#if canImport(SwiftUI)
import AgentChatCore
import SwiftUI

public struct AgentRichResultView: View {
    public let call: AgentToolCall
    public let result: AgentToolResult?
    public let isExpanded: Bool

    public init(call: AgentToolCall, result: AgentToolResult? = nil, isExpanded: Bool = false) {
        self.call = call
        self.result = result
        self.isExpanded = isExpanded
    }

    public var body: some View {
        let inspection = ToolCallInspection(call: call, result: result)
        let status: ToolExecutionStatus = result != nil ? (result!.isSuccess ? .completed : .failed) : .running

        ToolExecutionDisclosure(call: inspection, status: status, isExpanded: isExpanded) {
            if let customRenderer = AgentToolRendererRegistry.shared.renderer(for: call.name) {
                customRenderer.render(call: call, result: result)
            } else {
                genericPresentation
            }
        }
    }

    private var genericPresentation: some View {
        HStack(spacing: 8) {
            Image(systemName: "wrench.and.screwdriver.fill")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(call.name)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))

                if let summary = result?.outputSummary {
                    Text(summary)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }
}
#endif
