//
//  AgentMessageListView.swift
//  AgentUI
//
//  Extracted existing message list view preserving exact geometry, scroll-to-bottom controls, and iPad layout.
//

import SwiftUI
import UIKit

public struct AgentMessageListView<MessageContent: View, ComposerContent: View>: View {
    public let isDarkMode: Bool
    public let messageCount: Int
    @ViewBuilder public let messageContent: () -> MessageContent
    @ViewBuilder public let composerContent: () -> ComposerContent

    @State private var isAtBottom = true
    @State private var userHasScrolled = false
    @State private var isKeyboardVisible = false

    public init(
        isDarkMode: Bool,
        messageCount: Int,
        @ViewBuilder messageContent: @escaping () -> MessageContent,
        @ViewBuilder composerContent: @escaping () -> ComposerContent
    ) {
        self.isDarkMode = isDarkMode
        self.messageCount = messageCount
        self.messageContent = messageContent
        self.composerContent = composerContent
    }

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    messageContent()
                }
            }
            .background(Color.agentChatBackground(isDarkMode: isDarkMode))
            .overlay(alignment: .bottom) {
                if !isAtBottom && messageCount > 0 && !isKeyboardVisible {
                    Group {
                        if #available(iOS 26, *) {
                            Button(action: {
                                userHasScrolled = false
                                isAtBottom = true
                            }) {
                                Image(systemName: "arrow.down")
                                    .font(.system(size: 12, weight: .semibold))
                                    .frame(
                                        width: AgentConstants.UI.scrollToBottomButtonSize,
                                        height: AgentConstants.UI.scrollToBottomButtonSize
                                    )
                            }
                            .buttonStyle(.glass)
                            .clipShape(Circle())
                        } else {
                            Button(action: {
                                userHasScrolled = false
                                isAtBottom = true
                            }) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.8))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.bottom, 16)
                    .transition(.opacity)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Group {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        HStack {
                            Spacer()
                            composerContent()
                                .frame(maxWidth: 600)
                            Spacer()
                        }
                    } else {
                        composerContent()
                    }
                }
            }
        }
    }
}
