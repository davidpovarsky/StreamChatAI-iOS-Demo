import SwiftUI

struct SelectedModelMenu: View {
    @ObservedObject var viewModel: ChatViewModel
    let isDarkMode: Bool

    var body: some View {
        Menu {
            ForEach(AppConfig.shared.filteredModelTypes()) { model in
                Button {
                    viewModel.changeModel(to: model)
                } label: {
                    if viewModel.currentModel.id == model.id {
                        Label(model.displayName, systemImage: "checkmark")
                    } else {
                        Text(model.displayName)
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "cpu")
                    .font(.system(size: 14, weight: .semibold))
                Text(viewModel.currentModel.displayName)
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
        .disabled(viewModel.isLoading)
        .padding(.leading, 8)
        .accessibilityLabel("Selected model: \(viewModel.currentModel.displayName)")
    }
}
