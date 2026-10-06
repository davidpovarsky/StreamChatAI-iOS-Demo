//
//  AgentUIModels.swift
//  AgentUI
//
//  UI-facing presentation models and primitives.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

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

// MARK: - Streaming Content Chunks

public enum ContentChunkType: Codable, Equatable, Hashable, Sendable {
    case paragraph
    case codeBlock(language: String?)
    case heading
    case list
    case blockquote
    case table
    case other
}

public struct ContentChunk: Codable, Equatable, Identifiable, Hashable, Sendable {
    public let id: String
    public let type: ContentChunkType
    public let content: String
    public let isComplete: Bool

    public init(id: String = UUID().uuidString, type: ContentChunkType, content: String, isComplete: Bool) {
        self.id = id
        self.type = type
        self.content = content
        self.isComplete = isComplete
    }
}

public struct ThinkingChunk: Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    public let content: String
    public let isComplete: Bool

    public init(id: String, content: String, isComplete: Bool) {
        self.id = id
        self.content = content
        self.isComplete = isComplete
    }
}

// MARK: - Citations and Annotations

public struct URLCitation: Codable, Equatable, Hashable, Sendable {
    public let title: String
    public let url: String
    public let start_index: Int?
    public let end_index: Int?

    public init(title: String, url: String, start_index: Int? = nil, end_index: Int? = nil) {
        self.title = title
        self.url = url
        self.start_index = start_index
        self.end_index = end_index
    }
}

public struct Annotation: Codable, Equatable, Hashable, Sendable {
    public let type: String
    public let url_citation: URLCitation

    public init(type: String, url_citation: URLCitation) {
        self.type = type
        self.url_citation = url_citation
    }
}

// MARK: - Canonical Message Presentation Model

public struct AgentMessage: Identifiable, Equatable, Sendable {
    public let id: String
    public let role: MessageRole
    public var content: String
    public var thoughts: String?
    public var isThinking: Bool
    public var timestamp: Date
    public var isCollapsed: Bool
    public var isStreaming: Bool
    public var streamError: String?
    public var isRequestError: Bool
    public var generationTimeSeconds: Double?
    public var contentChunks: [ContentChunk]
    public var thinkingChunks: [ThinkingChunk]
    public var webSearchState: WebSearchState?
    public var urlFetches: [URLFetchState]
    public var attachments: [Attachment]
    public var contentParts: [MessageContentPart]
    public var annotations: [Annotation]?

    public static let longMessageAttachmentThreshold = 1200
    public var shouldDisplayAsAttachment: Bool {
        role == .user && content.count >= Self.longMessageAttachmentThreshold
    }

    public init(
        id: String = UUID().uuidString.lowercased(),
        role: MessageRole,
        content: String,
        thoughts: String? = nil,
        isThinking: Bool = false,
        timestamp: Date = Date(),
        isCollapsed: Bool = true,
        isStreaming: Bool = false,
        streamError: String? = nil,
        isRequestError: Bool = false,
        generationTimeSeconds: Double? = nil,
        contentChunks: [ContentChunk] = [],
        thinkingChunks: [ThinkingChunk] = [],
        webSearchState: WebSearchState? = nil,
        urlFetches: [URLFetchState] = [],
        attachments: [Attachment] = [],
        contentParts: [MessageContentPart] = [],
        annotations: [Annotation]? = nil
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.thoughts = thoughts
        self.isThinking = isThinking
        self.timestamp = timestamp
        self.isCollapsed = isCollapsed
        self.isStreaming = isStreaming
        self.streamError = streamError
        self.isRequestError = isRequestError
        self.generationTimeSeconds = generationTimeSeconds
        self.contentChunks = contentChunks
        self.thinkingChunks = thinkingChunks
        self.webSearchState = webSearchState
        self.urlFetches = urlFetches
        self.attachments = attachments
        self.contentParts = contentParts
        self.annotations = annotations
    }
}

// MARK: - Message Driving Interface

@MainActor
public protocol AgentMessageDriving: AnyObject {
    var drivingWebSearchSummary: String? { get }
    var drivingThinkingSummary: String? { get }
    var isMessageLoading: Bool { get }
    var editRequestedForMessageIndex: Int? { get set }

    func editMessage(at messageIndex: Int, newContent: String)
    func regenerateLastResponse()
    func regenerateMessage(at messageIndex: Int)
}

extension AgentMessageDriving {
    public var drivingWebSearchSummary: String? { nil }
    public var drivingThinkingSummary: String? { nil }
    public var isMessageLoading: Bool { false }
    public var editRequestedForMessageIndex: Int? {
        get { nil }
        set { }
    }
    public func editMessage(at messageIndex: Int, newContent: String) {}
    public func regenerateLastResponse() {}
    public func regenerateMessage(at messageIndex: Int) {}
}

// MARK: - Haptic Feedback Primitives

public enum HapticFeedback {
    public enum FeedbackType {
        case error
        case success
    }

    public static func trigger(_ type: FeedbackType) {
        let hapticEnabled = UserDefaults.standard.object(forKey: "hapticFeedbackEnabled") as? Bool ?? true
        guard hapticEnabled else { return }

        let generator = UINotificationFeedbackGenerator()
        switch type {
        case .error:
            generator.notificationOccurred(.error)
        case .success:
            generator.notificationOccurred(.success)
        }
    }
}



