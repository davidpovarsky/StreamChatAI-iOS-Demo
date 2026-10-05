// Sources/AgentUIShowcaseSupport/MockSurfaces/ShowcaseDeterministicFaviconResolver.swift
import Foundation
import AgentUI

public struct ShowcaseDeterministicFaviconResolver: AgentFaviconResolver, Sendable {
    public init() {}

    public func resolveFavicon(for domain: String) -> URL? {
        // Deterministic local URL for testing/showcase
        URL(string: "mock://favicon/\(domain)")
    }
}
