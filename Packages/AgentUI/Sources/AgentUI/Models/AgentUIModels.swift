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

public enum MessageRole: String, Codable, Sendable {
    case user
    case assistant
}

public enum WebSearchStatus: String, Codable, Equatable, Sendable {
    case searching
    case completed
    case failed
    case blocked
}

public struct WebSearchState: Codable, Equatable, Sendable {
    public var query: String?
    public var status: WebSearchStatus
    public var sources: [WebSearchSource]
    public var reason: String?

    public init(
        query: String? = nil,
        status: WebSearchStatus = .searching,
        sources: [WebSearchSource] = [],
        reason: String? = nil
    ) {
        self.query = query
        self.status = status
        self.sources = sources
        self.reason = reason
    }
}

public enum URLFetchStatus: String, Codable, Equatable, Sendable {
    case fetching
    case completed
    case failed
    case blocked
}

public struct URLFetchState: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let url: String
    public var status: URLFetchStatus

    public init(id: String = UUID().uuidString.lowercased(), url: String, status: URLFetchStatus = .fetching) {
        self.id = id
        self.url = url
        self.status = status
    }
}

public enum AttachmentType: String, Codable, Equatable, Sendable {
    case document
    case image
}

public enum AttachmentProcessingState: String, Codable, Equatable, Sendable {
    case pending
    case processing
    case completed
    case failed
}

public struct Attachment: Identifiable, Equatable, Sendable {
    public let id: String
    public let type: AttachmentType
    public let fileName: String
    public var mimeType: String?
    public var base64: String?
    public var thumbnailBase64: String?
    public var textContent: String?
    public var description: String?
    public var fileSize: Int64
    public var encryptionKey: String?
    public var processingState: AttachmentProcessingState

    public init(
        id: String = UUID().uuidString.lowercased(),
        type: AttachmentType,
        fileName: String,
        mimeType: String? = nil,
        base64: String? = nil,
        thumbnailBase64: String? = nil,
        textContent: String? = nil,
        description: String? = nil,
        fileSize: Int64 = 0,
        encryptionKey: String? = nil,
        processingState: AttachmentProcessingState = .pending
    ) {
        self.id = id
        self.type = type
        self.fileName = fileName
        self.mimeType = mimeType
        self.base64 = base64
        self.thumbnailBase64 = thumbnailBase64
        self.textContent = textContent
        self.description = description
        self.fileSize = fileSize
        self.encryptionKey = encryptionKey
        self.processingState = processingState
    }
}

extension Attachment: Codable {
    enum CodingKeys: String, CodingKey {
        case id, type, fileName, mimeType, base64, thumbnailBase64
        case textContent, description, fileSize
        case encryptionKey
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString.lowercased()
        type = try container.decode(AttachmentType.self, forKey: .type)
        fileName = try container.decode(String.self, forKey: .fileName)
        mimeType = try container.decodeIfPresent(String.self, forKey: .mimeType)
        base64 = try container.decodeIfPresent(String.self, forKey: .base64)
        thumbnailBase64 = try container.decodeIfPresent(String.self, forKey: .thumbnailBase64)
        textContent = try container.decodeIfPresent(String.self, forKey: .textContent)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        fileSize = try container.decodeIfPresent(Int64.self, forKey: .fileSize) ?? 0
        encryptionKey = try container.decodeIfPresent(String.self, forKey: .encryptionKey)
        processingState = .completed
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(fileName, forKey: .fileName)
        try container.encodeIfPresent(mimeType, forKey: .mimeType)
        try container.encodeIfPresent(base64, forKey: .base64)
        try container.encodeIfPresent(thumbnailBase64, forKey: .thumbnailBase64)
        try container.encodeIfPresent(textContent, forKey: .textContent)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(fileSize, forKey: .fileSize)
        try container.encodeIfPresent(encryptionKey, forKey: .encryptionKey)
    }
}


