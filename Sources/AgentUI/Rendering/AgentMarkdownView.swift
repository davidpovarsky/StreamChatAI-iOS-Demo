// Sources/AgentUI/Rendering/AgentMarkdownView.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentMarkdownView: View {
    public let content: String
    public var sectionSources: [AgentSource]?

    @Environment(\.agentUITheme) private var theme
    @Environment(\.agentUIDesignTokens) private var tokens

    public init(content: String, sectionSources: [AgentSource]? = nil) {
        self.content = content
        self.sectionSources = sectionSources
    }

    private var blocks: [AgentMarkdownBlock] {
        AgentMarkdownParser.parse(content)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(blocks) { block in
                renderBlock(block)
            }
        }
    }

    @ViewBuilder
    private func renderBlock(_ block: AgentMarkdownBlock) -> some View {
        switch block {
        case .heading(_, let level, let text):
            headingView(level: level, text: text)

        case .paragraph(_, let text):
            paragraphView(text: text)

        case .blockquote(_, let text):
            blockquoteView(text: text)

        case .unorderedList(_, let items):
            unorderedListView(items: items)

        case .orderedList(_, let items):
            orderedListView(items: items)

        case .codeBlock(_, let language, let code):
            AgentCodeBlockView(code: code, language: language)

        case .mathBlock(_, let formula):
            AgentMathView(formula: formula, isBlock: true)

        case .horizontalRule:
            Divider()
                .opacity(tokens.borderOpacity)
                .padding(.vertical, 4)

        case .table(_, let headers, let rows):
            tableView(headers: headers, rows: rows)
        }
    }

    @ViewBuilder
    private func headingView(level: Int, text: String) -> some View {
        let titleFont: Font = {
            switch level {
            case 1: return .title.bold()
            case 2: return .title2.bold()
            case 3: return .title3.weight(.semibold)
            case 4: return .headline
            default: return .subheadline.bold()
            }
        }()

        Text(text)
            .font(titleFont)
            .foregroundStyle(theme.primaryText)
            .padding(.top, level <= 2 ? 6 : 2)
            .textSelection(.enabled)
    }

    @ViewBuilder
    private func paragraphView(text: String) -> some View {
        if text.contains("$") {
            inlineMathParagraphView(text: text)
        } else if let attr = try? AttributedString(markdown: text, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
            if let sources = sectionSources, !sources.isEmpty {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text(attr)
                            .font(.body)
                            .foregroundStyle(theme.primaryText)
                            .lineSpacing(4)
                        AgentSectionSources(sectionID: "inline", sources: sources)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(attr)
                            .font(.body)
                            .foregroundStyle(theme.primaryText)
                            .lineSpacing(4)
                        AgentSectionSources(sectionID: "inline", sources: sources)
                    }
                }
                .textSelection(.enabled)
            } else {
                Text(attr)
                    .font(.body)
                    .foregroundStyle(theme.primaryText)
                    .lineSpacing(4)
                    .textSelection(.enabled)
            }
        } else {
            Text(text)
                .font(.body)
                .foregroundStyle(theme.primaryText)
                .lineSpacing(4)
                .textSelection(.enabled)
        }
    }

    @ViewBuilder
    private func inlineMathParagraphView(text: String) -> some View {
        // Split by $ to extract inline math expressions
        let parts = text.components(separatedBy: "$")
        if parts.count >= 3 {
            HStack(alignment: .center, spacing: 4) {
                ForEach(Array(parts.enumerated()), id: \.offset) { idx, part in
                    if idx % 2 == 1 {
                        // Math part
                        AgentMathView(formula: part, isBlock: false)
                    } else if !part.isEmpty {
                        // Regular text part
                        if let attr = try? AttributedString(markdown: part, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
                            Text(attr)
                                .font(.body)
                                .foregroundStyle(theme.primaryText)
                        } else {
                            Text(part)
                                .font(.body)
                                .foregroundStyle(theme.primaryText)
                        }
                    }
                }
            }
            .textSelection(.enabled)
        } else {
            Text(text)
                .font(.body)
                .foregroundStyle(theme.primaryText)
                .textSelection(.enabled)
        }
    }

    @ViewBuilder
    private func blockquoteView(text: String) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(theme.accentColor)
                .frame(width: 3)

            Text(text)
                .font(.body.italic())
                .foregroundStyle(theme.secondaryText)
                .lineSpacing(3)
                .textSelection(.enabled)
        }
        .padding(.vertical, 2)
        .padding(.leading, 4)
    }

    @ViewBuilder
    private func unorderedListView(items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .font(.body.bold())
                        .foregroundStyle(theme.accentColor)
                        .frame(width: 12, alignment: .center)

                    if let attr = try? AttributedString(markdown: item, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
                        Text(attr)
                            .font(.body)
                            .foregroundStyle(theme.primaryText)
                            .textSelection(.enabled)
                    } else {
                        Text(item)
                            .font(.body)
                            .foregroundStyle(theme.primaryText)
                            .textSelection(.enabled)
                    }
                }
            }
        }
        .padding(.leading, 4)
    }

    @ViewBuilder
    private func orderedListView(items: [(number: Int, text: String)]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(item.number).")
                        .font(.body.monospacedDigit())
                        .foregroundStyle(theme.secondaryText)
                        .frame(minWidth: 20, alignment: .trailing)

                    if let attr = try? AttributedString(markdown: item.text, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
                        Text(attr)
                            .font(.body)
                            .foregroundStyle(theme.primaryText)
                            .textSelection(.enabled)
                    } else {
                        Text(item.text)
                            .font(.body)
                            .foregroundStyle(theme.primaryText)
                            .textSelection(.enabled)
                    }
                }
            }
        }
        .padding(.leading, 4)
    }

    @ViewBuilder
    private func tableView(headers: [String], rows: [[String]]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 12) {
                ForEach(Array(headers.enumerated()), id: \.offset) { _, header in
                    Text(header)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(theme.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(theme.surfaceBackground)

            Divider()

            // Rows
            ForEach(Array(rows.enumerated()), id: \.offset) { rIdx, row in
                HStack(spacing: 12) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, cell in
                        Text(cell)
                            .font(.caption)
                            .foregroundStyle(theme.primaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(rIdx % 2 == 1 ? theme.surfaceBackground.opacity(0.5) : Color.clear)

                if rIdx < rows.count - 1 {
                    Divider().opacity(0.3)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(theme.borderColor, lineWidth: 0.5)
        )
        .padding(.vertical, 4)
    }
}
#endif
