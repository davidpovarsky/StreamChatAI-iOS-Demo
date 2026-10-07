#if canImport(SwiftUI)
import AgentChatCore
import SwiftUI
#if canImport(EmojiKit)
import EmojiKit
#endif

public struct AgentEmojiPicker: View {
    public let onSelectEmoji: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    private let defaultEmojis = [
        "😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "😊", "😇",
        "🙂", "🙃", "😉", "😌", "😍", "🥰", "😘", "😗", "😙", "😚",
        "😋", "😛", "😝", "😜", "🤪", "🤨", "🧐", "🤓", "😎", "🥸",
        "🤩", "🥳", "😏", "😒", "😞", "😔", "😟", "😕", "🙁", "☹️",
        "😣", "😖", "😫", "😩", "🥺", "😢", "😭", "😮‍💨", "😤", "😠",
        "👍", "👎", "👏", "🙌", "👐", "🤲", "🤝", "🙏", "✌️", "🤞",
        "🤟", "🤘", "🤙", "👈", "👉", "👆", "🖕", "👇", "☝️", "👋",
        "🔥", "✨", "🎉", "❤️", "🚀", "💡", "💯", "✅", "⚠️", "❌"
    ]

    public init(onSelectEmoji: @escaping (String) -> Void) {
        self.onSelectEmoji = onSelectEmoji
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                    ForEach(defaultEmojis, id: \.self) { emoji in
                        Button {
                            onSelectEmoji(emoji)
                            dismiss()
                        } label: {
                            Text(emoji)
                                .font(.system(size: 28))
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Emojis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
#endif
