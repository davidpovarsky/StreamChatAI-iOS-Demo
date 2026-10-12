import SwiftUI
import AgentChatCore

public struct AgentConversationHeaderView: View {
    public let title: String
    @Binding public var selectedModel: AgentModel
    public let availableModels: [AgentModel]
    public let onNewChat: () -> Void
    public let onClearChat: () -> Void

    public init(
        title: String,
        selectedModel: Binding<AgentModel>,
        availableModels: [AgentModel] = AgentModel.defaultModels,
        onNewChat: @escaping () -> Void,
        onClearChat: @escaping () -> Void
    ) {
        self.title = title
        self._selectedModel = selectedModel
        self.availableModels = availableModels
        self.onNewChat = onNewChat
        self.onClearChat = onClearChat
    }

    public var body: some View {
        HStack {
            Menu {
                ForEach(availableModels) { model in
                    Button {
                        selectedModel = model
                    } label: {
                        HStack {
                            Text(model.name)
                            if model.id == selectedModel.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 5) {
                    Text(selectedModel.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Menu {
                Button(action: onNewChat) {
                    Label("New Chat", systemImage: "square.and.pencil")
                }
                Divider()
                Button(role: .destructive, action: onClearChat) {
                    Label("Clear Messages", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
