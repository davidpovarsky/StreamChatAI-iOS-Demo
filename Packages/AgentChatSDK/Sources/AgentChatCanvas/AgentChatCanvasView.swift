import SwiftUI
import AgentChatCore
import AgentChatMotion

public struct AgentChatCanvasView: View {
    @Binding public var documentText: String
    public let title: String
    public let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var isEditing = false

    public init(
        documentText: Binding<String>,
        title: String = "Canvas Document",
        onSave: @escaping (String) -> Void
    ) {
        self._documentText = documentText
        self.title = title
        self.onSave = onSave
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TextEditor(text: $documentText)
                    .font(.system(.body, design: .monospaced))
                    .padding()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(documentText)
                        dismiss()
                    }
                }
            }
        }
    }
}
