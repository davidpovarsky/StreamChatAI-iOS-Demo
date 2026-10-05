//
//  InlineYouTubeMediaView.swift
//  SwiftChat
//
//  Compatibility wrapper forwarding to AgentUI.SafeInlineYouTubeMediaView.
//

@_exported import AgentUI
import SwiftUI

struct SafeInlineYouTubeMediaView: View {
    let part: MessageContentPart
    let isDarkMode: Bool

    var body: some View {
        AgentUI.SafeInlineYouTubeMediaView(part: part.toAgentUIPart(), isDarkMode: isDarkMode)
    }
}
