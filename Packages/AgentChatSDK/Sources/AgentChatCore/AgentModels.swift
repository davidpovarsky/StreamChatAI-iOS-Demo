import Foundation

public enum AgentMessageRole: String, Codable, Sendable, CaseIterable {
    case user
    case assistant
    case system
    case tool
}

public enum AgentGenerationState: Codable, Sendable, Equatable {
    case idle
    case thinking
    case streaming
    case executingTool(name: String)
    case completed
    case failed(String)
    case cancelled

    public var isGenerating: Bool {
        switch self {
        case .thinking, .streaming, .executingTool:
            return true
        case .idle, .completed, .failed, .cancelled:
            return false
        }
    }
}

public struct AgentToolCall: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public var name: String
    public var arguments: String
    public var service: String?
    public var timestamp: Date

    public init(
        id: String = UUID().uuidString,
        name: String,
        arguments: String = "{}",
        service: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.arguments = arguments
        self.service = service
        self.timestamp = timestamp
    }
}

public struct AgentToolResult: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let callID: String
    public var toolName: String
    public var isSuccess: Bool
    public var outputSummary: String
    public var rawOutput: String?
    public var dataPayload: [String: String]?
    public var timestamp: Date

    public init(
        id: String = UUID().uuidString,
        callID: String,
        toolName: String,
        isSuccess: Bool = true,
        outputSummary: String,
        rawOutput: String? = nil,
        dataPayload: [String: String]? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.callID = callID
        self.toolName = toolName
        self.isSuccess = isSuccess
        self.outputSummary = outputSummary
        self.rawOutput = rawOutput
        self.dataPayload = dataPayload
        self.timestamp = timestamp
    }
}

public struct AgentSource: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public var title: String
    public var url: String
    public var domain: String
    public var snippet: String?
    public var faviconURL: String?

    public init(
        id: String = UUID().uuidString,
        title: String,
        url: String,
        snippet: String? = nil,
        faviconURL: String? = nil
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.domain = URL(string: url)?.host ?? url
        self.snippet = snippet
        self.faviconURL = faviconURL ?? "https://www.google.com/s2/favicons?domain=\(URL(string: url)?.host ?? url)&sz=64"
    }
}

public struct AgentAttachment: Identifiable, Codable, Sendable, Equatable {
    public enum Kind: String, Codable, Sendable {
        case image
        case file
        case audio
        case document
    }

    public let id: String
    public var name: String
    public var mimeType: String
    public var kind: Kind
    public var url: String?
    public var sizeBytes: Int64

    public init(
        id: String = UUID().uuidString,
        name: String,
        mimeType: String = "application/octet-stream",
        kind: Kind = .file,
        url: String? = nil,
        sizeBytes: Int64 = 0
    ) {
        self.id = id
        self.name = name
        self.mimeType = mimeType
        self.kind = kind
        self.url = url
        self.sizeBytes = sizeBytes
    }
}

public struct AgentImageContent: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public var url: String?
    public var localBundleName: String?
    public var caption: String?
    public var altText: String?
    public var aspectRatio: Double?

    public init(
        id: String = UUID().uuidString,
        url: String? = nil,
        localBundleName: String? = nil,
        caption: String? = nil,
        altText: String? = nil,
        aspectRatio: Double? = 16.0 / 9.0
    ) {
        self.id = id
        self.url = url
        self.localBundleName = localBundleName
        self.caption = caption
        self.altText = altText
        self.aspectRatio = aspectRatio
    }
}

public struct AgentVideoContent: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public var url: String
    public var thumbnailURL: String?
    public var title: String?
    public var isYouTube: Bool

    public init(
        id: String = UUID().uuidString,
        url: String,
        thumbnailURL: String? = nil,
        title: String? = nil,
        isYouTube: Bool = false
    ) {
        self.id = id
        self.url = url
        self.thumbnailURL = thumbnailURL
        self.title = title
        self.isYouTube = isYouTube || url.contains("youtube.com") || url.contains("youtu.be")
    }
}

public struct AgentSVGContent: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public var rawSVG: String?
    public var bundleName: String?
    public var title: String?
    public var width: Double?
    public var height: Double?

    public init(
        id: String = UUID().uuidString,
        rawSVG: String? = nil,
        bundleName: String? = nil,
        title: String? = nil,
        width: Double? = nil,
        height: Double? = nil
    ) {
        self.id = id
        self.rawSVG = rawSVG
        self.bundleName = bundleName
        self.title = title
        self.width = width
        self.height = height
    }
}

public struct AgentRichResultContent: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public var toolID: String
    public var title: String
    public var subtitle: String?
    public var metrics: [String: String]
    public var statusText: String?

    public init(
        id: String = UUID().uuidString,
        toolID: String,
        title: String,
        subtitle: String? = nil,
        metrics: [String: String] = [:],
        statusText: String? = nil
    ) {
        self.id = id
        self.toolID = toolID
        self.title = title
        self.subtitle = subtitle
        self.metrics = metrics
        self.statusText = statusText
    }
}

public enum AgentMessageBlock: Identifiable, Sendable, Equatable {
    case markdown(id: String, text: String)
    case code(id: String, code: String, language: String?)
    case math(id: String, formula: String, displayMode: Bool)
    case image(id: String, content: AgentImageContent)
    case imageGallery(id: String, images: [AgentImageContent])
    case svg(id: String, content: AgentSVGContent)
    case video(id: String, content: AgentVideoContent)
    case sources(id: String, items: [AgentSource])
    case tool(id: String, call: AgentToolCall, result: AgentToolResult?)
    case richResult(id: String, content: AgentRichResultContent)
    case custom(id: String, typeIdentifier: String, payload: String)

    public var id: String {
        switch self {
        case .markdown(let id, _): return id
        case .code(let id, _, _): return id
        case .math(let id, _, _): return id
        case .image(let id, _): return id
        case .imageGallery(let id, _): return id
        case .svg(let id, _): return id
        case .video(let id, _): return id
        case .sources(let id, _): return id
        case .tool(let id, _, _): return id
        case .richResult(let id, _): return id
        case .custom(let id, _, _): return id
        }
    }
}

public struct AgentMessage: Identifiable, Sendable, Equatable {
    public let id: String
    public var role: AgentMessageRole
    public var blocks: [AgentMessageBlock]
    public var rawText: String
    public var generationState: AgentGenerationState
    public var timestamp: Date
    public var attachments: [AgentAttachment]

    public var isGenerating: Bool {
        generationState.isGenerating
    }

    public init(
        id: String = UUID().uuidString,
        role: AgentMessageRole,
        blocks: [AgentMessageBlock] = [],
        rawText: String = "",
        generationState: AgentGenerationState = .idle,
        timestamp: Date = Date(),
        attachments: [AgentAttachment] = []
    ) {
        self.id = id
        self.role = role
        self.blocks = blocks
        self.rawText = rawText
        self.generationState = generationState
        self.timestamp = timestamp
        self.attachments = attachments

        if blocks.isEmpty && !rawText.isEmpty {
            self.blocks = [.markdown(id: UUID().uuidString, text: rawText)]
        }
    }
}
