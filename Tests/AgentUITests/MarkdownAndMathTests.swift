// Tests/AgentUITests/MarkdownAndMathTests.swift
import Testing
import Foundation
@testable import AgentUI

@Suite("Markdown Parsing, Stability and Math Typesetting Tests")
struct MarkdownAndMathTests {
    @Test("Markdown parser derives deterministic stable identities during streaming")
    func testDeterministicStreamingIdentities() {
        let initialText = """
        # Heading One

        This is the first paragraph.

        ```swift
        let x = 42
        ```
        """

        let initialBlocks = AgentMarkdownParser.parse(initialText)
        #expect(initialBlocks.count == 3)
        let initialIDs = initialBlocks.map { $0.id }

        // Append more content as streaming proceeds
        let streamedText = initialText + """


        This is an appended second paragraph being streamed token by token.
        """

        let streamedBlocks = AgentMarkdownParser.parse(streamedText)
        #expect(streamedBlocks.count == 4)

        // The prefix block IDs MUST remain identical
        #expect(streamedBlocks[0].id == initialIDs[0])
        #expect(streamedBlocks[1].id == initialIDs[1])
        #expect(streamedBlocks[2].id == initialIDs[2])

        // Further append tokens to the last paragraph
        let streamedTextWithTokens = streamedText + " More tokens arriving."
        let updatedBlocks = AgentMarkdownParser.parse(streamedTextWithTokens)
        #expect(updatedBlocks.count == 4)
        #expect(updatedBlocks[0].id == initialIDs[0])
        #expect(updatedBlocks[1].id == initialIDs[1])
        #expect(updatedBlocks[2].id == initialIDs[2])
        #expect(updatedBlocks[3].id == streamedBlocks[3].id)
    }

    @Test("Markdown parser extracts headings, lists, quotes, tables, and rules")
    func testMarkdownBlockFamilies() {
        let markdown = """
        # Title 1
        ## Subtitle 2

        > Blockquote message

        - Item A
        - Item B

        1. First
        2. Second

        ---

        | Header A | Header B |
        | --- | --- |
        | Val 1 | Val 2 |
        """

        let blocks = AgentMarkdownParser.parse(markdown)
        #expect(blocks.count == 7)

        if case .heading(_, let level, let text) = blocks[0] {
            #expect(level == 1)
            #expect(text == "Title 1")
        } else {
            Issue.record("Expected heading block")
        }

        if case .heading(_, let level, let text) = blocks[1] {
            #expect(level == 2)
            #expect(text == "Subtitle 2")
        } else {
            Issue.record("Expected heading block")
        }

        if case .blockquote(_, let text) = blocks[2] {
            #expect(text == "Blockquote message")
        } else {
            Issue.record("Expected blockquote")
        }

        if case .unorderedList(_, let items) = blocks[3] {
            #expect(items == ["Item A", "Item B"])
        } else {
            Issue.record("Expected unordered list")
        }

        if case .orderedList(_, let items) = blocks[4] {
            #expect(items.count == 2)
            #expect(items[0].number == 1)
            #expect(items[0].text == "First")
        } else {
            Issue.record("Expected ordered list")
        }

        if case .horizontalRule = blocks[5] {
            // Success
        } else {
            Issue.record("Expected horizontal rule")
        }

        if case .table(_, let headers, let rows) = blocks[6] {
            #expect(headers == ["Header A", "Header B"])
            #expect(rows.count == 1)
            #expect(rows[0] == ["Val 1", "Val 2"])
        } else {
            Issue.record("Expected table")
        }
    }

    @Test("Math parser accurately decomposes quadratic formula AST")
    func testMathASTQuadraticFormula() {
        let formula = "x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}"
        let ast = AgentMathParser.parse(formula)

        guard case .sequence(let elements) = ast else {
            Issue.record("Expected sequence AST for formula")
            return
        }

        // Should start with x =
        #expect(elements.count >= 2)
        #expect(elements[0] == .variable("x"))
        #expect(elements[1] == .op("="))

        // Next element should be the fraction
        let fraction = elements[2]
        guard case .fraction(let numerator, let denominator) = fraction else {
            Issue.record("Expected fraction node in AST")
            return
        }

        // Denominator should contain 2a
        if case .sequence(let denItems) = denominator {
            #expect(denItems.contains(.number("2")))
            #expect(denItems.contains(.variable("a")))
        } else {
            Issue.record("Expected sequence in denominator")
        }

        // Numerator should contain square root
        var foundSquareRoot = false
        if case .sequence(let numItems) = numerator {
            for item in numItems {
                if case .squareRoot(let radicand) = item {
                    foundSquareRoot = true
                    #expect(radicand != .empty)
                }
            }
        }
        #expect(foundSquareRoot == true)
    }

    @Test("Math parser handles Greek symbols, exponents, and common operators")
    func testMathSymbolsAndOperators() {
        let formula = "\\alpha + \\beta^2 \\leq \\pi \\cdot \\infty"
        let ast = AgentMathParser.parse(formula)

        guard case .sequence(let items) = ast else {
            Issue.record("Expected sequence AST")
            return
        }

        #expect(items.contains(.variable("α")))
        #expect(items.contains(.op("+")))
        #expect(items.contains(.superscript(base: .variable("β"), exponent: .number("2"))))
        #expect(items.contains(.op("≤")))
        #expect(items.contains(.variable("π")))
        #expect(items.contains(.op("·")))
        #expect(items.contains(.symbol("∞")))
    }
}
