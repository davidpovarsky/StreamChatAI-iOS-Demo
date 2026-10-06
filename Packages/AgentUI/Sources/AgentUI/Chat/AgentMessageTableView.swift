//
//  AgentMessageTableView.swift
//  AgentUI
//
//  Created on 03/25/26.
//  Canonical UITableView-backed message list delivering 120fps streaming performance,
//  dynamic cell height estimation, and bottom anchoring.
//

import SwiftUI
import UIKit
import Combine

public enum StreamingBufferConstants {
    public static let initialMultiplier: CGFloat = 50.0
    public static let multiplierIncrement: CGFloat = 10.0
    public static let maxMultiplier: CGFloat = 200.0
    public static let extensionThresholdRatio: CGFloat = 0.9
    public static let maxCellHeight: CGFloat = 200_000
}

public struct AgentWelcomeView: View {
    public let isDarkMode: Bool

    public init(isDarkMode: Bool) {
        self.isDarkMode = isDarkMode
    }

    public var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("Start a conversation")
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
        }
        .padding(.top, 24)
        .padding(.bottom, 4)
    }
}

public struct AgentMessageTableView: UIViewRepresentable {
    public let messages: [AgentMessage]
    public let currentChatId: String?
    public let archivedMessagesStartIndex: Int
    public let isDarkMode: Bool
    public let isLoading: Bool
    public let driver: (any AgentMessageDriving)?
    @Binding public var isAtBottom: Bool
    @Binding public var userHasScrolled: Bool
    public let scrollTrigger: UUID
    public let scrollToUserTrigger: UUID
    @Binding public var tableOpacity: Double
    public let keyboardHeight: CGFloat
    public let onScrollInteractionChanged: ((Bool) -> Void)?
    public let onIsAtBottomChanged: ((Bool) -> Void)?
    public let welcomeContent: (() -> AnyView)?
    public let messageAccessory: ((AgentMessage) -> AnyView)?

    public init(
        messages: [AgentMessage],
        currentChatId: String? = nil,
        archivedMessagesStartIndex: Int = 0,
        isDarkMode: Bool,
        isLoading: Bool,
        isAtBottom: Binding<Bool>,
        userHasScrolled: Binding<Bool>,
        scrollTrigger: UUID,
        scrollToUserTrigger: UUID,
        tableOpacity: Binding<Double>,
        keyboardHeight: CGFloat = 0,
        driver: (any AgentMessageDriving)? = nil,
        onScrollInteractionChanged: ((Bool) -> Void)? = nil,
        onIsAtBottomChanged: ((Bool) -> Void)? = nil,
        welcomeContent: (() -> AnyView)? = nil,
        messageAccessory: ((AgentMessage) -> AnyView)? = nil
    ) {
        self.messages = messages
        self.currentChatId = currentChatId
        self.archivedMessagesStartIndex = archivedMessagesStartIndex
        self.isDarkMode = isDarkMode
        self.isLoading = isLoading
        self._isAtBottom = isAtBottom
        self._userHasScrolled = userHasScrolled
        self.scrollTrigger = scrollTrigger
        self.scrollToUserTrigger = scrollToUserTrigger
        self._tableOpacity = tableOpacity
        self.keyboardHeight = keyboardHeight
        self.driver = driver
        self.onScrollInteractionChanged = onScrollInteractionChanged
        self.onIsAtBottomChanged = onIsAtBottomChanged
        self.welcomeContent = welcomeContent
        self.messageAccessory = messageAccessory
    }

    public func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator
        tableView.keyboardDismissMode = .onDrag
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = true
        tableView.contentInsetAdjustmentBehavior = .automatic
        tableView.clipsToBounds = false

        if #available(iOS 15.0, *) {
            tableView.isPrefetchingEnabled = true
        }

        context.coordinator.tableView = tableView

        return tableView
    }

    public func updateUIView(_ tableView: UITableView, context: Context) {
        context.coordinator.parent = self

        let keyboardHeightChanged = context.coordinator.lastKeyboardHeight != keyboardHeight
        if keyboardHeightChanged {
            let wasAtBottom = context.coordinator.parent.isAtBottom
            context.coordinator.lastKeyboardHeight = keyboardHeight
            context.coordinator.isKeyboardTransitioning = true

            if wasAtBottom && keyboardHeight > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    context.coordinator.scrollToBottom(animated: true)
                    context.coordinator.isKeyboardTransitioning = false
                }
            } else {
                DispatchQueue.main.async {
                    context.coordinator.isKeyboardTransitioning = false
                }
            }
        }

        let currentChatId = self.currentChatId
        let previousChatId = context.coordinator.lastChatId
        let chatIdChanged = previousChatId != currentChatId

        let currentMessageIds = Set(messages.map { $0.id })
        let isIdConversion = chatIdChanged && !currentMessageIds.isEmpty &&
            currentMessageIds == context.coordinator.lastMessageIds

        if chatIdChanged {
            context.coordinator.lastChatId = currentChatId

            if !isIdConversion {
                context.coordinator.messageWrappers.removeAll()
                context.coordinator.shownMessageIds.removeAll()
            }
            context.coordinator.lastMessageIds = currentMessageIds
        } else if currentMessageIds != context.coordinator.lastMessageIds {
            let idsWereReplaced = !currentMessageIds.isEmpty &&
                                  !context.coordinator.lastMessageIds.isEmpty &&
                                  currentMessageIds.isDisjoint(with: context.coordinator.lastMessageIds)

            if idsWereReplaced {
                context.coordinator.messageWrappers.removeAll()
                context.coordinator.shownMessageIds.removeAll()
                context.coordinator.heightCache.removeAll()
            }
            context.coordinator.lastMessageIds = currentMessageIds
            tableView.reloadData()
        }

        let isDarkModeChanged = context.coordinator.lastIsDarkMode != isDarkMode
        let messageCountChanged = context.coordinator.lastMessageCount != messages.count

        if isDarkModeChanged {
            context.coordinator.lastIsDarkMode = isDarkMode
            DispatchQueue.main.async {
                for wrapper in context.coordinator.messageWrappers.values {
                    wrapper.isDarkMode = isDarkMode
                }
            }
        }

        if messageCountChanged || (chatIdChanged && !isIdConversion) {
            context.coordinator.lastMessageCount = messages.count
            context.coordinator.heightCache.removeAll()
            tableView.reloadData()
        } else if isLoading && !messages.isEmpty {
            if let lastMessage = messages.last,
               let wrapper = context.coordinator.messageWrappers[lastMessage.id] {

                let isArchived = messages.count - 1 < archivedMessagesStartIndex
                let showArchiveSeparator = messages.count - 1 == archivedMessagesStartIndex && archivedMessagesStartIndex > 0

                let screenHeight = UIScreen.main.bounds.height
                let needsBufferExtension = wrapper.extendBufferIfNeeded(screenHeight: screenHeight)

                let coordinator = context.coordinator
                DispatchQueue.main.async {
                    guard let currentMessage = coordinator.parent.messages.last else { return }

                    wrapper.update(
                        message: currentMessage,
                        isDarkMode: coordinator.parent.isDarkMode,
                        isLastMessage: true,
                        isLoading: coordinator.parent.isLoading,
                        isArchived: isArchived,
                        showArchiveSeparator: showArchiveSeparator,
                        messageIndex: coordinator.parent.messages.count - 1
                    )

                    if needsBufferExtension && !coordinator.isKeyboardTransitioning {
                        tableView.beginUpdates()
                        tableView.endUpdates()
                    }
                }
            }
        }

        let isLoadingChanged = context.coordinator.lastIsLoading != isLoading
        context.coordinator.lastIsLoading = isLoading

        if isLoadingChanged && !isLoading {
            if let lastMessage = messages.last,
               let wrapper = context.coordinator.messageWrappers[lastMessage.id] {
                let isArchived = messages.count - 1 < archivedMessagesStartIndex
                let showArchiveSeparator = messages.count - 1 == archivedMessagesStartIndex && archivedMessagesStartIndex > 0
                wrapper.update(
                    message: lastMessage,
                    isDarkMode: isDarkMode,
                    isLastMessage: true,
                    isLoading: false,
                    isArchived: isArchived,
                    showArchiveSeparator: showArchiveSeparator,
                    messageIndex: messages.count - 1
                )

                DispatchQueue.main.async {
                    wrapper.resetBuffer()
                }
            }

            DispatchQueue.main.async {
                UIView.performWithoutAnimation {
                    context.coordinator.isUserMessageScrollMode = false
                    let currentOffset = tableView.contentOffset.y
                    context.coordinator.updateContentInset()
                    tableView.layoutIfNeeded()
                    tableView.contentOffset.y = currentOffset
                }
            }
        }

        if context.coordinator.lastScrollToUserTrigger != scrollToUserTrigger {
            context.coordinator.lastScrollToUserTrigger = scrollToUserTrigger
            context.coordinator.shouldScrollToUserMessageAfterLayout = true
            context.coordinator.shouldScrollToBottomAfterLayout = false
            context.coordinator.isUserMessageScrollMode = true

            DispatchQueue.main.async {
                context.coordinator.scrollToUserMessage(animated: false)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if context.coordinator.shouldScrollToUserMessageAfterLayout {
                        context.coordinator.scrollToUserMessage(animated: false)
                        context.coordinator.shouldScrollToUserMessageAfterLayout = false

                        withAnimation(.easeIn(duration: 0.2)) {
                            self.tableOpacity = 1.0
                        }
                    }
                }
            }
        }

        if context.coordinator.lastScrollTrigger != scrollTrigger {
            context.coordinator.lastScrollTrigger = scrollTrigger
            context.coordinator.shouldScrollToBottomAfterLayout = true
            context.coordinator.shouldScrollToUserMessageAfterLayout = false
            context.coordinator.isUserMessageScrollMode = false

            DispatchQueue.main.async {
                context.coordinator.scrollToBottom(animated: false)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if context.coordinator.shouldScrollToBottomAfterLayout {
                        context.coordinator.scrollToBottom(animated: false)
                        context.coordinator.shouldScrollToBottomAfterLayout = false

                        withAnimation(.easeIn(duration: 0.2)) {
                            self.tableOpacity = 1.0
                        }
                    }
                }
            }
        }

        DispatchQueue.main.async {
            context.coordinator.checkIfAtBottom()
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, UITableViewDelegate, UITableViewDataSource {
        public var parent: AgentMessageTableView
        public weak var tableView: UITableView?
        public var lastScrollTrigger: UUID?
        public var lastScrollToUserTrigger: UUID?
        public var lastMessageCount: Int = 0
        public var lastIsLoading: Bool = false
        public var cellReuseIdentifierSuffix: String = ""
        public var lastKeyboardHeight: CGFloat = 0
        public var lastIsDarkMode: Bool = false
        public var lastChatId: String? = nil
        public var lastMessageIds: Set<String> = []
        private var isDragging = false
        private var isUpdatingContentInset = false
        public var messageWrappers: [String: AgentObservableMessageWrapper] = [:]
        public var shouldScrollToBottomAfterLayout = false
        public var shouldScrollToUserMessageAfterLayout = false
        public var isUserMessageScrollMode = false
        public var heightCache: [IndexPath: CGFloat] = [:]
        public var messageHeightCache: [String: CGFloat] = [:]
        public var shownMessageIds: Set<String> = []
        public var isKeyboardTransitioning = false

        public init(_ parent: AgentMessageTableView) {
            self.parent = parent
        }

        public func getOrCreateWrapper(
            for message: AgentMessage,
            isDarkMode: Bool,
            isLastMessage: Bool,
            isLoading: Bool,
            isArchived: Bool,
            showArchiveSeparator: Bool,
            messageIndex: Int
        ) -> AgentObservableMessageWrapper {
            if let existing = messageWrappers[message.id] {
                existing.update(
                    message: message,
                    isDarkMode: isDarkMode,
                    isLastMessage: isLastMessage,
                    isLoading: isLoading,
                    isArchived: isArchived,
                    showArchiveSeparator: showArchiveSeparator,
                    messageIndex: messageIndex
                )
                existing.shouldAnimateAppearance = false
                return existing
            } else {
                let isFirstTimeShown = !shownMessageIds.contains(message.id)
                shownMessageIds.insert(message.id)
                let wrapper = AgentObservableMessageWrapper(
                    message: message,
                    isDarkMode: isDarkMode,
                    isLastMessage: isLastMessage,
                    isLoading: isLoading,
                    isArchived: isArchived,
                    showArchiveSeparator: showArchiveSeparator,
                    shouldAnimateAppearance: isFirstTimeShown,
                    messageIndex: messageIndex
                )
                messageWrappers[message.id] = wrapper
                return wrapper
            }
        }

        public func numberOfSections(in tableView: UITableView) -> Int {
            1
        }

        public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if parent.messages.isEmpty {
                return 1
            }
            return parent.messages.count
        }

        public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cellIdentifier = (parent.messages.isEmpty ? "WelcomeCell" : "MessageCell") + cellReuseIdentifierSuffix

            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            cell.selectionStyle = .none
            cell.backgroundColor = .clear

            if parent.messages.isEmpty {
                cell.contentConfiguration = UIHostingConfiguration {
                    if let welcome = parent.welcomeContent {
                        welcome()
                    } else {
                        AgentWelcomeView(isDarkMode: parent.isDarkMode)
                            .padding(.vertical, 16)
                            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 100 : 0)
                            .frame(maxWidth: 900)
                            .frame(maxWidth: .infinity)
                    }
                }
                .minSize(width: 0, height: 0)
                .margins(.all, 0)
                .background(.clear)
            } else {
                let message = parent.messages[indexPath.row]
                let isLastMessage = indexPath.row == parent.messages.count - 1
                let isArchived = indexPath.row < parent.archivedMessagesStartIndex
                let showArchiveSeparator = indexPath.row == parent.archivedMessagesStartIndex && parent.archivedMessagesStartIndex > 0

                let wrapper = getOrCreateWrapper(
                    for: message,
                    isDarkMode: parent.isDarkMode,
                    isLastMessage: isLastMessage,
                    isLoading: parent.isLoading && isLastMessage,
                    isArchived: isArchived,
                    showArchiveSeparator: showArchiveSeparator,
                    messageIndex: indexPath.row
                )

                cell.contentConfiguration = UIHostingConfiguration {
                    AgentObservableMessageCell(
                        wrapper: wrapper,
                        driver: parent.driver,
                        coordinator: self,
                        accessory: parent.messageAccessory
                    )
                }
                .minSize(width: 0, height: 0)
                .margins(.all, 0)
                .background(.clear)
            }

            return cell
        }

        public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
            if let cachedHeight = heightCache[indexPath] {
                return cachedHeight
            }
            if indexPath.row < parent.messages.count {
                let messageId = parent.messages[indexPath.row].id
                if let cachedHeight = messageHeightCache[messageId] {
                    return cachedHeight
                }
            }
            return 100
        }

        public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            let height = cell.frame.size.height
            if height > 0 {
                heightCache[indexPath] = height
                if indexPath.row < parent.messages.count {
                    messageHeightCache[parent.messages[indexPath.row].id] = height
                }
            }

            if shouldScrollToBottomAfterLayout {
                let numberOfRows = tableView.numberOfRows(inSection: 0)
                if indexPath.row == numberOfRows - 1 {
                    DispatchQueue.main.async {
                        self.scrollToBottom(animated: false)
                        self.shouldScrollToBottomAfterLayout = false

                        withAnimation(.easeIn(duration: 0.2)) {
                            self.parent.tableOpacity = 1.0
                        }
                    }
                }
            }

            if shouldScrollToUserMessageAfterLayout {
                let numberOfRows = tableView.numberOfRows(inSection: 0)
                if indexPath.row == numberOfRows - 1 {
                    DispatchQueue.main.async {
                        self.scrollToUserMessage(animated: false)
                        self.shouldScrollToUserMessageAfterLayout = false

                        withAnimation(.easeIn(duration: 0.2)) {
                            self.parent.tableOpacity = 1.0
                        }
                    }
                }
            }
        }

        public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        }

        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            updateContentInset()
            checkIfAtBottom()
        }

        public func updateContentInset() {
            guard !isUpdatingContentInset else { return }
            guard let tableView = tableView else { return }
            isUpdatingContentInset = true
            defer { isUpdatingContentInset = false }

            let targetInset: CGFloat

            if parent.isLoading, let lastMessage = parent.messages.last,
               let wrapper = messageWrappers[lastMessage.id], wrapper.actualContentHeight > 0 {

                let screenHeight = UIScreen.main.bounds.height
                let bufferHeight = screenHeight * wrapper.bufferMultiplier
                let unusedBuffer = bufferHeight - wrapper.actualContentHeight
                let streamingInset = -max(0, unusedBuffer)

                if isUserMessageScrollMode {
                    let userMessageInset = insetForUserMessageAtTop(tableView)
                    targetInset = max(streamingInset, userMessageInset)
                } else {
                    targetInset = streamingInset
                }
            } else if parent.isLoading && isUserMessageScrollMode {
                targetInset = insetForUserMessageAtTop(tableView)
            } else {
                targetInset = 0
            }

            if tableView.contentInset.bottom != targetInset {
                UIView.performWithoutAnimation {
                    tableView.contentInset.bottom = targetInset
                    tableView.verticalScrollIndicatorInsets.bottom = targetInset
                }
            }
        }

        private func insetForUserMessageAtTop(_ tableView: UITableView) -> CGFloat {
            let numberOfRows = tableView.numberOfRows(inSection: 0)
            guard numberOfRows >= 2 else { return 0 }
            let userMessageIndexPath = IndexPath(row: numberOfRows - 2, section: 0)
            let userMessageY = tableView.rectForRow(at: userMessageIndexPath).origin.y
            return userMessageY + tableView.bounds.height - tableView.contentSize.height
        }

        public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            isDragging = true
            parent.userHasScrolled = true
            parent.onScrollInteractionChanged?(true)
            shouldScrollToBottomAfterLayout = false
            shouldScrollToUserMessageAfterLayout = false

            UIView.animate(withDuration: 0.3) {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }

        public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            isDragging = false
            if !decelerate {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.parent.onScrollInteractionChanged?(false)
                }
            }
        }

        public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.parent.onScrollInteractionChanged?(false)
            }
        }

        public func scrollToBottom(animated: Bool) {
            guard let tableView = tableView else { return }
            guard !parent.messages.isEmpty else { return }

            updateContentInset()

            let numberOfRows = tableView.numberOfRows(inSection: 0)
            guard numberOfRows > 0 else { return }
            guard numberOfRows == parent.messages.count || parent.messages.isEmpty else { return }

            let lastIndexPath = IndexPath(row: numberOfRows - 1, section: 0)
            tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: animated)
        }

        public func scrollToUserMessage(animated: Bool) {
            guard let tableView = tableView else { return }

            let numberOfRows = tableView.numberOfRows(inSection: 0)
            guard numberOfRows >= 2 else {
                scrollToBottom(animated: animated)
                return
            }
            guard numberOfRows == parent.messages.count else { return }

            updateContentInset()

            let userMessageIndexPath = IndexPath(row: numberOfRows - 2, section: 0)
            tableView.scrollToRow(at: userMessageIndexPath, at: .top, animated: animated)
        }

        public func checkIfAtBottom() {
            guard let tableView = tableView else { return }
            guard tableView.window != nil else { return }

            let contentHeight = tableView.contentSize.height
            let bottomInset = tableView.contentInset.bottom
            let viewHeight = tableView.bounds.height
            let currentOffset = tableView.contentOffset.y

            let maxOffset = contentHeight - viewHeight + bottomInset
            let distanceFromBottom = maxOffset - currentOffset

            let slack: CGFloat = 150
            let isVisible = distanceFromBottom <= slack

            if parent.isAtBottom != isVisible {
                DispatchQueue.main.async {
                    self.parent.isAtBottom = isVisible
                    self.parent.onIsAtBottomChanged?(isVisible)
                    if isVisible {
                        self.parent.userHasScrolled = false
                    }
                }
            }
        }
    }
}

public final class AgentObservableMessageWrapper: ObservableObject {
    @Published public var message: AgentMessage
    @Published public var isDarkMode: Bool
    @Published public var isLastMessage: Bool
    @Published public var isLoading: Bool
    @Published public var isArchived: Bool
    @Published public var showArchiveSeparator: Bool
    @Published public var shouldAnimateAppearance: Bool = false
    @Published public var messageIndex: Int
    public var bufferMultiplier: CGFloat = StreamingBufferConstants.initialMultiplier
    public var actualContentHeight: CGFloat = 0
    public var cachedHeight: CGFloat?
    public var cachedHeightKey: Int?

    public init(
        message: AgentMessage,
        isDarkMode: Bool,
        isLastMessage: Bool,
        isLoading: Bool,
        isArchived: Bool,
        showArchiveSeparator: Bool,
        shouldAnimateAppearance: Bool = true,
        messageIndex: Int = 0
    ) {
        self.message = message
        self.isDarkMode = isDarkMode
        self.isLastMessage = isLastMessage
        self.isLoading = isLoading
        self.isArchived = isArchived
        self.showArchiveSeparator = showArchiveSeparator
        self.shouldAnimateAppearance = shouldAnimateAppearance
        self.messageIndex = messageIndex
    }

    public func update(
        message: AgentMessage,
        isDarkMode: Bool,
        isLastMessage: Bool,
        isLoading: Bool,
        isArchived: Bool,
        showArchiveSeparator: Bool,
        messageIndex: Int
    ) {
        let contentChanged = self.message.content != message.content ||
                            self.message.contentParts != message.contentParts ||
                            self.message.thoughts != message.thoughts ||
                            self.message.contentChunks != message.contentChunks ||
                            self.message.thinkingChunks != message.thinkingChunks ||
                            self.message.isThinking != message.isThinking ||
                            self.message.isCollapsed != message.isCollapsed ||
                            self.message.generationTimeSeconds != message.generationTimeSeconds ||
                            self.message.streamError != message.streamError ||
                            self.isDarkMode != isDarkMode

        let metadataChanged = self.isLastMessage != isLastMessage ||
                              self.isLoading != isLoading ||
                              self.isArchived != isArchived ||
                              self.showArchiveSeparator != showArchiveSeparator ||
                              self.messageIndex != messageIndex

        if !contentChanged && !metadataChanged {
            return
        }

        if contentChanged {
            cachedHeight = nil
            cachedHeightKey = nil
        }

        DispatchQueue.main.async {
            self.message = message
            self.isDarkMode = isDarkMode
            self.isLastMessage = isLastMessage
            self.isLoading = isLoading
            self.isArchived = isArchived
            self.showArchiveSeparator = showArchiveSeparator
            self.messageIndex = messageIndex
        }
    }

    @discardableResult
    public func extendBufferIfNeeded(screenHeight: CGFloat) -> Bool {
        let currentBufferHeight = screenHeight * bufferMultiplier
        let threshold = currentBufferHeight * StreamingBufferConstants.extensionThresholdRatio
        let needsExtension = actualContentHeight > threshold
            && bufferMultiplier < StreamingBufferConstants.maxMultiplier

        if needsExtension {
            bufferMultiplier += StreamingBufferConstants.multiplierIncrement
        }
        return needsExtension
    }

    public func resetBuffer() {
        bufferMultiplier = StreamingBufferConstants.initialMultiplier
        actualContentHeight = 0
    }

    public func getCacheKey() -> Int {
        message.content.hashValue ^
        message.contentParts.hashValue ^
        (message.thoughts?.hashValue ?? 0) ^
        (message.contentChunks.hashValue) ^
        (message.thinkingChunks.hashValue) ^
        isDarkMode.hashValue
    }
}

public struct AgentObservableMessageCell: View {
    @ObservedObject public var wrapper: AgentObservableMessageWrapper
    public weak var driver: (any AgentMessageDriving)?
    public weak var coordinator: AgentMessageTableView.Coordinator?
    public var accessory: ((AgentMessage) -> AnyView)?
    @State private var hasAppeared = false

    private var bufferHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        return min(
            screenHeight * wrapper.bufferMultiplier,
            StreamingBufferConstants.maxCellHeight
        )
    }

    public init(
        wrapper: AgentObservableMessageWrapper,
        driver: (any AgentMessageDriving)? = nil,
        coordinator: AgentMessageTableView.Coordinator? = nil,
        accessory: ((AgentMessage) -> AnyView)? = nil
    ) {
        self.wrapper = wrapper
        self.driver = driver
        self.coordinator = coordinator
        self.accessory = accessory
    }

    public var body: some View {
        VStack(spacing: 0) {
            if wrapper.showArchiveSeparator {
                HStack(spacing: 8) {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                    Text("archived")
                        .foregroundColor(.gray)
                        .font(.system(size: 12))
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
            }

            ZStack(alignment: .topLeading) {
                if wrapper.isLoading && wrapper.isLastMessage {
                    Color.clear
                        .frame(height: bufferHeight)
                }

                AgentMessageView(
                    message: wrapper.message,
                    isDarkMode: wrapper.isDarkMode,
                    isLastMessage: wrapper.isLastMessage,
                    isLoading: wrapper.isLoading,
                    messageIndex: wrapper.messageIndex,
                    driver: driver
                ) {
                    if let acc = accessory?(wrapper.message) {
                        acc
                    }
                }
                .opacity(wrapper.isArchived ? 0.6 : 1.0)
                .padding(.vertical, 8)
                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 100 : 8)
                .modifier(AgentPadLayoutModifier())
                .agentIf(wrapper.isLoading && wrapper.isLastMessage) { view in
                    view.background(
                        GeometryReader { geometry in
                            Color.clear
                                .onChange(of: geometry.size.height) { _, newHeight in
                                    wrapper.actualContentHeight = newHeight
                                }
                        }
                    )
                }
            }
        }
        .opacity(wrapper.shouldAnimateAppearance && !hasAppeared ? 0 : 1)
        .onAppear {
            if wrapper.shouldAnimateAppearance && !hasAppeared {
                withAnimation(.easeIn(duration: 0.2)) {
                    hasAppeared = true
                }
            } else {
                hasAppeared = true
            }
        }
    }
}

private struct AgentPadLayoutModifier: ViewModifier {
    func body(content: Content) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            content
                .frame(maxWidth: 900)
                .frame(maxWidth: .infinity)
        } else {
            content
        }
    }
}

fileprivate extension View {
    @ViewBuilder
    func agentIf<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
