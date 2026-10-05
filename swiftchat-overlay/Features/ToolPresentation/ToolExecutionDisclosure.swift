//
//  ToolExecutionDisclosure.swift
//  SwiftChat
//
//  Generic Liquid Glass disclosure container for tool-provided UI and expandable call inspection.
//

import SwiftUI

public struct ToolExecutionDisclosure<Presentation: View>: View {
    public let call: ToolCallInspection
    public let status: ToolExecutionStatus
    public let presentation: () -> Presentation

    @State private var internalExpanded: Bool
    private var externalExpanded: Binding<Bool>?

    private var isExpandedBinding: Binding<Bool> {
        externalExpanded ?? $internalExpanded
    }

    public init(
        call: ToolCallInspection,
        status: ToolExecutionStatus = .completed,
        isExpanded: Bool = false,
        @ViewBuilder presentation: @escaping () -> Presentation
    ) {
        self.call = call
        self.status = status
        self._internalExpanded = State(initialValue: isExpanded)
        self.externalExpanded = nil
        self.presentation = presentation
    }

    public init(
        call: ToolCallInspection,
        status: ToolExecutionStatus = .completed,
        isExpanded: Binding<Bool>,
        @ViewBuilder presentation: @escaping () -> Presentation
    ) {
        self.call = call
        self.status = status
        self._internalExpanded = State(initialValue: isExpanded.wrappedValue)
        self.externalExpanded = isExpanded
        self.presentation = presentation
    }

    public var body: some View {
        DisclosureGroup(isExpanded: isExpandedBinding) {
            ToolCallInspectionView(call: call, status: status)
                .padding(.top, 4)
        } label: {
            HStack(spacing: 8) {
                presentation()

                Spacer(minLength: 4)

                if status == .running {
                    ProgressView()
                        .controlSize(.mini)
                } else if status == .failed {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .toolExecutionGlassEffect()
        .accessibilityElement(children: .contain)
        .accessibilityValue(isExpandedBinding.wrappedValue ? "Expanded" : "Collapsed")
    }
}

extension View {
    @ViewBuilder
    func toolExecutionGlassEffect() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: .rect(cornerRadius: 12))
        } else {
            self
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                )
        }
    }
}
