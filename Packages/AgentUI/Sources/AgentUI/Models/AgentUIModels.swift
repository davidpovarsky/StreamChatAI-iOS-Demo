//
//  AgentUIModels.swift
//  AgentUI
//
//  UI-facing presentation models and primitives.
//

import Foundation

public struct WebSearchSource: Codable, Equatable, Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let url: String

    public init(id: String = UUID().uuidString.lowercased(), title: String, url: String) {
        self.id = id
        self.title = title
        self.url = url
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString.lowercased()
        self.title = try container.decode(String.self, forKey: .title)
        self.url = try container.decode(String.self, forKey: .url)
    }
}
