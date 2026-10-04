import Foundation

struct SectionSourcesPresentation {
    let leadingMarkdown: String?
    let paragraphMarkdown: String

    static func parse(_ markdown: String) -> SectionSourcesPresentation? {
        let normalized = markdown.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return nil }

        let blocks = normalized.components(separatedBy: "\n\n")
        guard let paragraph = blocks.last,
              isSimpleParagraph(paragraph) else { return nil }

        let leading = blocks.dropLast().joined(separator: "\n\n")
        return SectionSourcesPresentation(
            leadingMarkdown: leading.isEmpty ? nil : leading,
            paragraphMarkdown: paragraph
        )
    }

    private static func isSimpleParagraph(_ text: String) -> Bool {
        let forbiddenPrefixes = ["#", ">", "- ", "* ", "+ ", "```", "|"]
        guard !text.contains("\n"),
              !text.contains("\\("),
              !text.contains("\\[") else { return false }
        return !forbiddenPrefixes.contains { text.hasPrefix($0) }
    }
}
