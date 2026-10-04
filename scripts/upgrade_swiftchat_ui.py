from pathlib import Path

root = Path("upstream/SwiftChat")

# ===========================================================================
# 1. ChatModels.swift: Add MessageContentPart, contentParts, and Hashable Chat
# ===========================================================================
models_path = root / "SwiftChat/Models/ChatModels.swift"
models_src = models_path.read_text(encoding="utf-8")

# 1a. Make WebSearchSource Hashable
target_wss = "struct WebSearchSource: Codable, Equatable, Identifiable {"
repl_wss = "struct WebSearchSource: Codable, Equatable, Identifiable, Hashable {"
if target_wss not in models_src:
    raise SystemExit("WebSearchSource definition not found")
models_src = models_src.replace(target_wss, repl_wss, 1)

# 1b. Add MessageContentPart struct before struct Message
target_msg = "/// Represents a single message in a chat\nstruct Message: Identifiable, Codable, Equatable {"
content_part_struct = """// MARK: - Rich Content Models

struct MessageContentPart: Identifiable, Codable, Equatable, Hashable {
    enum Kind: String, Codable, Hashable {
        case markdown
        case image
        case video
        case youtube
        case linkPreview
    }

    let id: String
    let kind: Kind

    var markdown: String?
    var sources: [WebSearchSource]

    var url: String?
    var title: String?
    var subtitle: String?
    var caption: String?
    var thumbnailURL: String?
    var youtubeVideoID: String?

    init(
        id: String = UUID().uuidString.lowercased(),
        kind: Kind,
        markdown: String? = nil,
        sources: [WebSearchSource] = [],
        url: String? = nil,
        title: String? = nil,
        subtitle: String? = nil,
        caption: String? = nil,
        thumbnailURL: String? = nil,
        youtubeVideoID: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.markdown = markdown
        self.sources = sources
        self.url = url
        self.title = title
        self.subtitle = subtitle
        self.caption = caption
        self.thumbnailURL = thumbnailURL
        self.youtubeVideoID = youtubeVideoID
    }
}

"""
if target_msg not in models_src:
    raise SystemExit("struct Message declaration not found")
models_src = models_src.replace(target_msg, content_part_struct + target_msg, 1)

# 1c. Add contentParts property to Message
target_attach_prop = "    var attachments: [Attachment] = []\n"
repl_attach_prop = "    var attachments: [Attachment] = []\n    var contentParts: [MessageContentPart] = []\n"
if target_attach_prop not in models_src:
    raise SystemExit("Message attachments property not found")
models_src = models_src.replace(target_attach_prop, repl_attach_prop, 1)

# 1d. Add contentParts to Message.init
target_init = "init(id: String = UUID().uuidString.lowercased(), role: MessageRole, content: String, thoughts: String? = nil, isThinking: Bool = false, timestamp: Date = Date(), isCollapsed: Bool = true, generationTimeSeconds: Double? = nil, contentChunks: [ContentChunk] = [], thinkingChunks: [ThinkingChunk] = [], webSearchState: WebSearchState? = nil, attachments: [Attachment] = []) {"
repl_init = "init(id: String = UUID().uuidString.lowercased(), role: MessageRole, content: String, thoughts: String? = nil, isThinking: Bool = false, timestamp: Date = Date(), isCollapsed: Bool = true, generationTimeSeconds: Double? = nil, contentChunks: [ContentChunk] = [], thinkingChunks: [ThinkingChunk] = [], webSearchState: WebSearchState? = nil, attachments: [Attachment] = [], contentParts: [MessageContentPart] = []) {"
if target_init not in models_src:
    raise SystemExit("Message init not found")
models_src = models_src.replace(target_init, repl_init, 1)

target_assign = "        self.attachments = attachments\n    }"
repl_assign = "        self.attachments = attachments\n        self.contentParts = contentParts\n    }"
if target_assign not in models_src:
    raise SystemExit("Message init assignment not found")
models_src = models_src.replace(target_assign, repl_assign, 1)

# 1e. Add contentParts to CodingKeys
target_keys = "        case attachments\n        case annotations\n    }"
repl_keys = "        case attachments\n        case annotations\n        case contentParts\n    }"
if target_keys not in models_src:
    raise SystemExit("Message CodingKeys not found")
models_src = models_src.replace(target_keys, repl_keys, 1)

# 1f. Add contentParts decoding
target_decode = "        attachments = try container.decodeIfPresent([Attachment].self, forKey: .attachments) ?? []\n        annotations = try container.decodeIfPresent([Annotation].self, forKey: .annotations)\n    }"
repl_decode = "        attachments = try container.decodeIfPresent([Attachment].self, forKey: .attachments) ?? []\n        annotations = try container.decodeIfPresent([Annotation].self, forKey: .annotations)\n        contentParts = try container.decodeIfPresent([MessageContentPart].self, forKey: .contentParts) ?? []\n    }"
if target_decode not in models_src:
    raise SystemExit("Message decoder not found")
models_src = models_src.replace(target_decode, repl_decode, 1)

# 1g. Add contentParts encoding
target_encode = "        if !attachments.isEmpty {\n            try container.encode(attachments, forKey: .attachments)\n        }\n        try container.encodeIfPresent(annotations, forKey: .annotations)\n    }"
repl_encode = "        if !attachments.isEmpty {\n            try container.encode(attachments, forKey: .attachments)\n        }\n        if !contentParts.isEmpty {\n            try container.encode(contentParts, forKey: .contentParts)\n        }\n        try container.encodeIfPresent(annotations, forKey: .annotations)\n    }"
if target_encode not in models_src:
    raise SystemExit("Message encoder not found")
models_src = models_src.replace(target_encode, repl_encode, 1)

# 1h. Add Chat: Hashable extension
chat_hashable = """

extension Chat: Hashable {
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
"""
models_src += chat_hashable
models_path.write_text(models_src, encoding="utf-8")
print("1. ChatModels.swift patched: MessageContentPart, contentParts, and Hashable Chat added.")


# ===========================================================================
# 2. MessageTableView.swift: Caching & change-detection support for contentParts
# ===========================================================================
table_path = root / "SwiftChat/Views/MessageTableView.swift"
table_src = table_path.read_text(encoding="utf-8")

old_change_check = "        let contentChanged = self.message.content != message.content ||\n"
new_change_check = "        let contentChanged = self.message.content != message.content ||\n                            self.message.contentParts != message.contentParts ||\n"
if old_change_check not in table_src:
    raise SystemExit("MessageTableView contentChanged check not found")
table_src = table_src.replace(old_change_check, new_change_check, 1)

old_cache_key = """    func getCacheKey() -> Int {
        message.content.hashValue ^
        (message.thoughts?.hashValue ?? 0) ^
        (message.contentChunks.hashValue) ^
        (message.thinkingChunks.hashValue) ^
        isDarkMode.hashValue
    }"""
new_cache_key = """    func getCacheKey() -> Int {
        message.content.hashValue ^
        message.contentParts.hashValue ^
        (message.thoughts?.hashValue ?? 0) ^
        (message.contentChunks.hashValue) ^
        (message.thinkingChunks.hashValue) ^
        isDarkMode.hashValue
    }"""
if old_cache_key not in table_src:
    raise SystemExit("MessageTableView getCacheKey not found")
table_src = table_src.replace(old_cache_key, new_cache_key, 1)
table_path.write_text(table_src, encoding="utf-8")
print("2. MessageTableView.swift patched: contentParts cache invalidation and change detection added.")


# ===========================================================================
# 3. MessageInputView.swift: Native iOS 26 Liquid Glass Menu for + button
# ===========================================================================
input_path = root / "SwiftChat/Views/MessageInputView.swift"
input_src = input_path.read_text(encoding="utf-8")

# Remove old AddToSheet presentation from root
old_input_sheet = """            .sheet(isPresented: $showAddSheet, onDismiss: {
                guard let action = pendingPickerAction else { return }
                pendingPickerAction = nil
                switch action {
                case .camera: showCamera = true
                case .photos: showPhotoPicker = true
                case .files: showDocumentPicker = true
                }
            }) {
                AddToSheetView(
                    viewModel: viewModel,
                    isDarkMode: isDarkMode,
                    onCamera: {
                        pendingPickerAction = .camera
                        showAddSheet = false
                    },
                    onPhotos: {
                        pendingPickerAction = .photos
                        showAddSheet = false
                    },
                    onFiles: {
                        pendingPickerAction = .files
                        showAddSheet = false
                    }
                )
                .presentationDetents([.height(340)])
                .presentationBackground(isDarkMode ? Color(hex: "161616") : Color(UIColor.systemGroupedBackground))
            }"""
if old_input_sheet not in input_src:
    raise SystemExit("MessageInputView AddToSheet sheet not found")
input_src = input_src.replace(old_input_sheet, "", 1)

# Replace attachButton with native Menu
old_attach = """    @ViewBuilder
    private var attachButton: some View {
        Button {
            showAddSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 20))
                .foregroundColor(.secondary)
                .frame(width: 24, height: 24)
        }
        .disabled(viewModel.isLoading || viewModel.isProcessingAttachment)
        .padding(.leading, 8)
    }"""

new_attach = """    @ViewBuilder
    private var attachButton: some View {
        if #available(iOS 26, *) {
            Menu {
                if viewModel.currentModel.isMultimodal {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button {
                            showCamera = true
                        } label: {
                            Label("Camera", systemImage: "camera")
                        }
                    }
                    Button {
                        showPhotoPicker = true
                    } label: {
                        Label("Photos", systemImage: "photo.on.rectangle")
                    }
                }
                Button {
                    showDocumentPicker = true
                } label: {
                    Label("Files", systemImage: "doc.badge.arrow.up")
                }

                Menu {
                    ForEach(AppConfig.shared.filteredModelTypes()) { model in
                        Button {
                            viewModel.changeModel(to: model)
                        } label: {
                            if viewModel.currentModel.id == model.id {
                                Label(model.displayName, systemImage: "checkmark")
                            } else {
                                Text(model.displayName)
                            }
                        }
                    }
                } label: {
                    Label("Model (\\(viewModel.currentModel.displayName))", systemImage: "cpu")
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .clipShape(Circle())
            .disabled(viewModel.isLoading || viewModel.isProcessingAttachment)
            .padding(.leading, 8)
        } else {
            Menu {
                if viewModel.currentModel.isMultimodal {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button {
                            showCamera = true
                        } label: {
                            Label("Camera", systemImage: "camera")
                        }
                    }
                    Button {
                        showPhotoPicker = true
                    } label: {
                        Label("Photos", systemImage: "photo.on.rectangle")
                    }
                }
                Button {
                    showDocumentPicker = true
                } label: {
                    Label("Files", systemImage: "doc.badge.arrow.up")
                }

                Menu {
                    ForEach(AppConfig.shared.filteredModelTypes()) { model in
                        Button {
                            viewModel.changeModel(to: model)
                        } label: {
                            if viewModel.currentModel.id == model.id {
                                Label(model.displayName, systemImage: "checkmark")
                            } else {
                                Text(model.displayName)
                            }
                        }
                    }
                } label: {
                    Label("Model (\\(viewModel.currentModel.displayName))", systemImage: "cpu")
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                    .frame(width: 24, height: 24)
            }
            .disabled(viewModel.isLoading || viewModel.isProcessingAttachment)
            .padding(.leading, 8)
        }
    }"""
if old_attach not in input_src:
    raise SystemExit("MessageInputView attachButton not found")
input_src = input_src.replace(old_attach, new_attach, 1)
input_path.write_text(input_src, encoding="utf-8")
print("3. MessageInputView.swift patched: Native iOS 26 Liquid Glass Menu source morph added.")


# ===========================================================================
# 4. ChatView.swift: Real NavigationSplitView architecture
# ===========================================================================
chat_view_path = root / "SwiftChat/Views/ChatView.swift"
chat_view_src = chat_view_path.read_text(encoding="utf-8")

# Replace ChatContainer with NavigationSplitView shell
start_container = chat_view_src.find("// MARK: - ChatContainer")
end_container = chat_view_src.find("// MARK: - WelcomeView")
if start_container < 0 or end_container < 0:
    raise SystemExit("ChatContainer range in ChatView.swift not found")

new_container = r"""// MARK: - ChatContainer

/// The primary SwiftUI container that holds the main chat interface and sidebar navigation using NavigationSplitView.
struct ChatContainer: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var viewModel: SwiftChat.ChatViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject private var settings = SettingsManager.shared

    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic
    @State private var preferredCompactColumn: NavigationSplitViewColumn = .detail
    @State private var messageText = ""

    private var toolbarContentColor: Color {
        colorScheme == .dark ? Color.white : Color.black
    }

    var body: some View {
        NavigationSplitView(
            columnVisibility: $columnVisibility,
            preferredCompactColumn: $preferredCompactColumn
        ) {
            sidebar
        } detail: {
            detailColumn
        }
        .environmentObject(viewModel)
        .onAppear {
            if horizontalSizeClass == .compact {
                columnVisibility = .detailOnly
                preferredCompactColumn = .detail
            }
            setupNavigationBarAppearance()
        }
        .onChange(of: colorScheme) { _, _ in
            setupNavigationBarAppearance()
        }
        .onChange(of: viewModel.currentChat?.id) { _, _ in
            if horizontalSizeClass == .compact {
                columnVisibility = .detailOnly
                preferredCompactColumn = .detail
            }
        }
        .fullScreenCover(isPresented: $viewModel.showImageViewer) {
            ImageViewerOverlay(
                images: viewModel.imageViewerImages,
                initialIndex: viewModel.imageViewerIndex,
                onDismiss: { viewModel.showImageViewer = false }
            )
        }
    }

    private var sidebar: some View {
        VStack(spacing: 0) {
            if horizontalSizeClass == .compact {
                Button(action: createNewChat) {
                    Label("New Chat", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .accessibilityLabel("New Chat")
                .accessibilityIdentifier("new-chat-button")
            }

            ChatSidebar(viewModel: viewModel)
        }
        .navigationTitle("Chats")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: createNewChat) {
                    Label("New Chat", systemImage: "plus")
                }
                .accessibilityLabel("New Chat")
                .accessibilityIdentifier("new-chat-button")
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }

    private var detailColumn: some View {
        ChatListView(
            isDarkMode: colorScheme == .dark,
            isLoading: viewModel.isLoading,
            viewModel: viewModel,
            messageText: $messageText
        )
        .background(Color.chatBackground(isDarkMode: colorScheme == .dark))
        .navigationTitle(viewModel.currentChat?.title ?? "SwiftChat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if horizontalSizeClass == .compact {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        preferredCompactColumn = .sidebar
                    } label: {
                        Label("Show Sidebar", systemImage: "sidebar.leading")
                    }
                    .accessibilityLabel("Show Sidebar")
                    .accessibilityIdentifier("show-sidebar-button")
                }
            }

            if !(viewModel.currentChat?.isBlankChat ?? true) {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: createNewChat) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(toolbarContentColor)
                    }
                }
            }
        }
    }

    private func createNewChat() {
        let language = settings.selectedLanguage == "System" ? nil : settings.selectedLanguage
        viewModel.createNewChat(language: language)
        messageText = ""
        if horizontalSizeClass == .compact {
            columnVisibility = .detailOnly
            preferredCompactColumn = .detail
        }
    }

    private func setupNavigationBarAppearance() {
        if #available(iOS 26, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.shadowColor = .clear
            updateAllNavigationBars(with: appearance)
        } else {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = colorScheme == .dark ? UIColor(Color.backgroundPrimary) : .white
            appearance.shadowColor = .clear
            updateAllNavigationBars(with: appearance)
        }
    }

    private func updateAllNavigationBars(with appearance: UINavigationBarAppearance) {
        let tintColor: UIColor = colorScheme == .dark ? .white : .black
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = tintColor
    }
}

"""
chat_view_src = chat_view_src[:start_container] + new_container + chat_view_src[end_container:]
chat_view_path.write_text(chat_view_src, encoding="utf-8")
print("4. ChatView.swift patched: Real NavigationSplitView shell installed.")


# ===========================================================================
# 5. ChatSidebar.swift: ManifoldKit Advanced SessionListView architecture
# ===========================================================================
sidebar_path = root / "SwiftChat/Views/ChatSidebar.swift"
sidebar_new = """//
//  ChatSidebar.swift
//  SwiftChat
//
//  Created on 03/25/26.
//  Copyright © 2026 Sacha Servan-Schreiber. All rights reserved.
//

import SwiftUI

/// Sidebar session list matching ManifoldKit Advanced SessionListView architecture
struct ChatSidebar: View {
    @ObservedObject var viewModel: SwiftChat.ChatViewModel

    @State private var chatToDelete: Chat?
    @State private var chatToRename: Chat?
    @State private var renameText: String = ""
    @State private var searchText: String = ""

    private var filteredChats: [Chat] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return viewModel.chats }
        return viewModel.chats.filter { chat in
            if chat.title.lowercased().contains(trimmed) { return true }
            return chat.messages.contains { $0.content.lowercased().contains(trimmed) }
        }
    }

    private var selectionBinding: Binding<Chat?> {
        Binding(
            get: { viewModel.currentChat },
            set: { newChat in
                if let newChat = newChat {
                    viewModel.selectChat(newChat)
                }
            }
        )
    }

    var body: some View {
        mainContent
            .searchable(text: $searchText, prompt: "Search chats")
            .alert("Rename Chat", isPresented: isRenamePresented) {
                TextField("Chat title", text: $renameText)
                Button("Cancel", role: .cancel) { chatToRename = nil }
                Button("Rename") {
                    if let chat = chatToRename {
                        let newTitle = renameText
                        viewModel.updateChatTitle(chat.id, newTitle: newTitle)
                    }
                    chatToRename = nil
                }
            }
            .alert("Delete Chat?", isPresented: isDeletePresented, presenting: chatToDelete) { chat in
                Button("Delete", role: .destructive) {
                    viewModel.deleteChat(chat.id)
                    if viewModel.chats.isEmpty {
                        viewModel.createNewChat()
                    }
                    chatToDelete = nil
                }
                Button("Cancel", role: .cancel) { chatToDelete = nil }
            } message: { chat in
                Text("This will permanently delete \\"\\(chat.title)\\" and all its messages.")
            }
    }

    @ViewBuilder
    private var mainContent: some View {
        if viewModel.chats.isEmpty && searchText.isEmpty {
            if #available(iOS 17.0, *) {
                ContentUnavailableView {
                    Label("No Chats", systemImage: "bubble.left.and.bubble.right")
                } description: {
                    Text("Tap the + button to start a new chat.")
                }
            } else {
                Text("No Chats")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        } else if filteredChats.isEmpty && !searchText.isEmpty {
            if #available(iOS 17.0, *) {
                ContentUnavailableView.search(text: searchText)
            } else {
                Text("No results for \\"\\(searchText)\\"")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        } else {
            sessionList
        }
    }

    private var sessionList: some View {
        List(selection: selectionBinding) {
            Section {
                ForEach(filteredChats) { chat in
                    rowContent(for: chat)
                        .tag(chat)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            deleteButton(for: chat)
                        }
                        .swipeActions(edge: .leading) {
                            renameButton(for: chat)
                                .tint(.blue)
                        }
                        .contextMenu {
                            renameButton(for: chat)
                            deleteButton(for: chat)
                        }
                }
            }
        }
        .accessibilityIdentifier("session-list")
    }

    @ViewBuilder
    private func rowContent(for chat: Chat) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(chat.title)
                    .font(.headline)
                    .lineLimit(1)
                if chat.isBlankChat {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 6, height: 6)
                }
            }

            Text(chat.createdAt, style: .relative)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\\(chat.title), created \\(chat.createdAt, style: .relative) ago")
        .accessibilityIdentifier("session-row")
    }

    private func deleteButton(for chat: Chat) -> some View {
        Button(role: .destructive) {
            chatToDelete = chat
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    private func renameButton(for chat: Chat) -> some View {
        Button {
            renameText = chat.title
            chatToRename = chat
        } label: {
            Label("Rename", systemImage: "pencil")
        }
    }

    private var isRenamePresented: Binding<Bool> {
        Binding(
            get: { chatToRename != nil },
            set: { if !$0 { chatToRename = nil } }
        )
    }

    private var isDeletePresented: Binding<Bool> {
        Binding(
            get: { chatToDelete != nil },
            set: { if !$0 { chatToDelete = nil } }
        )
    }
}
"""
sidebar_path.write_text(sidebar_new, encoding="utf-8")
print("5. ChatSidebar.swift patched: Native List(selection:) session list faithfully ported.")


# ===========================================================================
# 6. MessageView.swift: Shared favicon stack, inline source expansion, rich media
# ===========================================================================
msg_view_path = root / "SwiftChat/Views/MessageView.swift"
msg_view_src = msg_view_path.read_text(encoding="utf-8")

# 6a. Add imports
msg_view_src = "import AVKit\nimport WebKit\n" + msg_view_src

# 6b. Insert contentParts rendering into MessageView body
target_assistant_branch = """                            if !message.contentChunks.isEmpty {
                                ChunkedContentView(chunks: message.contentChunks, isDarkMode: isDarkMode, isStreaming: isLoading && isLastMessage)
                                    .equatable()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                LaTeXMarkdownView(content: message.content, isDarkMode: isDarkMode, isStreaming: isLoading && isLastMessage)
                                    .equatable()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }"""

repl_assistant_branch = """                            if !message.contentParts.isEmpty {
                                ForEach(message.contentParts) { part in
                                    switch part.kind {
                                    case .markdown:
                                        if let text = part.markdown, !text.isEmpty {
                                            LaTeXMarkdownView(content: text, isDarkMode: isDarkMode, isStreaming: false)
                                                .equatable()
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        if !part.sources.isEmpty {
                                            SectionSourcesClusterView(sources: part.sources, isDarkMode: isDarkMode)
                                        }
                                    case .image:
                                        InlineImageView(part: part, isDarkMode: isDarkMode)
                                    case .video:
                                        InlineVideoView(part: part, isDarkMode: isDarkMode)
                                    case .youtube:
                                        InlineYouTubeView(part: part, isDarkMode: isDarkMode)
                                    case .linkPreview:
                                        InlineLinkPreviewView(part: part, isDarkMode: isDarkMode)
                                    }
                                }
                            } else if !message.contentChunks.isEmpty {
                                ChunkedContentView(chunks: message.contentChunks, isDarkMode: isDarkMode, isStreaming: isLoading && isLastMessage)
                                    .equatable()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                LaTeXMarkdownView(content: message.content, isDarkMode: isDarkMode, isStreaming: isLoading && isLastMessage)
                                    .equatable()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }"""

if target_assistant_branch not in msg_view_src:
    raise SystemExit("MessageView assistant rendering branch not found")
msg_view_src = msg_view_src.replace(target_assistant_branch, repl_assistant_branch, 1)

# 6c. Update action buttons check to also show if contentParts are present
target_action_check = """                // Add action buttons for assistant messages (only when not streaming)
                if message.role == .assistant &&
                   (!message.content.isEmpty || message.thoughts != nil) &&
                   !(isLoading && isLastMessage) {"""

repl_action_check = """                // Add action buttons for assistant messages (only when not streaming)
                if message.role == .assistant &&
                   (!message.content.isEmpty || !message.contentParts.isEmpty || message.thoughts != nil) &&
                   !(isLoading && isLastMessage) {"""

if target_action_check not in msg_view_src:
    raise SystemExit("MessageView action buttons check not found")
msg_view_src = msg_view_src.replace(target_action_check, repl_action_check, 1)

# 6d. Refactor SourcesButton and add SourceFaviconStack, SectionSourcesClusterView, Rich Media Views
target_sources_button_start = "/// Button showing \"Sources\" with overlapping favicons\nprivate struct SourcesButton: View {"
sources_and_media_views = """// MARK: - Reusable Favicon Stack

struct SourceFaviconStack: View {
    let sources: [WebSearchSource]
    let isDarkMode: Bool
    var iconSize: CGFloat = 18
    var overlap: CGFloat = -6

    private var uniqueDomains: [String] {
        var seen = Set<String>()
        var domains: [String] = []
        for source in sources {
            let domain = getDomain(from: source.url)
            if !seen.contains(domain) {
                seen.insert(domain)
                domains.append(domain)
            }
            if domains.count >= 4 { break }
        }
        return domains
    }

    private func getDomain(from urlString: String) -> String {
        guard let url = URL(string: urlString),
              let host = url.host else {
            return urlString
        }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }

    private func faviconUrl(for domain: String) -> String {
        "https://icons.duckduckgo.com/ip3/\\(domain).ico"
    }

    var body: some View {
        HStack(spacing: overlap) {
            ForEach(Array(uniqueDomains.enumerated()), id: \\.offset) { index, domain in
                AsyncImage(url: URL(string: faviconUrl(for: domain))) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure, .empty:
                        Image(systemName: "globe")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: iconSize, height: iconSize)
                .background(isDarkMode ? Color.black : Color.white)
                .clipShape(Circle())
                .overlay(Circle().stroke(isDarkMode ? Color.white.opacity(0.2) : Color.black.opacity(0.1), lineWidth: 1))
                .zIndex(Double(uniqueDomains.count - index))
            }
        }
    }
}

/// In-section compact citation cluster expanding inline source rows
struct SectionSourcesClusterView: View {
    let sources: [WebSearchSource]
    let isDarkMode: Bool
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 5) {
                    SourceFaviconStack(sources: sources, isDarkMode: isDarkMode, iconSize: 15, overlap: -5)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(isDarkMode ? .white.opacity(0.6) : .black.opacity(0.5))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())

            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(sources) { source in
                        SourceRowView(source: source, isDarkMode: isDarkMode)
                    }
                }
                .padding(.leading, 6)
                .padding(.vertical, 2)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Rich Media Component Views

struct InlineImageView: View {
    let part: MessageContentPart
    let isDarkMode: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Group {
                if let urlString = part.url, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                                ProgressView()
                            }
                            .aspectRatio(16/9, contentMode: .fit)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        case .failure:
                            fallbackView
                        @unknown default:
                            fallbackView
                        }
                    }
                } else if let base64 = part.thumbnailURL, let data = Data(base64Encoded: base64), let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    fallbackView
                }
            }
            .frame(maxWidth: 480)

            if let caption = part.caption, !caption.isEmpty {
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)
            }
        }
        .padding(.vertical, 4)
    }

    private var fallbackView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
            VStack(spacing: 6) {
                Image(systemName: "photo")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)
                if let title = part.title {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .aspectRatio(16/9, contentMode: .fit)
    }
}

struct InlineVideoView: View {
    let part: MessageContentPart
    let isDarkMode: Bool
    @State private var player: AVPlayer? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                if let urlString = part.url, let url = URL(string: urlString) {
                    VideoPlayer(player: player)
                        .onAppear {
                            if player == nil {
                                player = AVPlayer(url: url)
                            }
                        }
                        .onDisappear {
                            player?.pause()
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                        .overlay {
                            Image(systemName: "video.slash")
                                .font(.system(size: 28))
                                .foregroundStyle(.secondary)
                        }
                }
            }
            .aspectRatio(16/9, contentMode: .fit)
            .frame(maxWidth: 480)

            if let caption = part.caption ?? part.title, !caption.isEmpty {
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)
            }
        }
        .padding(.vertical, 4)
    }
}

struct YouTubeWebView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.layer.cornerRadius = 16
        webView.layer.masksToBounds = true

        let embedHTML = \"\"\"
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
          * { margin: 0; padding: 0; }
          body, html { width: 100%; height: 100%; background: #000; overflow: hidden; }
          iframe { width: 100%; height: 100%; border: none; }
        </style>
        </head>
        <body>
        <iframe src="https://www.youtube.com/embed/\\(videoID)?playsinline=1&rel=0&modestbranding=1" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
        </body>
        </html>
        \"\"\"
        webView.loadHTMLString(embedHTML, baseURL: URL(string: "https://www.youtube.com"))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct InlineYouTubeView: View {
    let part: MessageContentPart
    let isDarkMode: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                if let videoID = part.youtubeVideoID ?? extractYouTubeID(from: part.url) {
                    YouTubeWebView(videoID: videoID)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    fallbackView
                }
            }
            .aspectRatio(16/9, contentMode: .fit)
            .frame(maxWidth: 480)

            if let title = part.title {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    if let subtitle = part.subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                .padding(.leading, 4)
            }
        }
        .padding(.vertical, 4)
    }

    private var fallbackView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
            VStack(spacing: 6) {
                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.red)
                Text(part.title ?? "YouTube Video")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func extractYouTubeID(from urlString: String?) -> String? {
        guard let urlString = urlString, let url = URL(string: urlString) else { return nil }
        if url.host?.contains("youtu.be") == true {
            return url.pathComponents.dropFirst().first
        }
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItem = components.queryItems?.first(where: { $0.name == "v" }) {
            return queryItem.value
        }
        return nil
    }
}

struct InlineLinkPreviewView: View {
    let part: MessageContentPart
    let isDarkMode: Bool

    private var displayHost: String {
        guard let urlString = part.url, let url = URL(string: urlString), let host = url.host else {
            return part.url ?? ""
        }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }

    var body: some View {
        Button {
            if let urlString = part.url, let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 12) {
                if let thumb = part.thumbnailURL, let thumbURL = URL(string: thumb) {
                    AsyncImage(url: thumbURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            FaviconView(url: part.url ?? "", isDarkMode: isDarkMode)
                        }
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    FaviconView(url: part.url ?? "", isDarkMode: isDarkMode)
                        .frame(width: 22, height: 22)
                        .padding(8)
                        .background(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(part.title ?? displayHost)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    if let subtitle = part.subtitle ?? part.caption, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    Text(displayHost)
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.045))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.08), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: 480)
        .padding(.vertical, 4)
    }
}

"""
if target_sources_button_start not in msg_view_src:
    raise SystemExit("MessageView SourcesButton anchor not found")
msg_view_src = msg_view_src.replace(target_sources_button_start, sources_and_media_views + target_sources_button_start, 1)

# Refactor SourcesButton body to use SourceFaviconStack
old_sources_button_body = """            HStack(spacing: 4) {
                Text("Sources")
                    .font(.system(size: 13, weight: .medium))
                
                // Overlapping favicons
                HStack(spacing: -6) {
                    ForEach(Array(uniqueDomains.enumerated()), id: \\.offset) { index, domain in
                        AsyncImage(url: URL(string: faviconUrl(for: domain))) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            case .failure, .empty:
                                Image(systemName: "globe")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: 18, height: 18)
                        .background(isDarkMode ? Color.black : Color.white)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(isDarkMode ? Color.white.opacity(0.2) : Color.black.opacity(0.1), lineWidth: 1))
                        .zIndex(Double(uniqueDomains.count - index))
                    }
                }
            }"""

new_sources_button_body = """            HStack(spacing: 6) {
                Text("Sources")
                    .font(.system(size: 13, weight: .medium))

                SourceFaviconStack(sources: sources, isDarkMode: isDarkMode, iconSize: 18, overlap: -6)
            }"""

if old_sources_button_body not in msg_view_src:
    raise SystemExit("MessageView SourcesButton body not found")
msg_view_src = msg_view_src.replace(old_sources_button_body, new_sources_button_body, 1)

msg_view_path.write_text(msg_view_src, encoding="utf-8")
print("6. MessageView.swift patched: Shared favicon stack, inline source expansion, rich media added.")

print("All SwiftChat UI upgrades applied successfully!")
