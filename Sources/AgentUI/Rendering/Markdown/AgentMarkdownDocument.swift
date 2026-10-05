// Sources/AgentUI/Rendering/Markdown/AgentMarkdownDocument.swift
import Foundation

public enum AgentMarkdownBlock: Identifiable, Sendable, Equatable {
    case heading(id: String, level: Int, text: String)
    case paragraph(id: String, text: String)
    case blockquote(id: String, text: String)
    case unorderedList(id: String, items: [String])
    case orderedList(id: String, items: [(number: Int, text: String)])
    case codeBlock(id: String, language: String?, code: String)
    case mathBlock(id: String, formula: String)
    case horizontalRule(id: String)
    case table(id: String, headers: [String], rows: [[String]])

    public var id: String {
        switch self {
        case .heading(let id, _, _): return id
        case .paragraph(let id, _): return id
        case .blockquote(let id, _): return id
        case .unorderedList(let id, _): return id
        case .orderedList(let id, _): return id
        case .codeBlock(let id, _, _): return id
        case .mathBlock(let id, _): return id
        case .horizontalRule(let id): return id
        case .table(let id, _, _): return id
        }
    }

    public static func == (lhs: AgentMarkdownBlock, rhs: AgentMarkdownBlock) -> Bool {
        switch (lhs, rhs) {
        case (.heading(let lId, let lL, let lT), .heading(let rId, let rL, let rT)):
            return lId == rId && lL == rL && lT == rT
        case (.paragraph(let lId, let lT), .paragraph(let rId, let rT)):
            return lId == rId && lT == rT
        case (.blockquote(let lId, let lT), .blockquote(let rId, let rT)):
            return lId == rId && lT == rT
        case (.unorderedList(let lId, let lItems), .unorderedList(let rId, let rItems)):
            return lId == rId && lItems == rItems
        case (.orderedList(let lId, let lItems), .orderedList(let rId, let rItems)):
            return lId == rId && lItems.map { "\($0.number):\($0.text)" } == rItems.map { "\($0.number):\($0.text)" }
        case (.codeBlock(let lId, let lLang, let lC), .codeBlock(let rId, let rLang, let rC)):
            return lId == rId && lLang == rLang && lC == rC
        case (.mathBlock(let lId, let lF), .mathBlock(let rId, let rF)):
            return lId == rId && lF == rF
        case (.horizontalRule(let lId), .horizontalRule(let rId)):
            return lId == rId
        case (.table(let lId, let lH, let lR), .table(let rId, let rH, let rR)):
            return lId == rId && lH == rH && lR == rR
        default:
            return false
        }
    }
}
