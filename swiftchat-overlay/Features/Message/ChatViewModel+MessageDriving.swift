//
//  ChatViewModel+MessageDriving.swift
//  SwiftChat
//
//  Bridges ChatViewModel and Message models losslessly to AgentUI.
//

import SwiftUI
@_exported import AgentUI

extension Message {
    public func toAgentMessage() -> AgentMessage {
        AgentMessage(
            id: id,
            role: role == .user ? .user : .assistant,
            content: content,
            thoughts: thoughts,
            isThinking: isThinking,
            timestamp: timestamp,
            isCollapsed: isCollapsed,
            isStreaming: isStreaming,
            streamError: streamError,
            isRequestError: isRequestError,
            generationTimeSeconds: generationTimeSeconds,
            contentChunks: contentChunks.map { chunk in
                AgentUI.ContentChunk(
                    id: chunk.id,
                    type: {
                        switch chunk.type {
                        case .paragraph: return .paragraph
                        case .codeBlock(let lang): return .codeBlock(language: lang)
                        case .heading: return .heading
                        case .list: return .list
                        case .blockquote: return .blockquote
                        case .table: return .table
                        case .other: return .other
                        }
                    }(),
                    content: chunk.content,
                    isComplete: chunk.isComplete
                )
            },
            thinkingChunks: thinkingChunks.map { chunk in
                AgentUI.ThinkingChunk(
                    id: chunk.id,
                    content: chunk.content,
                    isComplete: chunk.isComplete
                )
            },
            webSearchState: webSearchState.map { state in
                AgentUI.WebSearchState(
                    query: state.query,
                    status: {
                        switch state.status {
                        case .searching: return .searching
                        case .completed: return .completed
                        case .failed: return .failed
                        case .blocked: return .blocked
                        }
                    }(),
                    sources: state.sources.map { src in
                        AgentUI.WebSearchSource(id: src.id, title: src.title, url: src.url)
                    },
                    reason: state.reason
                )
            },
            urlFetches: urlFetches.map { f in
                AgentUI.URLFetchState(
                    id: f.id,
                    url: f.url,
                    status: {
                        switch f.status {
                        case .fetching: return .fetching
                        case .completed: return .completed
                        case .failed: return .failed
                        case .blocked: return .blocked
                        }
                    }()
                )
            },
            attachments: attachments.map { att in
                AgentUI.Attachment(
                    id: att.id,
                    type: att.type == .image ? .image : .document,
                    fileName: att.fileName,
                    mimeType: att.mimeType,
                    base64: att.base64,
                    thumbnailBase64: att.thumbnailBase64,
                    textContent: att.textContent,
                    description: att.description,
                    fileSize: att.fileSize,
                    encryptionKey: att.encryptionKey,
                    processingState: {
                        switch att.processingState {
                        case .pending: return .pending
                        case .processing: return .processing
                        case .completed: return .completed
                        case .failed: return .failed
                        }
                    }()
                )
            },
            contentParts: contentParts.map { part in
                AgentUI.MessageContentPart(
                    id: part.id,
                    kind: {
                        switch part.kind {
                        case .markdown: return .markdown
                        case .image: return .image
                        case .video: return .video
                        case .youtube: return .youtube
                        case .linkPreview: return .linkPreview
                        }
                    }(),
                    markdown: part.markdown,
                    sources: part.sources.map { src in
                        AgentUI.WebSearchSource(id: src.id, title: src.title, url: src.url)
                    },
                    url: part.url,
                    title: part.title,
                    subtitle: part.subtitle,
                    caption: part.caption,
                    thumbnailURL: part.thumbnailURL,
                    youtubeVideoID: part.youtubeVideoID
                )
            },
            annotations: annotations?.map { ann in
                AgentUI.Annotation(
                    type: ann.type,
                    url_citation: AgentUI.URLCitation(
                        title: ann.url_citation.title,
                        url: ann.url_citation.url,
                        start_index: ann.url_citation.start_index,
                        end_index: ann.url_citation.end_index
                    )
                )
            }
        )
    }
}

extension ChatViewModel: AgentMessageDriving {
    public var isMessageLoading: Bool {
        isLoading
    }

    public var drivingWebSearchSummary: String? {
        webSearchSummary.isEmpty ? nil : webSearchSummary
    }

    public var drivingThinkingSummary: String? {
        thinkingSummary.isEmpty ? nil : thinkingSummary
    }
}
