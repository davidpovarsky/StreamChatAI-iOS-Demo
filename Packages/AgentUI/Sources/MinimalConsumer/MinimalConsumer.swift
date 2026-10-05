//
//  MinimalConsumer.swift
//  MinimalConsumer
//
//  Second minimal consumer proving another target imports and instantiates AgentUI without Hanlin or app-specific dependencies.
//

import SwiftUI
import AgentUI

public struct MinimalConsumerView: View {
    @StateObject private var controller = MockAgentRuntimeController()
    @State private var messageText: String = ""

    public init() {}

    public var body: some View {
        AgentChatView(
            sidebar: {
                AgentChatSidebarView(
                    sessions: controller.sessions,
                    currentSessionId: controller.currentSession?.id,
                    onSelectSession: { controller.selectSession($0) },
                    onDeleteSession: { controller.deleteSession(id: $0) },
                    onRenameSession: { controller.renameSession(id: $0, newTitle: $1) },
                    onCreateNewSession: { controller.createNewSession() }
                )
            },
            detail: {
                AgentMessageListView(
                    isDarkMode: false,
                    messageCount: 0,
                    messageContent: {
                        Text("Minimal Consumer Chat")
                            .font(.headline)
                            .padding()
                    },
                    composerContent: {
                        AgentComposerView(
                            messageText: $messageText,
                            driver: controller
                        )
                    }
                )
            }
        )
    }
}
