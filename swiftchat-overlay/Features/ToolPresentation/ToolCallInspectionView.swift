//
//  ToolCallInspectionView.swift
//  SwiftChat
//
//  Clean expanded inspection content showing technical tool call details.
//

import SwiftUI

public struct ToolCallInspectionView: View {
    public let call: ToolCallInspection
    public let status: ToolExecutionStatus

    public init(call: ToolCallInspection, status: ToolExecutionStatus = .completed) {
        self.call = call
        self.status = status
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
                .opacity(0.35)
                .padding(.bottom, 2)

            if let service = call.service, !service.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Repository / Service")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.tertiary)
                    Text(service)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Tool call")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.tertiary)
                HStack(spacing: 6) {
                    Text(call.toolName)
                        .font(.caption.monospaced())
                        .foregroundStyle(.primary)

                    if let callID = call.callID, !callID.isEmpty {
                        Text("(\(callID))")
                            .font(.caption2.monospaced())
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Arguments")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.tertiary)

                ScrollView(.vertical) {
                    Text(call.arguments.formattedText)
                        .font(.caption2.monospaced())
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                }
                .frame(maxHeight: 180)
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .textSelection(.enabled)
            }

            if let result = call.resultSummary, !result.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Result")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.tertiary)
                    Text(result)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            if let error = call.errorMessage, !error.isEmpty {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Error")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.orange)
                    Text(error)
                        .font(.caption2.monospaced())
                        .foregroundStyle(.primary)
                        .padding(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.orange.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tool call details for \(call.toolName)")
    }
}
