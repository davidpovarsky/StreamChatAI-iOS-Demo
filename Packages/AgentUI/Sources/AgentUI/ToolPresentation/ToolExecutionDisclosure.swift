//
//  ToolExecutionDisclosure.swift
//  AgentUI
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
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpandedBinding.wrappedValue.toggle()
                }
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

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpandedBinding.wrappedValue ? 90 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpandedBinding.wrappedValue)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpandedBinding.wrappedValue {
                ToolCallInspectionView(call: call, status: status)
                    .padding(.top, 8)
                    .transition(.opacity)
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
    public func toolExecutionGlassEffect() -> some View {
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
