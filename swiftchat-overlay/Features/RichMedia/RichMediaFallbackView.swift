//
//  RichMediaFallbackView.swift
//  SwiftChat
//
//  Compatibility wrapper forwarding to AgentUI.RichMediaFallbackView.
//

@_exported import AgentUI
import SwiftUI

struct RichMediaFallbackView: View {
    let title: String
    let subtitle: String
    let iconName: String
    let isDarkMode: Bool

    var body: some View {
        AgentUI.RichMediaFallbackView(
            title: title,
            subtitle: subtitle,
            iconName: iconName,
            isDarkMode: isDarkMode
        )
    }
}
