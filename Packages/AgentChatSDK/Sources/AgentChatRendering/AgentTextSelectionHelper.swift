import Foundation
#if canImport(STTextKitPlus)
import STTextKitPlus
#endif

public struct AgentTextSelectionHelper: Sendable {
    public init() {}

    public func characterRange(for query: String, in fullText: String) -> NSRange? {
        guard !query.isEmpty, !fullText.isEmpty else { return nil }
        let nsString = fullText as NSString
        let range = nsString.range(of: query)
        return range.location != NSNotFound ? range : nil
    }

    public func extractSnippets(from text: String, query: String, padding: Int = 40) -> [String] {
        guard let range = characterRange(for: query, in: text) else { return [] }
        let nsString = text as NSString
        let start = max(0, range.location - padding)
        let end = min(nsString.length, range.location + range.length + padding)
        let snippetRange = NSRange(location: start, length: end - start)
        return [nsString.substring(with: snippetRange)]
    }
}
