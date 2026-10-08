#if canImport(SwiftUI)
import SwiftUI
#if canImport(EmojiKit)
import EmojiKit
#endif
import AgentChatCore

/// Additive emoji picker popover/sheet using `EmojiKit`.
/// Injected cleanly into SwiftChat's '+' composer menu.
public struct AgentEmojiPicker: View {
    @Binding public var text: String
    public let isDarkMode: Bool
    public var onDismiss: () -> Void

    public init(
        text: Binding<String>,
        isDarkMode: Bool = false,
        onDismiss: @escaping () -> Void = {}
    ) {
        self._text = text
        self.isDarkMode = isDarkMode
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationStack {
            emojiContent
                .navigationTitle("Emojis")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") {
                            onDismiss()
                        }
                    }
                }
        }
    }

    @ViewBuilder
    private var emojiContent: some View {
#if canImport(EmojiKit)
        EmojiScrollGrid(
            emojis: Emoji.all,
            action: { emoji in
                text.append(emoji.char)
            },
            section: { $0.view },
            item: { $0.view }
        )
#else
        // Fallback standard emoji matrix
        let fallbackEmojis = ["😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "😊", "😇", "🙂", "🙃", "😉", "😌", "😍", "🥰", "😘", "😗", "😙", "😚", "😋", "😛", "😝", "😜", "🤪", "🤨", "🧐", "🤓", "😎", "🤩", "🥳", "😏", "😒", "😞", "😔", "😟", "😕", "🙁", "☹️", "😣", "😖", "😫", "😩", "🥺", "😢", "😭", "😤", "😠", "😡", "🤬", "🤯", "😳", "🥵", "🥶", "😱", "😨", "😰", "😥", "😓", "🤗", "🤔", "🤭", "🤫", "🤥", "😶", "😐", "😑", "😬", "🙄", "😯", "😦", "😧", "😮", "😲", "🥱", "😴", "🤤", "😪", "😵", "🤐", "🥴", "🤢", "🤮", "🤧", "😷", "🤒", "🤕", "🤑", "🤠", "😈", "👿", "👹", "👺", "🤡", "💩", "👻", "💀", "☠️", "👽", "👾", "🤖", "🎃", "😺", "😸", "😹", "😻", "😼", "😽", "🙀", "😿", "😾", "👋", "🤚", "🖐", "✋", "🖖", "👌", "🤌", "🤏", "✌️", "🤞", "🤟", "🤘", "🤙", "👈", "👉", "👆", "🖕", "👇", "☝️", "👍", "👎", "✊", "👊", "🤛", "🤜", "👏", "🙌", "👐", "🤲", "🤝", "🙏", "✍️", "💅", "🤳", "💪", "🦾", "🦿", "🦵", "🦶", "👂", "🦻", "👃", "🫀", "🫁", "🧠", "🦷", "🦴", "👀", "👁", "👅", "👄", "💋", "🩸"]
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 12) {
                ForEach(fallbackEmojis, id: \.self) { emoji in
                    Button(emoji) {
                        text.append(emoji)
                    }
                    .font(.system(size: 28))
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
#endif
    }
}
#endif
