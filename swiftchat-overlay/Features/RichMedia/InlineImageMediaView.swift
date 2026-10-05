//
//  InlineImageMediaView.swift
//  SwiftChat
//
//  Compatibility wrapper forwarding to AgentUI.SafeInlineImageMediaView.
//

@_exported import AgentUI
import SwiftUI

struct SafeInlineImageMediaView: View {
    let part: MessageContentPart
    let isDarkMode: Bool

    var body: some View {
        AgentUI.SafeInlineImageMediaView(part: part.toAgentUIPart(), isDarkMode: isDarkMode)
    }
}

extension MessageContentPart {
    func toAgentUIPart() -> AgentUI.MessageContentPart {
        AgentUI.MessageContentPart(
            id: id,
            kind: AgentUI.MessageContentPart.Kind(rawValue: kind.rawValue) ?? .markdown,
            markdown: markdown,
            sources: sources.map { AgentUI.WebSearchSource(id: $0.id, title: $0.title, url: $0.url) },
            url: url,
            title: title,
            subtitle: subtitle,
            caption: caption,
            thumbnailURL: thumbnailURL,
            youtubeVideoID: youtubeVideoID
        )
    }
}
