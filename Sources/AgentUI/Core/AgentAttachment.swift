// Sources/AgentUI/Core/AgentAttachment.swift
import Foundation

public struct AgentAttachment: Identifiable, Sendable, Equatable, Hashable {
    public let id: String
    public let filename: String
    public let mimeType: String
    public let sizeInBytes: Int64
    public let localURL: URL?
    public let previewData: Data?

    public init(
        id: String = UUID().uuidString,
        filename: String,
        mimeType: String,
        sizeInBytes: Int64 = 0,
        localURL: URL? = nil,
        previewData: Data? = nil
    ) {
        self.id = id
        self.filename = filename
        self.mimeType = mimeType
        self.sizeInBytes = sizeInBytes
        self.localURL = localURL
        self.previewData = previewData
    }

    public var isImage: Bool {
        mimeType.hasPrefix("image/")
    }

    public var isVideo: Bool {
        mimeType.hasPrefix("video/")
    }

    public var isAudio: Bool {
        mimeType.hasPrefix("audio/")
    }
}
