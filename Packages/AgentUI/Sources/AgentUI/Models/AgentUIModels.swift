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

public struct MessageContentPart: Identifiable, Codable, Equatable, Hashable, Sendable {
    public enum Kind: String, Codable, Hashable, Sendable {
        case markdown
        case image
        case video
        case youtube
        case linkPreview
    }

    public let id: String
    public let kind: Kind

    public var markdown: String?
    public var sources: [WebSearchSource]

    public var url: String?
    public var title: String?
    public var subtitle: String?
    public var caption: String?
    public var thumbnailURL: String?
    public var youtubeVideoID: String?

    public init(
        id: String = UUID().uuidString.lowercased(),
        kind: Kind,
        markdown: String? = nil,
        sources: [WebSearchSource] = [],
        url: String? = nil,
        title: String? = nil,
        subtitle: String? = nil,
        caption: String? = nil,
        thumbnailURL: String? = nil,
        youtubeVideoID: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.markdown = markdown
        self.sources = sources
        self.url = url
        self.title = title
        self.subtitle = subtitle
        self.caption = caption
        self.thumbnailURL = thumbnailURL
        self.youtubeVideoID = youtubeVideoID
    }
}

