//
//  InlineSectionSourcesView.swift
//  SwiftChat
//
//  Compatibility wrapper forwarding to AgentUI.AgentInlineSectionSourcesView.
//

import AgentUI
import SwiftUI

struct InlineSectionSourcesView: View {
    let markdown: String
    let sources: [WebSearchSource]
    let isDarkMode: Bool

    init(markdown: String, sources: [WebSearchSource], isDarkMode: Bool) {
        self.markdown = markdown
        self.sources = sources
        self.isDarkMode = isDarkMode
    }

    var body: some View {
        AgentInlineSectionSourcesView(
            markdown: markdown,
            sources: sources,
            isDarkMode: isDarkMode
        ) { text in
            LaTeXMarkdownView(content: text, isDarkMode: isDarkMode, isStreaming: false)
                .equatable()
        }
    }
}
