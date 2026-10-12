import SwiftUI

public struct AgentTranscriptEmptyView: View {
    public let assistantName: String
    public let onSelectPrompt: (String) -> Void

    public init(assistantName: String = "Assistant", onSelectPrompt: @escaping (String) -> Void) {
        self.assistantName = assistantName
        self.onSelectPrompt = onSelectPrompt
    }

    private let suggestions = [
        "Research SwiftUI agent UI architectures and summarize findings",
        "Create a budget calculator form with slider and total calculation",
        "Analyze monthly revenue data and show interactive chart",
        "Schedule a team design review meeting for Tuesday"
    ]

    public var body: some View {
        VStack(spacing: 20) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)

                Text("How can I help you today?")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)

                Text("100% Native SwiftUI Agent UI SDK with Hierarchical Activity")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 10) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button {
                        onSelectPrompt(suggestion)
                    } label: {
                        HStack {
                            Text(suggestion)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.secondary.opacity(0.08))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: 520)
            .padding(.horizontal, 20)

            Spacer()
        }
    }
}

public struct AgentScrollToBottomButton: View {
    public let count: Int
    public let onScrollToBottom: () -> Void

    public init(count: Int = 0, onScrollToBottom: @escaping () -> Void) {
        self.count = count
        self.onScrollToBottom = onScrollToBottom
    }

    public var body: some View {
        Button(action: onScrollToBottom) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .bold))

                if count > 0 {
                    Text("\(count) new")
                        .font(.system(size: 11, weight: .semibold))
                }
            }
            .foregroundColor(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: Color.black.opacity(0.12), radius: 6, y: 3)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Scroll to bottom")
    }
}
