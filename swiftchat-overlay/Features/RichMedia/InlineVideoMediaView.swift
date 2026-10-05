//
//  InlineVideoMediaView.swift
//  SwiftChat
//
//  Compatibility wrapper forwarding to AgentUI.SafeInlineVideoMediaView.
//

@_exported import AgentUI
import SwiftUI

struct SafeInlineVideoMediaView: View {
    let part: MessageContentPart
    let isDarkMode: Bool

    var body: some View {
        AgentUI.SafeInlineVideoMediaView(part: part.toAgentUIPart(), isDarkMode: isDarkMode)
    }
}
