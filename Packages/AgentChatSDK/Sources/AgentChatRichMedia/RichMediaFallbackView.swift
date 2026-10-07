#if canImport(SwiftUI)
import SwiftUI

public struct RichMediaFallbackView: View {
    public let icon: String
    public let title: String
    public let isDarkMode: Bool
    public var actionTitle: String?
    public var action: (() -> Void)?

    public init(icon: String, title: String, isDarkMode: Bool, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.isDarkMode = isDarkMode
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                if let actionTitle, let action {
                    Button(actionTitle, action: action)
                        .font(.caption.weight(.semibold))
                        .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .aspectRatio(16 / 9, contentMode: .fit)
    }
}
#endif
