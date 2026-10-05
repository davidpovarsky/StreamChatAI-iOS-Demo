// Sources/AgentUI/Tools/ToolCallInspectionView.swift
#if canImport(SwiftUI)
import SwiftUI

public struct ToolCallInspectionView: View {
    public let inspection: ToolCallInspection
    public let status: AgentActivityStatus

    @Environment(\.agentUITheme) private var theme
    @Environment(\.agentUIDesignTokens) private var tokens

    public init(inspection: ToolCallInspection, status: AgentActivityStatus = .completed) {
        self.inspection = inspection
        self.status = status
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
                .opacity(tokens.borderOpacity)
                .padding(.bottom, 2)

            if let service = inspection.service, !service.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text(AgentLocalization.string("Repository / Service"))
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(theme.tertiaryText)
                    Text(service)
                        .font(.caption)
                        .foregroundStyle(theme.secondaryText)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(AgentLocalization.string("Tool call"))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(theme.tertiaryText)
                HStack(spacing: 6) {
                    Text(inspection.toolName)
                        .font(.caption.monospaced())
                        .foregroundStyle(theme.primaryText)

                    if let callID = inspection.callID, !callID.isEmpty {
                        Text("(\(callID))")
                            .font(.caption2.monospaced())
                            .foregroundStyle(theme.tertiaryText)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(AgentLocalization.string("Arguments"))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(theme.tertiaryText)

                ScrollView(.vertical) {
                    Text(inspection.prettyPrintedArguments)
                        .font(.caption2.monospaced())
                        .foregroundStyle(theme.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                }
                .frame(maxHeight: 180)
                .background(theme.surfaceBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .textSelection(.enabled)
            }

            if let result = inspection.resultSummary, !result.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text(AgentLocalization.string("Result"))
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(theme.tertiaryText)
                    Text(result)
                        .font(.caption2)
                        .foregroundStyle(theme.secondaryText)
                }
            }

            if let error = inspection.errorMessage, !error.isEmpty {
                VStack(alignment: .leading, spacing: 3) {
                    Text(AgentLocalization.string("Error"))
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(theme.errorColor)
                    Text(error)
                        .font(.caption2.monospaced())
                        .foregroundStyle(theme.primaryText)
                        .padding(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(theme.errorColor.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tool call details for \(inspection.toolName)")
    }
}
#endif
