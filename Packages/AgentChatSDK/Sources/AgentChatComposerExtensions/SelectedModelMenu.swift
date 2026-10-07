#if canImport(SwiftUI)
import SwiftUI
import AgentChatCore

public struct SelectedModelMenu: View {
    public let currentModel: ModelType
    public let availableModels: [ModelType]
    public let isDarkMode: Bool
    public let isLoading: Bool
    public let onSelect: (ModelType) -> Void

    public init(
        currentModel: ModelType,
        availableModels: [ModelType] = [.gpt4o, .gpt4oMini, .o1, .o3Mini],
        isDarkMode: Bool = false,
        isLoading: Bool = false,
        onSelect: @escaping (ModelType) -> Void
    ) {
        self.currentModel = currentModel
        self.availableModels = availableModels
        self.isDarkMode = isDarkMode
        self.isLoading = isLoading
        self.onSelect = onSelect
    }

    public var body: some View {
        Menu {
            ForEach(availableModels) { model in
                Button {
                    onSelect(model)
                } label: {
                    if currentModel.id == model.id {
                        Label(model.name, systemImage: "checkmark")
                    } else {
                        Text(model.name)
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "cpu")
                    .font(.system(size: 14, weight: .semibold))
                Text(currentModel.shortName)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.secondary.opacity(0.15))
            .clipShape(Capsule())
            .foregroundColor(isDarkMode ? .white : .primary)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: 168)
        .disabled(isLoading)
        .padding(.leading, 8)
        .accessibilityLabel("Selected model: \(currentModel.name)")
    }
}
#endif
