//
//  AgentMessageListView.swift
//  AgentUI
//
//  Authoritative chat list view orchestrating 120fps AgentMessageTableView,
//  floating liquid-glass scroll-to-bottom button, keyboard observers, and iPad layout.
//

import SwiftUI
import UIKit

public struct AgentMessageListView<ComposerContent: View, AccessoryContent: View>: View {
    public let messages: [AgentMessage]
    public let currentChatId: String?
    public let currentChatCreatedAt: Date?
    public let isCurrentChatBlank: Bool
    public let archivedMessagesStartIndex: Int
    public let isDarkMode: Bool
    public let isLoading: Bool
    public let driver: (any AgentMessageDriving)?
    public let scrollToBottomTrigger: UUID?
    public let scrollToUserMessageTrigger: UUID?
    public let onScrollInteractionChanged: ((Bool) -> Void)?
    public let onIsAtBottomChanged: ((Bool) -> Void)?
    @ViewBuilder public let composer: (Bool) -> ComposerContent
    @ViewBuilder public let accessory: (AgentMessage) -> AccessoryContent

    @State private var isAtBottom = true
    @State private var userHasScrolled = false
    @State private var isKeyboardVisible = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var scrollTrigger = UUID()
    @State private var scrollToUserTrigger = UUID()
    @State private var tableOpacity = 1.0

    public init(
        messages: [AgentMessage],
        currentChatId: String? = nil,
        currentChatCreatedAt: Date? = nil,
        isCurrentChatBlank: Bool = false,
        archivedMessagesStartIndex: Int = 0,
        isDarkMode: Bool,
        isLoading: Bool,
        driver: (any AgentMessageDriving)? = nil,
        scrollToBottomTrigger: UUID? = nil,
        scrollToUserMessageTrigger: UUID? = nil,
        onScrollInteractionChanged: ((Bool) -> Void)? = nil,
        onIsAtBottomChanged: ((Bool) -> Void)? = nil,
        @ViewBuilder composer: @escaping (Bool) -> ComposerContent,
        @ViewBuilder accessory: @escaping (AgentMessage) -> AccessoryContent
    ) {
        self.messages = messages
        self.currentChatId = currentChatId
        self.currentChatCreatedAt = currentChatCreatedAt
        self.isCurrentChatBlank = isCurrentChatBlank
        self.archivedMessagesStartIndex = archivedMessagesStartIndex
        self.isDarkMode = isDarkMode
        self.isLoading = isLoading
        self.driver = driver
        self.scrollToBottomTrigger = scrollToBottomTrigger
        self.scrollToUserMessageTrigger = scrollToUserMessageTrigger
        self.onScrollInteractionChanged = onScrollInteractionChanged
        self.onIsAtBottomChanged = onIsAtBottomChanged
        self.composer = composer
        self.accessory = accessory
    }

    public var body: some View {
        AgentMessageTableView(
            messages: messages,
            currentChatId: currentChatId,
            archivedMessagesStartIndex: archivedMessagesStartIndex,
            isDarkMode: isDarkMode,
            isLoading: isLoading,
            isAtBottom: $isAtBottom,
            userHasScrolled: $userHasScrolled,
            scrollTrigger: scrollTrigger,
            scrollToUserTrigger: scrollToUserTrigger,
            tableOpacity: $tableOpacity,
            keyboardHeight: keyboardHeight,
            driver: driver,
            onScrollInteractionChanged: { active in
                onScrollInteractionChanged?(active)
            },
            onIsAtBottomChanged: { atBottom in
                onIsAtBottomChanged?(atBottom)
            },
            messageAccessory: { message in
                AnyView(accessory(message))
            }
        )
        .opacity(tableOpacity)
        .background(Color.agentChatBackground(isDarkMode: isDarkMode))
        .overlay(alignment: .bottom) {
            if !isAtBottom && !messages.isEmpty && !isKeyboardVisible {
                Group {
                    if #available(iOS 26, *) {
                        Button(action: {
                            userHasScrolled = false
                            onScrollInteractionChanged?(false)
                            scrollTrigger = UUID()
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
                            onScrollInteractionChanged?(false)
                            scrollTrigger = UUID()
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
                        composer(isKeyboardVisible)
                            .frame(maxWidth: 600)
                        Spacer()
                    }
                } else {
                    composer(isKeyboardVisible)
                }
            }
        }
        .onAppear {
            setupKeyboardObservers()
        }
        .onDisappear {
            removeKeyboardObservers()
            onScrollInteractionChanged?(false)
        }
        .onChange(of: messages.count) { oldCount, newCount in
            if newCount > oldCount {
                let newMessages = messages.suffix(newCount - oldCount)
                let hasUserMessage = newMessages.contains { $0.role == .user }
                let wasInitialLoad = oldCount == 0

                if hasUserMessage || wasInitialLoad {
                    userHasScrolled = false
                    onScrollInteractionChanged?(false)
                    if hasUserMessage && isLoading {
                        scrollToUserTrigger = UUID()
                    } else {
                        scrollTrigger = UUID()
                    }
                }
            }
        }
        .onChange(of: currentChatCreatedAt) { _, _ in
            userHasScrolled = false
            onScrollInteractionChanged?(false)

            if !isCurrentChatBlank {
                tableOpacity = 0
                scrollTrigger = UUID()
                isAtBottom = true
            } else {
                tableOpacity = 1.0
                isAtBottom = true
            }
        }
        .onChange(of: scrollToBottomTrigger) { _, _ in
            userHasScrolled = false
            onScrollInteractionChanged?(false)
            scrollTrigger = UUID()
        }
        .onChange(of: scrollToUserMessageTrigger) { _, _ in
            userHasScrolled = false
            onScrollInteractionChanged?(false)
            scrollToUserTrigger = UUID()
        }
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                isKeyboardVisible = true
                self.keyboardHeight = keyboardFrame.height
            }
        }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            isKeyboardVisible = false
            keyboardHeight = 0
        }
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension AgentMessageListView where AccessoryContent == EmptyView {
    public init(
        messages: [AgentMessage],
        currentChatId: String? = nil,
        currentChatCreatedAt: Date? = nil,
        isCurrentChatBlank: Bool = false,
        archivedMessagesStartIndex: Int = 0,
        isDarkMode: Bool,
        isLoading: Bool,
        driver: (any AgentMessageDriving)? = nil,
        scrollToBottomTrigger: UUID? = nil,
        scrollToUserMessageTrigger: UUID? = nil,
        onScrollInteractionChanged: ((Bool) -> Void)? = nil,
        onIsAtBottomChanged: ((Bool) -> Void)? = nil,
        @ViewBuilder composer: @escaping (Bool) -> ComposerContent
    ) {
        self.init(
            messages: messages,
            currentChatId: currentChatId,
            currentChatCreatedAt: currentChatCreatedAt,
            isCurrentChatBlank: isCurrentChatBlank,
            archivedMessagesStartIndex: archivedMessagesStartIndex,
            isDarkMode: isDarkMode,
            isLoading: isLoading,
            driver: driver,
            scrollToBottomTrigger: scrollToBottomTrigger,
            scrollToUserMessageTrigger: scrollToUserMessageTrigger,
            onScrollInteractionChanged: onScrollInteractionChanged,
            onIsAtBottomChanged: onIsAtBottomChanged,
            composer: composer,
            accessory: { _ in EmptyView() }
        )
    }
}
