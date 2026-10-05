// Sources/AgentUI/Rendering/Markdown/AgentMarkdownParser.swift
import Foundation

public enum AgentMarkdownParser {
    public static func parse(_ text: String) -> [AgentMarkdownBlock] {
        var blocks: [AgentMarkdownBlock] = []
        let lines = text.components(separatedBy: "\n")
        var lineIndex = 0
        var blockOrdinal = 0

        while lineIndex < lines.count {
            let line = lines[lineIndex]
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // 1. Empty lines
            if trimmed.isEmpty {
                lineIndex += 1
                continue
            }

            // 2. Fenced code block
            if trimmed.hasPrefix("```") {
                let lang = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                let codeLanguage = lang.isEmpty ? nil : lang
                var codeLines: [String] = []
                lineIndex += 1

                while lineIndex < lines.count {
                    let current = lines[lineIndex]
                    if current.trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                        lineIndex += 1
                        break
                    }
                    codeLines.append(current)
                    lineIndex += 1
                }

                let id = "blk-\(blockOrdinal)-code"
                blockOrdinal += 1
                blocks.append(.codeBlock(id: id, language: codeLanguage, code: codeLines.joined(separator: "\n")))
                continue
            }

            // 3. Block math $$...$$
            if trimmed.hasPrefix("$$") {
                var formulaLines: [String] = []
                if trimmed.hasSuffix("$$") && trimmed.count > 4 {
                    // Single line $$formula$$
                    let formula = String(trimmed.dropFirst(2).dropLast(2))
                    let id = "blk-\(blockOrdinal)-math"
                    blockOrdinal += 1
                    blocks.append(.mathBlock(id: id, formula: formula))
                    lineIndex += 1
                    continue
                } else {
                    // Multi-line $$ ... $$
                    let first = String(trimmed.dropFirst(2))
                    if !first.isEmpty { formulaLines.append(first) }
                    lineIndex += 1
                    while lineIndex < lines.count {
                        let current = lines[lineIndex].trimmingCharacters(in: .whitespaces)
                        if current.hasSuffix("$$") {
                            let last = String(current.dropLast(2))
                            if !last.isEmpty { formulaLines.append(last) }
                            lineIndex += 1
                            break
                        }
                        formulaLines.append(lines[lineIndex])
                        lineIndex += 1
                    }
                    let id = "blk-\(blockOrdinal)-math"
                    blockOrdinal += 1
                    blocks.append(.mathBlock(id: id, formula: formulaLines.joined(separator: "\n")))
                    continue
                }
            }

            // 4. Horizontal rules (---, ***, ___)
            if trimmed == "---" || trimmed == "***" || trimmed == "___" {
                let id = "blk-\(blockOrdinal)-hr"
                blockOrdinal += 1
                blocks.append(.horizontalRule(id: id))
                lineIndex += 1
                continue
            }

            // 5. Headings (# H1, ## H2, ### H3, #### H4)
            if trimmed.hasPrefix("#") {
                var level = 0
                for ch in trimmed {
                    if ch == "#" { level += 1 } else { break }
                }
                if level >= 1 && level <= 6 {
                    let remainder = String(trimmed.dropFirst(level)).trimmingCharacters(in: .whitespaces)
                    let id = "blk-\(blockOrdinal)-h\(level)"
                    blockOrdinal += 1
                    blocks.append(.heading(id: id, level: level, text: remainder))
                    lineIndex += 1
                    continue
                }
            }

            // 6. Blockquotes (> ...)
            if trimmed.hasPrefix(">") {
                var quoteLines: [String] = []
                while lineIndex < lines.count {
                    let current = lines[lineIndex].trimmingCharacters(in: .whitespaces)
                    if current.hasPrefix(">") {
                        let content = String(current.dropFirst(1)).trimmingCharacters(in: .whitespaces)
                        quoteLines.append(content)
                        lineIndex += 1
                    } else {
                        break
                    }
                }
                let id = "blk-\(blockOrdinal)-quote"
                blockOrdinal += 1
                blocks.append(.blockquote(id: id, text: quoteLines.joined(separator: "\n")))
                continue
            }

            // 7. Unordered list (- item, * item, + item)
            if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") || trimmed.hasPrefix("+ ") {
                var listItems: [String] = []
                while lineIndex < lines.count {
                    let current = lines[lineIndex].trimmingCharacters(in: .whitespaces)
                    if current.hasPrefix("- ") || current.hasPrefix("* ") || current.hasPrefix("+ ") {
                        listItems.append(String(current.dropFirst(2)))
                        lineIndex += 1
                    } else {
                        break
                    }
                }
                let id = "blk-\(blockOrdinal)-ul"
                blockOrdinal += 1
                blocks.append(.unorderedList(id: id, items: listItems))
                continue
            }

            // 8. Ordered list (1. item, 2. item...)
            let pattern = "^(\\d+)\\.\\s+(.*)"
            if let regex = try? NSRegularExpression(pattern: pattern),
               let _ = regex.firstMatch(in: trimmed, range: NSRange(location: 0, length: trimmed.utf16.count)) {
                var listItems: [(number: Int, text: String)] = []
                while lineIndex < lines.count {
                    let current = lines[lineIndex].trimmingCharacters(in: .whitespaces)
                    if let match = regex.firstMatch(in: current, range: NSRange(location: 0, length: current.utf16.count)),
                       let numRange = Range(match.range(at: 1), in: current),
                       let textRange = Range(match.range(at: 2), in: current),
                       let num = Int(current[numRange]) {
                        listItems.append((number: num, text: String(current[textRange])))
                        lineIndex += 1
                    } else {
                        break
                    }
                }
                let id = "blk-\(blockOrdinal)-ol"
                blockOrdinal += 1
                blocks.append(.orderedList(id: id, items: listItems))
                continue
            }

            // 9. Tables (| H1 | H2 | ...)
            if trimmed.hasPrefix("|") && trimmed.hasSuffix("|") && lines.count > lineIndex + 1 && lines[lineIndex + 1].contains("---") {
                let headers = trimmed.split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                lineIndex += 2 // skip header and delimiter row
                var rows: [[String]] = []
                while lineIndex < lines.count {
                    let current = lines[lineIndex].trimmingCharacters(in: .whitespaces)
                    if current.hasPrefix("|") && current.hasSuffix("|") {
                        let rowCols = current.split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                        rows.append(rowCols)
                        lineIndex += 1
                    } else {
                        break
                    }
                }
                let id = "blk-\(blockOrdinal)-table"
                blockOrdinal += 1
                blocks.append(.table(id: id, headers: headers, rows: rows))
                continue
            }

            // 10. Paragraph
            var paragraphLines: [String] = []
            while lineIndex < lines.count {
                let current = lines[lineIndex]
                let curTrimmed = current.trimmingCharacters(in: .whitespaces)
                if curTrimmed.isEmpty ||
                   curTrimmed.hasPrefix("```") ||
                   curTrimmed.hasPrefix("$$") ||
                   curTrimmed.hasPrefix("#") ||
                   curTrimmed.hasPrefix(">") ||
                   curTrimmed.hasPrefix("- ") ||
                   curTrimmed.hasPrefix("* ") ||
                   curTrimmed.hasPrefix("+ ") ||
                   curTrimmed == "---" {
                    break
                }
                paragraphLines.append(current)
                lineIndex += 1
            }

            let id = "blk-\(blockOrdinal)-p"
            blockOrdinal += 1
            blocks.append(.paragraph(id: id, text: paragraphLines.joined(separator: "\n")))
        }

        return blocks
    }
}
