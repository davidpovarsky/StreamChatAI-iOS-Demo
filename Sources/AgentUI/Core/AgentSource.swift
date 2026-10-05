// Sources/AgentUI/Core/AgentSource.swift
import Foundation

public struct AgentSource: Identifiable, Sendable, Equatable, Hashable {
    public let id: String
    public let title: String
    public let url: String
    public let domain: String
    public let snippet: String?
    public let sectionID: String?

    public init(
        id: String = UUID().uuidString,
        title: String,
        url: String,
        domain: String? = nil,
        snippet: String? = nil,
        sectionID: String? = nil
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.snippet = snippet
        self.sectionID = sectionID
        if let domain, !domain.isEmpty {
            self.domain = domain
        } else if let host = URL(string: url)?.host {
            self.domain = host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
        } else {
            self.domain = "source"
        }
    }

    public var faviconURL: URL? {
        URL(string: "https://icons.duckduckgo.com/ip3/\(domain).ico")
    }
}

public struct AgentSourceClusterData: Sendable, Equatable {
    public let sources: [AgentSource]

    public init(sources: [AgentSource]) {
        self.sources = sources
    }

    public var uniqueDomains: [String] {
        var seen = Set<String>()
        return sources.compactMap { source in
            let dom = source.domain
            return seen.insert(dom).inserted ? dom : nil
        }
    }
}
