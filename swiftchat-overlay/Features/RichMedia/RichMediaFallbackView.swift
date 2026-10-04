import SwiftUI

struct RichMediaFallbackView: View {
    let icon: String
    let title: String
    let isDarkMode: Bool
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
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
