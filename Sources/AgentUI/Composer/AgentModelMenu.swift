// Sources/AgentUI/Composer/AgentModelMenu.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentModelMenu: View {
    public let models: [AgentModelDescriptor]
    public let selectedModel: AgentModelDescriptor
    public let isDisabled: Bool
    public let onSelect: (AgentModelDescriptor) -> Void

    @Environment(\.agentUITheme) private var theme

    public init(
        models: [AgentModelDescriptor],
        selectedModel: AgentModelDescriptor,
        isDisabled: Bool = false,
        onSelect: @escaping (AgentModelDescriptor) -> Void
    ) {
        self.models = models
        self.selectedModel = selectedModel
        self.isDisabled = isDisabled
        self.onSelect = onSelect
    }

    public var body: some View {
        Menu {
            ForEach(models) { model in
                Button {
                    onSelect(model)
                } label: {
                    if model.id == selectedModel.id {
                        Label(model.displayName, systemImage: "checkmark")
                    } else {
                        Label(model.displayName, systemImage: model.iconSystemName)
                    }
                }
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: selectedModel.iconSystemName)
                    .font(.system(size: 11, weight: .semibold))
                Text(selectedModel.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(theme.tertiaryText)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(theme.surfaceBackground)
            .clipShape(Capsule())
            .foregroundStyle(theme.primaryText)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .accessibilityLabel("Select Model: \(selectedModel.displayName)")
    }
}
#endif
