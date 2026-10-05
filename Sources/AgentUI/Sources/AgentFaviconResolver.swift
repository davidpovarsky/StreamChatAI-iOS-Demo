// Sources/AgentUI/Sources/AgentFaviconResolver.swift
import Foundation

public protocol AgentFaviconResolver: Sendable {
    func resolveFavicon(for domain: String) -> URL?
}

#if canImport(SwiftUI)
import SwiftUI

extension EnvironmentValues {
    @Entry public var agentFaviconResolver: (any AgentFaviconResolver)? = nil
}
#endif
