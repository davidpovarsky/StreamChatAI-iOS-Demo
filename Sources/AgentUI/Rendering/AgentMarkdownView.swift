// Sources/AgentUI/Rendering/AgentMarkdownView.swift
#if canImport(SwiftUI)
import SwiftUI

private enum MarkdownSegment: Identifiable {
    case text(id: String, content: String)
    case code(id: String, language: String?, code: String)
    case math(id: String, formula: String)

    var id: String {
        switch self {
        case .text(let id, _): return id
        case .code(let id, _, _): return id
        case .math(let id, _): return id
        }
    }
}

public struct AgentMarkdownView: View {
    public let content: String

    @Environment(\.agentUITheme) private var theme

    public init(content: String) {
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(parseSegments(from: content)) { segment in
                switch segment {
                case .text(_, let text):
                    renderText(text)
                case .code(_, let language, let code):
                    AgentCodeBlockView(code: code, language: language)
                case .math(_, let formula):
                    AgentMathView(formula: formula, isBlock: true)
                }
            }
        }
    }

    @ViewBuilder
    private func renderText(_ text: String) -> some View {
        if let attr = try? AttributedString(markdown: text, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
            Text(attr)
                .font(.body)
                .foregroundStyle(theme.primaryText)
                .lineSpacing(4)
                .textSelection(.enabled)
        } else {
            Text(text)
                .font(.body)
                .foregroundStyle(theme.primaryText)
                .lineSpacing(4)
                .textSelection(.enabled)
        }
    }

    private func parseSegments(from raw: String) -> [MarkdownSegment] {
        var segments: [MarkdownSegment] = []
        let lines = raw.components(separatedBy: "\n")
        var currentText: [String] = []
        var inCodeBlock = false
        var codeLanguage: String? = nil
        var currentCode: [String] = []
        var inMathBlock = false
        var currentMath: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("```") {
                if inCodeBlock {
                    // Close code block
                    segments.append(.code(
                        id: UUID().uuidString,
                        language: codeLanguage,
                        code: currentCode.joined(separator: "\n")
                    ))
                    currentCode = []
                    codeLanguage = nil
                    inCodeBlock = false
                } else {
                    // Flush accumulated text
                    if !currentText.isEmpty {
                        segments.append(.text(id: UUID().uuidString, content: currentText.joined(separator: "\n")))
                        currentText = []
                    }
                    inCodeBlock = true
                    let lang = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                    codeLanguage = lang.isEmpty ? nil : lang
                }
                continue
            }

            if inCodeBlock {
                currentCode.append(line)
                continue
            }

            if trimmed.hasPrefix("$$") && trimmed.hasSuffix("$$") && trimmed.count > 4 {
                if !currentText.isEmpty {
                    segments.append(.text(id: UUID().uuidString, content: currentText.joined(separator: "\n")))
                    currentText = []
                }
                let formula = String(trimmed.dropFirst(2).dropLast(2))
                segments.append(.math(id: UUID().uuidString, formula: formula))
                continue
            }

            currentText.append(line)
        }

        if inCodeBlock && !currentCode.isEmpty {
            segments.append(.code(
                id: UUID().uuidString,
                language: codeLanguage,
                code: currentCode.joined(separator: "\n")
            ))
        }

        if !currentText.isEmpty {
            segments.append(.text(id: UUID().uuidString, content: currentText.joined(separator: "\n")))
        }

        return segments
    }
}
#endif
