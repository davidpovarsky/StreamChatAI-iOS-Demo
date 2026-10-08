import Foundation
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Message Role

public enum MessageRole: String, Codable, Sendable, CaseIterable {
    case user
    case assistant
    case system
}

// MARK: - Web Search Source

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
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString.lowercased()
        title = try container.decode(String.self, forKey: .title)
        url = try container.decode(String.self, forKey: .url)
    }
}

// MARK: - Web Search Status & State

public enum WebSearchStatus: String, Codable, Equatable, Hashable, Sendable {
    case searching
    case reading
    case synthesizing
    case complete
    case completed
    case failed
    case blocked
}

public struct WebSearchState: Codable, Equatable, Hashable, Sendable {
    public var query: String?
    public var status: WebSearchStatus
    public var sources: [WebSearchSource]
    public var reason: String?
    public var error: String?

    public init(
        query: String? = nil,
        status: WebSearchStatus = .searching,
        sources: [WebSearchSource] = [],
        reason: String? = nil,
        error: String? = nil
    ) {
        self.query = query
        self.status = status
        self.sources = sources
        self.reason = reason
        self.error = error ?? reason
    }

    public init(status: WebSearchStatus, query: String, sources: [WebSearchSource] = [], error: String? = nil) {
        self.status = status
        self.query = query
        self.sources = sources
        self.error = error
        self.reason = error
    }
}

// MARK: - Rich Content Models

public struct MessageContentPart: Identifiable, Codable, Equatable, Hashable, Sendable {
    public enum Kind: String, Codable, Hashable, Sendable {
        case markdown
        case image
        case video
        case youtube
        case linkPreview
        case svg
        case lottie
        case customTool
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
    public var svgString: String?
    public var lottieAnimationName: String?
    public var toolName: String?
    public var rawPayload: String?

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
        youtubeVideoID: String? = nil,
        svgString: String? = nil,
        lottieAnimationName: String? = nil,
        toolName: String? = nil,
        rawPayload: String? = nil
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
        self.svgString = svgString
        self.lottieAnimationName = lottieAnimationName
        self.toolName = toolName
        self.rawPayload = rawPayload
    }
}

// MARK: - Attachment Models

public enum AttachmentType: String, Codable, Equatable, Hashable, Sendable {
    case image
    case document
    case audio
    case video
}

public enum AttachmentProcessingState: String, Codable, Equatable, Hashable, Sendable {
    case pending
    case processing
    case completed
    case failed
}

public struct Attachment: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: String
    public var type: AttachmentType
    public var url: String?
    public var filename: String
    public var size: Int?
    public var mimeType: String?
    public var base64: String?
    public var thumbnailBase64: String?
    public var textContent: String?
    public var description: String?
    public var encryptionKey: String?
    public var processingState: AttachmentProcessingState

    public var fileName: String {
        get { filename }
        set { filename = newValue }
    }

    public var fileSize: Int64 {
        get { Int64(size ?? 0) }
        set { size = Int(newValue) }
    }

    public init(
        id: String = UUID().uuidString.lowercased(),
        type: AttachmentType = .image,
        url: String? = nil,
        filename: String = "",
        size: Int? = nil,
        fileName: String? = nil,
        mimeType: String? = nil,
        base64: String? = nil,
        thumbnailBase64: String? = nil,
        textContent: String? = nil,
        description: String? = nil,
        fileSize: Int64? = nil,
        encryptionKey: String? = nil,
        processingState: AttachmentProcessingState = .pending
    ) {
        self.id = id
        self.type = type
        self.url = url
        self.filename = fileName ?? filename
        self.size = fileSize != nil ? Int(fileSize!) : size
        self.mimeType = mimeType
        self.base64 = base64
        self.thumbnailBase64 = thumbnailBase64
        self.textContent = textContent
        self.description = description
        self.encryptionKey = encryptionKey
        self.processingState = processingState
    }
}

// MARK: - Chunks

public enum ContentChunkType: Codable, Equatable, Hashable, Sendable {
    case paragraph
    case codeBlock(language: String?)
    case latexBlock
    case heading
    case list
    case blockquote
    case table
    case other

    public static var codeBlock: ContentChunkType {
        .codeBlock(language: nil)
    }
}

public struct ContentChunk: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: String
    public var type: ContentChunkType
    public var content: String
    public var isComplete: Bool
    public var timestamp: Date

    public var text: String { content }

    public init(id: String = UUID().uuidString.lowercased(), type: ContentChunkType = .other, content: String, isComplete: Bool = true, timestamp: Date = Date()) {
        self.id = id
        self.type = type
        self.content = content
        self.isComplete = isComplete
        self.timestamp = timestamp
    }

    public init(id: String = UUID().uuidString.lowercased(), text: String, timestamp: Date = Date()) {
        self.id = id
        self.type = .other
        self.content = text
        self.isComplete = true
        self.timestamp = timestamp
    }
}

public struct ThinkingChunk: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: String
    public var content: String
    public var isComplete: Bool
    public var timestamp: Date

    public var text: String { content }

    public init(id: String = UUID().uuidString.lowercased(), content: String, isComplete: Bool = true, timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.isComplete = isComplete
        self.timestamp = timestamp
    }

    public init(id: String = UUID().uuidString.lowercased(), text: String, timestamp: Date = Date()) {
        self.id = id
        self.content = text
        self.isComplete = true
        self.timestamp = timestamp
    }
}

// MARK: - URL Fetch Types

public enum URLFetchStatus: String, Codable, Equatable, Hashable, Sendable {
    case fetching
    case completed
    case failed
    case blocked
}

public struct URLFetchState: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: String
    public let url: String
    public var status: URLFetchStatus
    public var title: String?

    public init(id: String = UUID().uuidString.lowercased(), url: String, status: URLFetchStatus = .fetching, title: String? = nil) {
        self.id = id
        self.url = url
        self.status = status
        self.title = title
    }
}

public typealias URLFetch = URLFetchState

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

// MARK: - Message Model

public struct Message: Identifiable, Codable, Equatable, Hashable, Sendable {
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
    public var attachments: [Attachment]
    public var contentParts: [MessageContentPart]
    public var urlFetches: [URLFetch]

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
        attachments: [Attachment] = [],
        contentParts: [MessageContentPart] = [],
        urlFetches: [URLFetch] = []
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
        self.attachments = attachments
        self.contentParts = contentParts
        self.urlFetches = urlFetches
    }
}

// MARK: - Model Type

public struct ModelType: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let shortName: String
    public let iconName: String
    public let isThinkingModel: Bool

    public var displayName: String { name }
    public var fullName: String { name }
    public var isMultimodal: Bool { true }
    public var modelName: String { id }

    public init(
        id: String,
        name: String,
        shortName: String? = nil,
        iconName: String = "sparkles",
        isThinkingModel: Bool = false
    ) {
        self.id = id
        self.name = name
        self.shortName = shortName ?? name
        self.iconName = iconName
        self.isThinkingModel = isThinkingModel
    }

    public init(
        id: String,
        displayName: String,
        fullName: String? = nil,
        iconName: String = "sparkles",
        isMultimodal: Bool = true,
        isThinkingModel: Bool = false
    ) {
        self.id = id
        self.name = displayName
        self.shortName = displayName
        self.iconName = iconName
        self.isThinkingModel = isThinkingModel
    }

    public static let gpt4o = ModelType(id: "gpt-4o", name: "GPT-4o", shortName: "4o", iconName: "sparkles")
    public static let gpt4oMini = ModelType(id: "gpt-4o-mini", name: "GPT-4o mini", shortName: "Mini", iconName: "bolt")
    public static let o1 = ModelType(id: "o1", name: "o1", shortName: "o1", iconName: "brain", isThinkingModel: true)
    public static let o3Mini = ModelType(id: "o3-mini", name: "o3-mini", shortName: "o3", iconName: "brain", isThinkingModel: true)
}

// MARK: - Chat Model

public struct Chat: Identifiable, Codable, Equatable, Hashable, Sendable {
    public enum TitleState: String, Codable, Hashable, Sendable {
        case placeholder
        case generated
        case manual
    }

    public static let placeholderTitle = "Untitled"

    public let id: String
    public var title: String
    public var titleState: TitleState
    public var messages: [Message]
    public var hasActiveStream: Bool
    public var createdAt: Date
    public var modelType: ModelType
    public var language: String?

    public var isBlankChat: Bool {
        messages.isEmpty
    }

    public var needsGeneratedTitle: Bool {
        titleState == .placeholder
    }

    public init(
        id: String = UUID().uuidString.lowercased(),
        title: String = placeholderTitle,
        titleState: TitleState = .placeholder,
        messages: [Message] = [],
        hasActiveStream: Bool = false,
        createdAt: Date = Date(),
        modelType: ModelType = .gpt4o,
        language: String? = nil
    ) {
        self.id = id
        self.title = title
        self.titleState = titleState
        self.messages = messages
        self.hasActiveStream = hasActiveStream
        self.createdAt = createdAt
        self.modelType = modelType
        self.language = language
    }

    public static func create(
        title: String = placeholderTitle,
        titleState: TitleState = .placeholder,
        messages: [Message] = [],
        modelType: ModelType = .gpt4o,
        language: String? = nil
    ) -> Chat {
        Chat(
            id: UUID().uuidString.lowercased(),
            title: title,
            titleState: titleState,
            messages: messages,
            hasActiveStream: false,
            createdAt: Date(),
            modelType: modelType,
            language: language
        )
    }

    public static func triggerSuccessFeedback() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
}
