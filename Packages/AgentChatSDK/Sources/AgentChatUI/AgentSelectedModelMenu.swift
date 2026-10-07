#if canImport(SwiftUI)
import AgentChatCore
import SwiftUI

public struct AgentSelectedModelMenu: View {
    @Binding public var selectedModel: AgentModelItem?
    public let availableModels: [AgentModelItem]
    public let isDisabled: Bool

    @Environment(\.colorScheme) private var colorScheme

    public init(
        selectedModel: Binding<AgentModelItem?>,
        availableModels: [AgentModelItem],
        isDisabled: Bool = false
    ) {
        self._selectedModel = selectedModel
        self.availableModels = availableModels
        self.isDisabled = isDisabled
    }

    public var body: some View {
        Menu {
            ForEach(availableModels) { model in
                Button {
                    selectedModel = model
                } label: {
                    if selectedModel?.id == model.id {
                        Label(model.displayName, systemImage: "checkmark")
                    } else {
                        Text(model.displayName)
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "cpu")
                    .font(.system(size: 13, weight: .semibold))
                Text(selectedModel?.displayName ?? "Select Model")
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .bold))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.secondary.opacity(0.12), in: Capsule())
            .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .accessibilityLabel("Selected AI Model: \(selectedModel?.displayName ?? "None")")
    }
}
#endif
