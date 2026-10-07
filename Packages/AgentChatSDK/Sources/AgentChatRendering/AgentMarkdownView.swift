#if canImport(SwiftUI)
import AgentChatCore
import SwiftUI

public struct AgentMarkdownView: View {
    public let text: String

    public init(text: String) {
        self.text = text
    }

    public var body: some View {
        if let attributed = try? AttributedString(markdown: text, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
            Text(attributed)
                .font(.system(size: 15))
                .lineSpacing(4)
                .textSelection(.enabled)
        } else {
            Text(text)
                .font(.system(size: 15))
                .lineSpacing(4)
                .textSelection(.enabled)
        }
    }
}
#endif
