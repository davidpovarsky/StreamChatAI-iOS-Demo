#if canImport(AgentChatCore)
import AgentChatCore
#endif
import Foundation
#if canImport(Markdown)
import Markdown
#endif

public struct AgentMarkdownParser: AgentMarkdownParsing, Sendable {
    public init() {}
}

public typealias SwiftMarkdownParser = AgentMarkdownParser

extension AgentMarkdownParser {

    public func parse(markdown: String) -> [AgentMessageBlock] {
        let trimmed = markdown.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        var blocks: [AgentMessageBlock] = []

        let lines = markdown.components(separatedBy: "\n")
        var currentTextLines: [String] = []
        var inCodeFence = false
        var codeLanguage: String?
        var currentCodeLines: [String] = []
        var inMathBlock = false
        var currentMathLines: [String] = []

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            if !inCodeFence && !inMathBlock {
                if trimmedLine.hasPrefix("```") {
                    if !currentTextLines.isEmpty {
                        let text = currentTextLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                        if !text.isEmpty {
                            blocks.append(.markdown(id: UUID().uuidString, text: text))
                        }
                        currentTextLines.removeAll()
                    }
                    inCodeFence = true
                    let lang = String(trimmedLine.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                    codeLanguage = lang.isEmpty ? nil : lang
                    currentCodeLines.removeAll()
                    continue
                } else if trimmedLine.hasPrefix("$$") && trimmedLine.hasSuffix("$$") && trimmedLine.count > 2 {
                    if !currentTextLines.isEmpty {
                        let text = currentTextLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                        if !text.isEmpty {
                            blocks.append(.markdown(id: UUID().uuidString, text: text))
                        }
                        currentTextLines.removeAll()
                    }
                    let formula = String(trimmedLine.dropFirst(2).dropLast(2)).trimmingCharacters(in: .whitespaces)
                    blocks.append(.math(id: UUID().uuidString, formula: formula, displayMode: true))
                    continue
                } else if trimmedLine == "$$" {
                    if !currentTextLines.isEmpty {
                        let text = currentTextLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                        if !text.isEmpty {
                            blocks.append(.markdown(id: UUID().uuidString, text: text))
                        }
                        currentTextLines.removeAll()
                    }
                    inMathBlock = true
                    currentMathLines.removeAll()
                    continue
                }
            } else if inCodeFence {
                if trimmedLine.hasPrefix("```") {
                    inCodeFence = false
                    let code = currentCodeLines.joined(separator: "\n")
                    blocks.append(.code(id: UUID().uuidString, code: code, language: codeLanguage))
                    currentCodeLines.removeAll()
                    codeLanguage = nil
                    continue
                } else {
                    currentCodeLines.append(line)
                    continue
                }
            } else if inMathBlock {
                if trimmedLine == "$$" {
                    inMathBlock = false
                    let formula = currentMathLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                    blocks.append(.math(id: UUID().uuidString, formula: formula, displayMode: true))
                    currentMathLines.removeAll()
                    continue
                } else {
                    currentMathLines.append(line)
                    continue
                }
            }

            currentTextLines.append(line)
        }

        if inCodeFence && !currentCodeLines.isEmpty {
            blocks.append(.code(id: UUID().uuidString, code: currentCodeLines.joined(separator: "\n"), language: codeLanguage))
        } else if inMathBlock && !currentMathLines.isEmpty {
            blocks.append(.math(id: UUID().uuidString, formula: currentMathLines.joined(separator: "\n"), displayMode: true))
        } else if !currentTextLines.isEmpty {
            let text = currentTextLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                blocks.append(.markdown(id: UUID().uuidString, text: text))
            }
        }

        return blocks.isEmpty ? [.markdown(id: UUID().uuidString, text: markdown)] : blocks
    }
}
