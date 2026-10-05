// Sources/AgentUI/Core/AgentContentBlock.swift
import Foundation

public enum AgentContentBlock: Identifiable, Sendable, Equatable {
    case markdown(id: String, content: String)
    case image(id: String, url: URL?, altText: String?, caption: String?)
    case video(id: String, url: URL?, title: String?, caption: String?)
    case youtube(id: String, videoID: String, title: String?, subtitle: String?)
    case linkPreview(id: String, url: URL, title: String?, description: String?, iconURL: URL?)
    case attachment(id: String, attachment: AgentAttachment)
    case toolExecution(id: String, execution: AgentToolExecution)
    case embeddedResult(id: String, descriptor: AgentEmbeddedPresentationDescriptor)
    case nativeUI(id: String, block: AgentNativeUIBlock)
    case customSurface(id: String, handlerID: String, payload: AgentEmbeddedPayload)

    public var id: String {
        switch self {
        case .markdown(let id, _): return id
        case .image(let id, _, _, _): return id
        case .video(let id, _, _, _): return id
        case .youtube(let id, _, _, _): return id
        case .linkPreview(let id, _, _, _, _): return id
        case .attachment(let id, _): return id
        case .toolExecution(let id, _): return id
        case .embeddedResult(let id, _): return id
        case .nativeUI(let id, _): return id
        case .customSurface(let id, _, _): return id
        }
    }
}
