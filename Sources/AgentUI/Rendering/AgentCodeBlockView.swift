// Sources/AgentUI/Rendering/AgentCodeBlockView.swift
#if canImport(SwiftUI)
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

public struct AgentCodeBlockView: View {
    public let code: String
    public let language: String?

    @State private var hasCopied = false
    @Environment(\.agentUITheme) private var theme
    @Environment(\.agentUIDesignTokens) private var tokens

    public init(code: String, language: String? = nil) {
        self.code = code
        self.language = language
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header bar with language & copy button
            HStack {
                Text(language?.uppercased() ?? "CODE")
                    .font(.caption2.weight(.bold).monospaced())
                    .foregroundStyle(theme.secondaryText)

                Spacer()

                Button {
                    copyToClipboard()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: hasCopied ? "checkmark" : "doc.on.doc")
                            .font(.caption2)
                        Text(hasCopied ? "Copied" : "Copy")
                            .font(.caption2.weight(.medium))
                    }
                    .foregroundStyle(hasCopied ? .green : theme.secondaryText)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(theme.surfaceBackground.opacity(0.8))

            Divider().opacity(0.2)

            // Scrollable Code Content
            ScrollView(.horizontal, showsIndicators: true) {
                Text(code)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(theme.primaryText)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(theme.codeBackground)
        .clipShape(RoundedRectangle(cornerRadius: tokens.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: tokens.cardCornerRadius)
                .strokeBorder(theme.borderColor, lineWidth: 0.5)
        )
        .padding(.vertical, 4)
    }

    private func copyToClipboard() {
        #if canImport(UIKit)
        UIPasteboard.general.string = code
        #endif
        hasCopied = true
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            hasCopied = false
        }
    }
}
#endif
