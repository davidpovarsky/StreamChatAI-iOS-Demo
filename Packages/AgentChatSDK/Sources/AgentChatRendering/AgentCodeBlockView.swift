#if canImport(SwiftUI)
import AgentChatCore
import SwiftUI
#if canImport(Highlightr)
import Highlightr
#endif
#if canImport(UIKit)
import UIKit
#endif

public struct AgentCodeTheme: Sendable, Equatable {
    public var name: String

    public static let atomOneDark = AgentCodeTheme(name: "atom-one-dark")
    public static let github = AgentCodeTheme(name: "github")
    public static let vs = AgentCodeTheme(name: "vs")
    public static let xcode = AgentCodeTheme(name: "xcode")
}

public struct AgentCodeBlockView: View {
    public let code: String
    public let language: String?
    public var theme: AgentCodeTheme
    public var lineWrapping: Bool

    @State private var isCopied = false
    @Environment(\.colorScheme) private var colorScheme

    public init(
        code: String,
        language: String? = nil,
        theme: AgentCodeTheme = .atomOneDark,
        lineWrapping: Bool = false
    ) {
        self.code = code
        self.language = language
        self.theme = theme
        self.lineWrapping = lineWrapping
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerBar

            Divider()
                .overlay(Color.white.opacity(0.1))

            codeContainer
        }
        .background(Color(red: 0.12, green: 0.13, blue: 0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5)
        )
    }

    private var headerBar: some View {
        HStack {
            Text(languageDisplay)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color.white.opacity(0.7))

            Spacer()

            Button {
                copyCode()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 11))
                    Text(isCopied ? "Copied" : "Copy")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundStyle(isCopied ? .green : Color.white.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.04))
    }

    @ViewBuilder
    private var codeContainer: some View {
        if lineWrapping {
            highlightedText
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            ScrollView(.horizontal, showsIndicators: true) {
                highlightedText
                    .padding(12)
            }
        }
    }

    @ViewBuilder
    private var highlightedText: some View {
        #if canImport(Highlightr) && canImport(UIKit)
        if let highlightr = HighlightrWrapper.shared.highlightr,
           let highlighted = highlightr.highlight(code, as: language) {
            Text(AttributedString(highlighted))
                .font(.system(size: 13, design: .monospaced))
                .textSelection(.enabled)
        } else {
            fallbackCodeText
        }
        #else
        fallbackCodeText
        #endif
    }

    private var fallbackCodeText: some View {
        Text(code)
            .font(.system(size: 13, design: .monospaced))
            .foregroundStyle(Color.white.opacity(0.92))
            .textSelection(.enabled)
    }

    private var languageDisplay: String {
        guard let lang = language, !lang.isEmpty else { return "Code" }
        return lang.lowercased()
    }

    private func copyCode() {
        #if canImport(UIKit)
        UIPasteboard.general.string = code
        #endif
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            isCopied = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                isCopied = false
            }
        }
    }
}

#if canImport(Highlightr)
private final class HighlightrWrapper: @unchecked Sendable {
    static let shared = HighlightrWrapper()
    let highlightr: Highlightr?

    init() {
        self.highlightr = Highlightr()
        self.highlightr?.setTheme(to: "atom-one-dark")
    }
}
#endif
#endif
