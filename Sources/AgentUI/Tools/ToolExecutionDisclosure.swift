// Sources/AgentUI/Tools/ToolExecutionDisclosure.swift
#if canImport(SwiftUI)
import SwiftUI

public struct ToolExecutionDisclosure: View {
    public let execution: AgentToolExecution
    @State private var isExpanded: Bool

    @Environment(\.agentToolSurfaces) private var registry
    @Environment(\.agentUIDesignTokens) private var tokens

    public init(execution: AgentToolExecution, isExpanded: Bool = false) {
        self.execution = execution
        self._isExpanded = State(initialValue: execution.isExpanded || isExpanded)
    }

    public var body: some View {
        // ONE continuous surface containing header and inspection
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    registry.resolve(execution: execution)

                    Spacer(minLength: 4)

                    if execution.status == .running {
                        ProgressView()
                            .controlSize(.mini)
                    } else if execution.status == .failed {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.orange)
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.secondary.opacity(0.6))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                ToolCallInspectionView(
                    inspection: execution.inspection,
                    status: execution.status
                )
                .padding(.top, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        // Single continuous glass/material shape wrapper
        .agentGlassEffect(cornerRadius: tokens.toolDisclosureCornerRadius)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tool execution: \(execution.inspection.toolName)")
        .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
    }
}
#endif
