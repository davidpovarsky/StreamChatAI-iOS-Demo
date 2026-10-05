//
//  AgentActivityTimelineView.swift
//  SwiftChat
//
//  Compatibility bridge forwarding to AgentUI.AgentActivityTimelineView.
//

import AgentUI
import SwiftUI

struct AgentActivityTimelineBridge: View {
    let messageID: String
    let isDarkMode: Bool
    @ObservedObject private var store = AgentActivityStore.shared

    var body: some View {
        if let session = store.session(for: messageID) {
            AgentActivityTimelineView(session: session, isDarkMode: isDarkMode) {
                store.setExpanded(!session.isExpanded, messageID: messageID)
            }
        }
    }
}

typealias AgentActivityTimelineView = AgentUI.AgentActivityTimelineView
