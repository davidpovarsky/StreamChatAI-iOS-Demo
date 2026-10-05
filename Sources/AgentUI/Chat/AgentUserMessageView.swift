// Sources/AgentUI/Chat/AgentUserMessageView.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentUserMessageView: View {
    public let message: AgentMessage

    @Environment(\.agentUITheme) private var theme
    @Environment(\.agentUIDesignTokens) private var tokens

    public init(message: AgentMessage) {
        self.message = message
    }

    public var body: some View {
        HStack {
            Spacer(minLength: 40)

            VStack(alignment: .trailing, spacing: 6) {
                Text(message.textContent)
                    .font(.body)
                    .foregroundStyle(theme.userBubbleForeground)
                    .padding(.horizontal, tokens.bubblePaddingHorizontal)
                    .padding(.vertical, tokens.bubblePaddingVertical)
                    .background(theme.userBubbleBackground)
                    .clipShape(RoundedRectangle(cornerRadius: tokens.bubbleCornerRadius))
                    .textSelection(.enabled)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 2)
    }
}
#endif
