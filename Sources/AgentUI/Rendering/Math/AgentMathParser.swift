// Sources/AgentUI/Rendering/Math/AgentMathParser.swift
import Foundation

public indirect enum MathAST: Sendable, Equatable {
    case variable(String)
    case number(String)
    case op(String)
    case symbol(String)
    case fraction(numerator: MathAST, denominator: MathAST)
    case squareRoot(radicand: MathAST)
    case superscript(base: MathAST, exponent: MathAST)
    case subscripted(base: MathAST, sub: MathAST)
    case sequence([MathAST])
    case empty
}

public enum AgentMathParser {
    public static func parse(_ formula: String) -> MathAST {
        let cleaned = formula.trimmingCharacters(in: CharacterSet(charactersIn: "$ \t\r\n"))
        var scanner = MathScanner(cleaned)
        let elements = scanner.parseSequence()
        if elements.isEmpty {
            return .empty
        } else if elements.count == 1 {
            return elements[0]
        } else {
            return .sequence(elements)
        }
    }
}

private struct MathScanner {
    private let chars: [Character]
    private var index: Int = 0

    init(_ string: String) {
        self.chars = Array(string)
    }

    private var isAtEnd: Bool { index >= chars.count }
    private var current: Character? { isAtEnd ? nil : chars[index] }

    mutating func parseSequence() -> [MathAST] {
        var result: [MathAST] = []
        while !isAtEnd {
            skipWhitespace()
            if isAtEnd { break }
            if current == "}" { break }
            if let node = parsePrimary() {
                result.append(node)
            }
        }
        return result
    }

    private mutating func skipWhitespace() {
        while !isAtEnd && chars[index].isWhitespace {
            index += 1
        }
    }

    private mutating func parsePrimary() -> MathAST? {
        skipWhitespace()
        guard !isAtEnd else { return nil }

        let ch = chars[index]

        var base: MathAST?

        if ch == "\\" {
            base = parseCommand()
        } else if ch == "{" {
            index += 1
            let seq = parseSequence()
            if !isAtEnd && chars[index] == "}" {
                index += 1
            }
            base = seq.count == 1 ? seq[0] : .sequence(seq)
        } else if ch.isNumber {
            var numStr = ""
            while !isAtEnd && (chars[index].isNumber || chars[index] == ".") {
                numStr.append(chars[index])
                index += 1
            }
            base = .number(numStr)
        } else if "=+-*/±×÷·≤≥≠≈∑∫∞∂()[]".contains(ch) {
            index += 1
            base = .op(String(ch))
        } else if ch.isLetter {
            index += 1
            base = .variable(String(ch))
        } else {
            index += 1
            base = .symbol(String(ch))
        }

        guard var currentBase = base else { return nil }

        // Check for superscript (^) or subscript (_)
        while !isAtEnd {
            skipWhitespace()
            guard !isAtEnd else { break }
            if chars[index] == "^" {
                index += 1
                if let exp = parsePrimary() {
                    currentBase = .superscript(base: currentBase, exponent: exp)
                }
            } else if chars[index] == "_" {
                index += 1
                if let sub = parsePrimary() {
                    currentBase = .subscripted(base: currentBase, sub: sub)
                }
            } else {
                break
            }
        }

        return currentBase
    }

    private mutating func parseCommand() -> MathAST {
        index += 1 // skip \
        var cmd = ""
        while !isAtEnd && chars[index].isLetter {
            cmd.append(chars[index])
            index += 1
        }

        switch cmd {
        case "frac":
            let num = parseBlockOrPrimary()
            let den = parseBlockOrPrimary()
            return .fraction(numerator: num, denominator: den)

        case "sqrt":
            let rad = parseBlockOrPrimary()
            return .squareRoot(radicand: rad)

        case "pm": return .op("±")
        case "times": return .op("×")
        case "div": return .op("÷")
        case "cdot": return .op("·")
        case "leq": return .op("≤")
        case "geq": return .op("≥")
        case "neq": return .op("≠")
        case "approx": return .op("≈")
        case "sum": return .op("∑")
        case "int": return .op("∫")
        case "infty": return .symbol("∞")
        case "partial": return .op("∂")

        case "alpha": return .variable("α")
        case "beta": return .variable("β")
        case "gamma": return .variable("γ")
        case "delta": return .variable("δ")
        case "Delta": return .symbol("Δ")
        case "theta": return .variable("θ")
        case "lambda": return .variable("λ")
        case "pi": return .variable("π")
        case "sigma": return .variable("σ")
        case "Sigma": return .symbol("Σ")
        case "omega": return .variable("ω")
        case "Omega": return .symbol("Ω")
        case "phi": return .variable("φ")
        case "psi": return .variable("ψ")

        case "left", "right":
            // skip delimiter command, let primary parse delimiter
            return parsePrimary() ?? .empty

        default:
            return .variable(cmd)
        }
    }

    private mutating func parseBlockOrPrimary() -> MathAST {
        skipWhitespace()
        guard !isAtEnd else { return .empty }
        if chars[index] == "{" {
            index += 1
            let seq = parseSequence()
            if !isAtEnd && chars[index] == "}" {
                index += 1
            }
            return seq.count == 1 ? seq[0] : .sequence(seq)
        } else {
            return parsePrimary() ?? .empty
        }
    }
}
