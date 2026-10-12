//
//  AgentChatMarkdownView.swift
//  AgentChatMarkdown
//
//  Canonical markdown, syntax-highlighted code and SwiftMath LaTeX renderer.
//

import SwiftUI
import Textual
import SwiftMath
#if canImport(UIKit)
import UIKit
#endif
import AgentChatCore

public enum TableAlignment: String, Sendable {
    case left
    case center
    case right

    public var viewAlignment: Alignment {
        switch self {
        case .left: return .leading
        case .center: return .center
        case .right: return .trailing
        }
    }

    #if canImport(UIKit)
    public var textAlignment: NSTextAlignment {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        }
    }
    #endif
}

public struct ParsedTable: Sendable {
    public let headers: [String]
    public let alignments: [TableAlignment]
    public let rows: [[String]]

    public init(headers: [String], alignments: [TableAlignment], rows: [[String]]) {
        self.headers = headers
        self.alignments = alignments
        self.rows = rows
    }
}

private enum SegmentKind: Sendable {
    case markdown(String)
    case latex(String, isDisplay: Bool)
    case table(ParsedTable)
}

private struct ContentSegment: Sendable {
    let id: String
    let kind: SegmentKind
}

private struct SegmentView: View {
    let segment: ContentSegment
    let isDarkMode: Bool
    let isStreaming: Bool

    var body: some View {
        switch segment.kind {
        case .markdown(let text):
            let strippedText = isStreaming ? text : AgentChatMarkdownView.stripCitations(from: text)
            StructuredText(markdown: strippedText)
                .textual.structuredTextStyle(.gitHub)
                .textual.highlighterTheme(isStreaming ? .plain : .default)
                .textual.textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
                .environment(\.colorScheme, isDarkMode ? .dark : .light)
        case .latex(let latex, let isDisplay):
            LaTeXView(
                latex: latex,
                isDisplay: isDisplay,
                isDarkMode: isDarkMode
            )
        case .table(let table):
            MarkdownTableView(
                table: table,
                isDarkMode: isDarkMode
            )
        }
    }
}

private class MarkdownRenderCache: @unchecked Sendable {
    static let shared = MarkdownRenderCache()

    private var cache: [String: [ContentSegment]] = [:]
    private let queue = DispatchQueue(label: "com.agentchat.markdown-cache", attributes: .concurrent)

    init() {
        #if canImport(UIKit)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        #endif
    }

    @objc private func handleMemoryWarning() {
        clear()
    }

    func get(for key: String) -> [ContentSegment]? {
        queue.sync { cache[key] }
    }

    func set(_ value: [ContentSegment], for key: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            if self.cache.count >= 200 {
                self.cache.removeAll()
            }
            self.cache[key] = value
        }
    }

    func clear() {
        queue.async(flags: .barrier) { [weak self] in
            self?.cache.removeAll()
        }
    }
}

public struct AgentChatMarkdownView: View {
    public let content: String
    public let isDarkMode: Bool
    public let isStreaming: Bool
    public let horizontalPadding: CGFloat
    public let maxWidthAlignment: Alignment

    @State private var segments: [ContentSegment]?

    public init(
        content: String,
        isDarkMode: Bool = false,
        isStreaming: Bool = false,
        horizontalPadding: CGFloat = 0,
        maxWidthAlignment: Alignment = .leading
    ) {
        self.content = content
        self.isDarkMode = isDarkMode
        self.isStreaming = isStreaming
        self.horizontalPadding = horizontalPadding
        self.maxWidthAlignment = maxWidthAlignment
    }

    public var body: some View {
        Group {
            if isStreaming {
                markdownFallback(content: content)
            } else if let segments = segments {
                ForEach(segments, id: \.id) { segment in
                    SegmentView(segment: segment, isDarkMode: isDarkMode, isStreaming: false)
                        .id(segment.id)
                }
            } else {
                markdownFallback(content: content)
            }
        }
        .environment(\.colorScheme, isDarkMode ? .dark : .light)
        .padding(.horizontal, horizontalPadding)
        .frame(maxWidth: horizontalPadding > 0 ? .infinity : nil, alignment: maxWidthAlignment)
        .transaction { transaction in
            transaction.animation = nil
        }
        .task(id: content) {
            guard !isStreaming else { return }
            let cacheKey = "\(content.hashValue)"
            if let cached = MarkdownRenderCache.shared.get(for: cacheKey) {
                if segments == nil {
                    segments = cached
                }
                return
            }
            let contentToProcess = content
            let parsed = Self.parseContent(contentToProcess)
            MarkdownRenderCache.shared.set(parsed, for: cacheKey)
            segments = parsed
        }
    }

    private func markdownFallback(content: String) -> some View {
        let strippedText = Self.stripCitations(from: content)
        return StructuredText(markdown: strippedText)
            .textual.structuredTextStyle(.gitHub)
            .textual.highlighterTheme(isStreaming ? .plain : .default)
            .textual.textSelection(.enabled)
            .fixedSize(horizontal: false, vertical: true)
            .environment(\.colorScheme, isDarkMode ? .dark : .light)
    }

    public static func stripCitations(from text: String) -> String {
        let chars = Array(text.unicodeScalars)
        let count = chars.count
        var result = String.UnicodeScalarView()
        result.reserveCapacity(count)
        var i = 0
        let citePrefix: [UnicodeScalar] = Array("#cite-".unicodeScalars)

        while i < count {
            var start = i
            if chars[start] == " " && start + 1 < count && chars[start + 1] == "[" {
                start += 1
            }
            guard start < count, chars[start] == "[" else {
                result.append(chars[i])
                i += 1
                continue
            }

            var j = start + 1
            guard j < count, chars[j] >= "0", chars[j] <= "9" else {
                result.append(chars[i])
                i += 1
                continue
            }
            while j < count, chars[j] >= "0", chars[j] <= "9" { j += 1 }
            guard j < count, chars[j] == "]" else {
                result.append(chars[i])
                i += 1
                continue
            }
            j += 1

            guard j < count, chars[j] == "(" else {
                result.append(chars[i])
                i += 1
                continue
            }
            j += 1
            var matches = true
            for c in citePrefix {
                guard j < count, chars[j] == c else { matches = false; break }
                j += 1
            }
            guard matches else {
                result.append(chars[i])
                i += 1
                continue
            }
            while j < count, chars[j] >= "0", chars[j] <= "9" { j += 1 }
            guard j < count, chars[j] == "~" else {
                result.append(chars[i])
                i += 1
                continue
            }
            j += 1

            var foundTilde = false
            while j < count {
                if chars[j] == "~" {
                    foundTilde = true
                    break
                }
                j += 1
            }

            guard foundTilde else {
                for k in i..<j { result.append(chars[k]) }
                i = j
                continue
            }
            j += 1

            var depth = 1
            var found = false
            while j < count {
                if chars[j] == "(" {
                    depth += 1
                } else if chars[j] == ")" {
                    depth -= 1
                    if depth == 0 {
                        j += 1
                        found = true
                        break
                    }
                }
                j += 1
            }

            if found {
                i = j
            } else {
                result.append(chars[i])
                i += 1
            }
        }

        return String(result)
    }

    private static func parseContent(_ content: String) -> [ContentSegment] {
        var segments: [ContentSegment] = []
        let lines = content.components(separatedBy: "\n")
        var currentMarkdown: [String] = []
        var i = 0

        while i < lines.count {
            let line = lines[i]

            // Check display latex $$
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("$$") {
                if !currentMarkdown.isEmpty {
                    let text = currentMarkdown.joined(separator: "\n")
                    segments.append(ContentSegment(id: UUID().uuidString, kind: .markdown(text)))
                    currentMarkdown.removeAll()
                }

                var latexLines: [String] = []
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed == "$$" {
                    i += 1
                    while i < lines.count && !lines[i].trimmingCharacters(in: .whitespaces).hasPrefix("$$") {
                        latexLines.append(lines[i])
                        i += 1
                    }
                    if i < lines.count { i += 1 }
                } else {
                    let mathContent = trimmed.dropFirst(2).dropLast(trimmed.hasSuffix("$$") ? 2 : 0)
                    latexLines.append(String(mathContent))
                    i += 1
                }
                let latexStr = latexLines.joined(separator: "\n")
                segments.append(ContentSegment(id: UUID().uuidString, kind: .latex(latexStr, isDisplay: true)))
                continue
            }

            // Check table
            if line.contains("|") && i + 1 < lines.count && isTableDelimiter(lines[i + 1]) {
                if !currentMarkdown.isEmpty {
                    let text = currentMarkdown.joined(separator: "\n")
                    segments.append(ContentSegment(id: UUID().uuidString, kind: .markdown(text)))
                    currentMarkdown.removeAll()
                }

                let headerLine = line
                let delimiterLine = lines[i + 1]
                var rowLines: [String] = []
                i += 2
                while i < lines.count && lines[i].contains("|") && !lines[i].trimmingCharacters(in: .whitespaces).isEmpty {
                    rowLines.append(lines[i])
                    i += 1
                }

                if let table = parseTable(headers: headerLine, delimiter: delimiterLine, rows: rowLines) {
                    segments.append(ContentSegment(id: UUID().uuidString, kind: .table(table)))
                }
                continue
            }

            currentMarkdown.append(line)
            i += 1
        }

        if !currentMarkdown.isEmpty {
            let text = currentMarkdown.joined(separator: "\n")
            segments.append(ContentSegment(id: UUID().uuidString, kind: .markdown(text)))
        }

        return segments
    }

    private static func isTableDelimiter(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard trimmed.contains("-") && trimmed.contains("|") else { return false }
        let allowed = CharacterSet(charactersIn: "|- :")
        return CharacterSet(charactersIn: trimmed).isSubset(of: allowed)
    }

    private static func parseTable(headers: String, delimiter: String, rows: [String]) -> ParsedTable? {
        let cleanRow: (String) -> [String] = { line in
            line.split(separator: "|", omittingEmptySubsequences: false)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        }

        let headerCells = cleanRow(headers)
        let delimiterCells = cleanRow(delimiter)
        guard !headerCells.isEmpty else { return nil }

        let alignments = delimiterCells.map { cell -> TableAlignment in
            let hasLeading = cell.hasPrefix(":")
            let hasTrailing = cell.hasSuffix(":")
            if hasLeading && hasTrailing { return .center }
            if hasTrailing { return .right }
            return .left
        }

        let rowData = rows.map { cleanRow($0) }
        return ParsedTable(headers: headerCells, alignments: alignments, rows: rowData)
    }
}

// MARK: - Table Views

private struct MarkdownTableView: View {
    let table: ParsedTable
    let isDarkMode: Bool

    @State private var columnWidths: [Int: CGFloat] = [:]

    private var borderColor: Color {
        isDarkMode ? Color.white.opacity(0.15) : Color.black.opacity(0.1)
    }

    private var headerBackground: Color {
        isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.03)
    }

    private var alternatingRowBackground: Color {
        isDarkMode ? Color.white.opacity(0.02) : Color.black.opacity(0.015)
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            VStack(spacing: 0) {
                if !table.headers.isEmpty {
                    MarkdownTableRowView(
                        cells: table.headers,
                        alignments: table.alignments,
                        isHeader: true,
                        isDarkMode: isDarkMode,
                        borderColor: borderColor,
                        background: headerBackground,
                        columnWidths: columnWidths
                    )
                    Rectangle().fill(borderColor).frame(height: 1)
                }

                ForEach(table.rows.indices, id: \.self) { index in
                    MarkdownTableRowView(
                        cells: table.rows[index],
                        alignments: table.alignments,
                        isHeader: false,
                        isDarkMode: isDarkMode,
                        borderColor: borderColor,
                        background: index.isMultiple(of: 2) ? alternatingRowBackground : Color.clear,
                        columnWidths: columnWidths
                    )
                    if index < table.rows.count - 1 {
                        Rectangle().fill(borderColor).frame(height: 1)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(borderColor, lineWidth: 1))
        }
        .padding(.vertical, 8)
        .onAppear {
            if columnWidths.isEmpty {
                columnWidths = Self.measureWidths(for: table)
            }
        }
    }

    private static func measureWidths(for table: ParsedTable) -> [Int: CGFloat] {
        var widths: [Int: CGFloat] = [:]
        for (i, h) in table.headers.enumerated() {
            widths[i] = min(CGFloat(max(h.count * 10 + 24, 60)), 300)
        }
        for row in table.rows {
            for (i, c) in row.enumerated() {
                let w = min(CGFloat(max(c.count * 10 + 24, 60)), 300)
                widths[i] = max(widths[i] ?? 0, w)
            }
        }
        return widths
    }
}

private struct MarkdownTableRowView: View {
    let cells: [String]
    let alignments: [TableAlignment]
    let isHeader: Bool
    let isDarkMode: Bool
    let borderColor: Color
    let background: Color
    let columnWidths: [Int: CGFloat]

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(cells.indices, id: \.self) { index in
                Text(cells[index])
                    .font(.system(size: 14, weight: isHeader ? .semibold : .regular))
                    .foregroundColor(isDarkMode ? .white : .black)
                    .padding(.vertical, isHeader ? 8 : 6)
                    .padding(.horizontal, 10)
                    .frame(
                        width: columnWidths[index],
                        alignment: alignments.indices.contains(index) ? alignments[index].viewAlignment : .leading
                    )
                    .background(background)

                if index < cells.count - 1 {
                    Rectangle().fill(borderColor).frame(width: 1)
                }
            }
        }
    }
}

// MARK: - LaTeX Math Views

public struct LaTeXView: View {
    public let latex: String
    public let isDisplay: Bool
    public let isDarkMode: Bool

    public init(latex: String, isDisplay: Bool, isDarkMode: Bool) {
        self.latex = latex
        self.isDisplay = isDisplay
        self.isDarkMode = isDarkMode
    }

    public var body: some View {
        if isDisplay {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    MathView(latex: latex, displayMode: true, isDarkMode: isDarkMode)
                        .fixedSize()
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        } else {
            MathView(latex: latex, displayMode: false, isDarkMode: isDarkMode)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        }
    }
}

#if canImport(UIKit)
public struct MathView: UIViewRepresentable {
    public let latex: String
    public let displayMode: Bool
    public let isDarkMode: Bool

    public init(latex: String, displayMode: Bool, isDarkMode: Bool) {
        self.latex = latex
        self.displayMode = displayMode
        self.isDarkMode = isDarkMode
    }

    public func makeUIView(context: Context) -> MTMathUILabel {
        let label = MTMathUILabel()
        label.latex = latex
        label.labelMode = displayMode ? .display : .text
        label.textColor = isDarkMode ? .white : .black.withAlphaComponent(0.85)
        label.fontSize = displayMode ? 18 : 16
        label.textAlignment = displayMode ? .center : .left
        label.backgroundColor = .clear
        label.isUserInteractionEnabled = true
        label.contentInsets = UIEdgeInsets(top: 6, left: 2, bottom: 6, right: 2)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.sizeToFit()
        return label
    }

    public func updateUIView(_ uiView: MTMathUILabel, context: Context) {
        uiView.latex = latex
        uiView.labelMode = displayMode ? .display : .text
        uiView.textColor = isDarkMode ? .white : .black.withAlphaComponent(0.85)
        uiView.fontSize = displayMode ? 18 : 16
        uiView.textAlignment = displayMode ? .center : .left
        uiView.contentInsets = UIEdgeInsets(top: 6, left: 2, bottom: 6, right: 2)
        uiView.sizeToFit()
    }
}
#else
public struct MathView: View {
    public let latex: String
    public let displayMode: Bool
    public let isDarkMode: Bool

    public var body: some View {
        Text(latex)
            .font(.system(.body, design: .serif))
    }
}
#endif
