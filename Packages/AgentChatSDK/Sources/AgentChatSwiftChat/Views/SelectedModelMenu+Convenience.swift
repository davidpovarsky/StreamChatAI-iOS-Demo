#if canImport(SwiftUI)
import SwiftUI
import AgentChatCore
import AgentChatComposerExtensions

extension SelectedModelMenu {
    public init(viewModel: ChatViewModel, isDarkMode: Bool) {
        self.init(
            currentModel: viewModel.currentModel,
            availableModels: AppConfig.shared.availableModels,
            isDarkMode: isDarkMode,
            isLoading: viewModel.isLoading
        ) { model in
            viewModel.changeModel(to: model)
        }
    }
}
#endif
