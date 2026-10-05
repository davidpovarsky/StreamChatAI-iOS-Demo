//
//  SelectedModelMenu.swift
//  AgentUI
//
//  Extracted existing SelectedModelMenu unchanged.
//

import SwiftUI

public struct AgentSelectedModelMenu: View {
    public let currentModelId: String
    public let currentModelDisplayName: String
    public let availableModels: [AgentModelDescriptor]
    public let isLoading: Bool
    public let isDarkMode: Bool
    public let onSelectModel: (AgentModelDescriptor) -> Void

    public init(
        currentModelId: String,
        currentModelDisplayName: String,
        availableModels: [AgentModelDescriptor],
        isLoading: Bool,
        isDarkMode: Bool,
        onSelectModel: @escaping (AgentModelDescriptor) -> Void
    ) {
        self.currentModelId = currentModelId
        self.currentModelDisplayName = currentModelDisplayName
        self.availableModels = availableModels
        self.isLoading = isLoading
        self.isDarkMode = isDarkMode
        self.onSelectModel = onSelectModel
    }

    public var body: some View {
        Menu {
            ForEach(availableModels) { model in
                Button {
                    onSelectModel(model)
                } label: {
                    if currentModelId == model.id {
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
                Text(currentModelDisplayName)
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
        .accessibilityLabel("Selected model: \(currentModelDisplayName)")
    }
}
