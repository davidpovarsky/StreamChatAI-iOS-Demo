import SwiftUI
import AgentUI

struct SelectedModelMenu: View {
    @ObservedObject var viewModel: ChatViewModel
    let isDarkMode: Bool

    var body: some View {
        AgentSelectedModelMenu(
            currentModelId: viewModel.currentModel.id,
            currentModelDisplayName: viewModel.currentModel.displayName,
            availableModels: AppConfig.shared.filteredModelTypes().map {
                AgentModelDescriptor(
                    id: $0.id,
                    displayName: $0.displayName,
                    fullName: $0.fullName,
                    iconName: $0.iconName,
                    isMultimodal: $0.isMultimodal
                )
            },
            isLoading: viewModel.isLoading,
            isDarkMode: isDarkMode,
            onSelectModel: { selected in
                if let model = AppConfig.shared.filteredModelTypes().first(where: { $0.id == selected.id }) {
                    viewModel.changeModel(to: model)
                }
            }
        )
    }
}
