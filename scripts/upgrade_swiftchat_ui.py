from pathlib import Path

root = Path("upstream/SwiftChat")

# ===========================================================================
# 1. ChatModels.swift: Add AgentActivityItem, MessageContentPart, and Message fields
# ===========================================================================
models_path = root / "SwiftChat/Models/ChatModels.swift"
models_src = models_path.read_text(encoding="utf-8")

# 1a. Make WebSearchSource Hashable
target_wss = "struct WebSearchSource: Codable, Equatable, Identifiable {"
repl_wss = "struct WebSearchSource: Codable, Equatable, Identifiable, Hashable {"
if target_wss not in models_src:
    raise SystemExit("WebSearchSource definition not found")
models_src = models_src.replace(target_wss, repl_wss, 1)

# 1b. Add AgentActivity models and MessageContentPart struct before struct Message
target_msg = "/// Represents a single message in a chat\nstruct Message: Identifiable, Codable, Equatable {"
activity_and_content_models = """// MARK: - Agent Activity Models

enum AgentActivityKind: String, Codable, Equatable, Hashable {
    case reasoning
    case webSearch
    case urlFetch
    case toolCall
    case github
    case status
}

enum AgentActivityStatus: String, Codable, Equatable, Hashable {
    case pending
    case running
    case completed
    case failed
}

struct AgentActivityItem: Identifiable, Codable, Equatable, Hashable {
    var id: String
    var kind: AgentActivityKind
    var status: AgentActivityStatus

    var title: String
    var summary: String?

    var startedAt: Date?
    var completedAt: Date?

    // Search payload
    var query: String?
    var sources: [WebSearchSource]

    // Tool payload
    var toolName: String?
    var toolArgumentsJSON: String?
    var toolResultSummary: String?
    var serviceName: String?
    var serviceURL: String?

    init(
        id: String = UUID().uuidString.lowercased(),
        kind: AgentActivityKind,
        status: AgentActivityStatus = .completed,
        title: String,
        summary: String? = nil,
        startedAt: Date? = nil,
        completedAt: Date? = nil,
        query: String? = nil,
        sources: [WebSearchSource] = [],
        toolName: String? = nil,
        toolArgumentsJSON: String? = nil,
        toolResultSummary: String? = nil,
        serviceName: String? = nil,
        serviceURL: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.status = status
        self.title = title
        self.summary = summary
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.query = query
        self.sources = sources
        self.toolName = toolName
        self.toolArgumentsJSON = toolArgumentsJSON
        self.toolResultSummary = toolResultSummary
        self.serviceName = serviceName
        self.serviceURL = serviceURL
    }
}

// MARK: - Rich Content Models

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
    var assetName: String?

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
        youtubeVideoID: String? = nil,
        assetName: String? = nil
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
        self.assetName = assetName
    }
}

"""
if target_msg not in models_src:
    raise SystemExit("struct Message declaration not found")
models_src = models_src.replace(target_msg, activity_and_content_models + target_msg, 1)

# 1c. Add contentParts and activityItems properties to Message
target_attach_prop = "    var attachments: [Attachment] = []\n"
repl_attach_prop = """    var attachments: [Attachment] = []
    var contentParts: [MessageContentPart] = []
    var activityItems: [AgentActivityItem] = []
    var activityStartedAt: Date? = nil
    var activityCompletedAt: Date? = nil
"""
if target_attach_prop not in models_src:
    raise SystemExit("Message attachments property not found")
models_src = models_src.replace(target_attach_prop, repl_attach_prop, 1)

# 1d. Add properties to Message.init
target_init = "init(id: String = UUID().uuidString.lowercased(), role: MessageRole, content: String, thoughts: String? = nil, isThinking: Bool = false, timestamp: Date = Date(), isCollapsed: Bool = true, generationTimeSeconds: Double? = nil, contentChunks: [ContentChunk] = [], thinkingChunks: [ThinkingChunk] = [], webSearchState: WebSearchState? = nil, attachments: [Attachment] = []) {"
repl_init = "init(id: String = UUID().uuidString.lowercased(), role: MessageRole, content: String, thoughts: String? = nil, isThinking: Bool = false, timestamp: Date = Date(), isCollapsed: Bool = true, generationTimeSeconds: Double? = nil, contentChunks: [ContentChunk] = [], thinkingChunks: [ThinkingChunk] = [], webSearchState: WebSearchState? = nil, attachments: [Attachment] = [], contentParts: [MessageContentPart] = [], activityItems: [AgentActivityItem] = [], activityStartedAt: Date? = nil, activityCompletedAt: Date? = nil) {"
if target_init not in models_src:
    raise SystemExit("Message init not found")
models_src = models_src.replace(target_init, repl_init, 1)

target_assign = "        self.attachments = attachments\n    }"
repl_assign = """        self.attachments = attachments
        self.contentParts = contentParts
        self.activityItems = activityItems
        self.activityStartedAt = activityStartedAt
        self.activityCompletedAt = activityCompletedAt
    }"""
if target_assign not in models_src:
    raise SystemExit("Message init assignment not found")
models_src = models_src.replace(target_assign, repl_assign, 1)

# 1e. Add CodingKeys
target_keys = "        case attachments\n        case annotations\n    }"
repl_keys = """        case attachments
        case annotations
        case contentParts
        case activityItems
        case activityStartedAt
        case activityCompletedAt
    }"""
if target_keys not in models_src:
    raise SystemExit("Message CodingKeys not found")
models_src = models_src.replace(target_keys, repl_keys, 1)

# 1f. Add decoding
target_decode = "        attachments = try container.decodeIfPresent([Attachment].self, forKey: .attachments) ?? []\n        annotations = try container.decodeIfPresent([Annotation].self, forKey: .annotations)\n    }"
repl_decode = """        attachments = try container.decodeIfPresent([Attachment].self, forKey: .attachments) ?? []
        annotations = try container.decodeIfPresent([Annotation].self, forKey: .annotations)
        contentParts = try container.decodeIfPresent([MessageContentPart].self, forKey: .contentParts) ?? []
        activityItems = try container.decodeIfPresent([AgentActivityItem].self, forKey: .activityItems) ?? []
        activityStartedAt = try container.decodeIfPresent(Date.self, forKey: .activityStartedAt)
        activityCompletedAt = try container.decodeIfPresent(Date.self, forKey: .activityCompletedAt)
    }"""
if target_decode not in models_src:
    raise SystemExit("Message decoder not found")
models_src = models_src.replace(target_decode, repl_decode, 1)

# 1g. Add encoding
target_encode = "        if !attachments.isEmpty {\n            try container.encode(attachments, forKey: .attachments)\n        }\n        try container.encodeIfPresent(annotations, forKey: .annotations)\n    }"
repl_encode = """        if !attachments.isEmpty {\n            try container.encode(attachments, forKey: .attachments)\n        }\n        if !contentParts.isEmpty {\n            try container.encode(contentParts, forKey: .contentParts)\n        }\n        if !activityItems.isEmpty {\n            try container.encode(activityItems, forKey: .activityItems)\n        }\n        try container.encodeIfPresent(activityStartedAt, forKey: .activityStartedAt)\n        try container.encodeIfPresent(activityCompletedAt, forKey: .activityCompletedAt)\n        try container.encodeIfPresent(annotations, forKey: .annotations)\n    }"""
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
print("1. ChatModels.swift patched: AgentActivityItem, MessageContentPart, contentParts, activityItems, and Hashable Chat added.")


# ===========================================================================
# 2. MessageTableView.swift: Caching & change-detection support
# ===========================================================================
table_path = root / "SwiftChat/Views/MessageTableView.swift"
table_src = table_path.read_text(encoding="utf-8")

old_change_check = "        let contentChanged = self.message.content != message.content ||\n"
new_change_check = """        let contentChanged = self.message.content != message.content ||
                            self.message.contentParts != message.contentParts ||
                            self.message.activityItems != message.activityItems ||
                            self.message.activityStartedAt != message.activityStartedAt ||
                            self.message.activityCompletedAt != message.activityCompletedAt ||
"""
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
        message.activityItems.hashValue ^
        (message.activityStartedAt?.hashValue ?? 0) ^
        (message.activityCompletedAt?.hashValue ?? 0) ^
        (message.thoughts?.hashValue ?? 0) ^
        (message.contentChunks.hashValue) ^
        (message.thinkingChunks.hashValue) ^
        isDarkMode.hashValue
    }"""
if old_cache_key not in table_src:
    raise SystemExit("MessageTableView getCacheKey not found")
table_src = table_src.replace(old_cache_key, new_cache_key, 1)
table_path.write_text(table_src, encoding="utf-8")
print("2. MessageTableView.swift patched: contentParts & activityItems cache invalidation and change detection added.")


# ===========================================================================
# 3. MessageInputView.swift: Model picker capsule & + Menu with Web Search toggle
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

# Replace attachButton and webSearchButton
old_attach_and_search = """    @ViewBuilder
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
    }

    @ViewBuilder
    private var webSearchButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.isWebSearchEnabled.toggle()
                settings.webSearchEnabled = viewModel.isWebSearchEnabled
            }
        }) {
            if viewModel.isWebSearchEnabled {
                HStack(spacing: 6) {
                    Image(systemName: "globe")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Web Search")
                        .font(.system(size: 12, weight: .semibold))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.secondary.opacity(0.15))
                .clipShape(Capsule())
                .foregroundColor(.blue)
            } else {
                Image(systemName: "globe")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.leading, 8)
    }"""

new_attach_and_model = """    @ViewBuilder
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

                Toggle(isOn: Binding(
                    get: { viewModel.isWebSearchEnabled },
                    set: { newValue in
                        viewModel.isWebSearchEnabled = newValue
                        settings.webSearchEnabled = newValue
                    }
                )) {
                    Label("Web Search", systemImage: "globe")
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

                Toggle(isOn: Binding(
                    get: { viewModel.isWebSearchEnabled },
                    set: { newValue in
                        viewModel.isWebSearchEnabled = newValue
                        settings.webSearchEnabled = newValue
                    }
                )) {
                    Label("Web Search", systemImage: "globe")
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
    }

    @ViewBuilder
    private var modelMenu: some View {
        Menu {
            ForEach(AppConfig.shared.filteredModelTypes()) { model in
                Button {
                    viewModel.changeModel(to: model)
                } label: {
                    if model.id == viewModel.currentModel.id {
                        Label(model.displayName, systemImage: "checkmark")
                    } else {
                        Text(model.displayName)
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "cpu")
                    .font(.system(size: 13, weight: .semibold))
                Text(viewModel.currentModel.displayName)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
            }
            .foregroundColor(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.05))
            .clipShape(Capsule())
        }
        .padding(.leading, 4)
    }"""

if old_attach_and_search not in input_src:
    raise SystemExit("MessageInputView attachButton and webSearchButton block not found")
input_src = input_src.replace(old_attach_and_search, new_attach_and_model, 1)

# Replace occurrences of webSearchButton in composer HStack with modelMenu
input_src = input_src.replace("webSearchButton", "modelMenu")

input_path.write_text(input_src, encoding="utf-8")
print("3. MessageInputView.swift patched: Native iOS 26 Menu, Model selector capsule, and Web Search toggle in + menu.")


# ===========================================================================
# 4. ChatView.swift: Real NavigationSplitView architecture
# ===========================================================================
chat_view_path = root / "SwiftChat/Views/ChatView.swift"
chat_view_src = chat_view_path.read_text(encoding="utf-8")

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
//

import SwiftUI

struct ChatSidebar: View {
    @ObservedObject var viewModel: SwiftChat.ChatViewModel
    @State private var searchText = ""
    @State private var chatToRename: Chat?
    @State private var renameText = ""
    @State private var chatToDelete: Chat?

    private var filteredChats: [Chat] {
        if searchText.isEmpty {
            return viewModel.chats
        }
        return viewModel.chats.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        sessionList
            .searchable(text: $searchText, placement: .sidebar, prompt: "Search chats")
            .alert("Rename Chat", isPresented: isRenamePresented) {
                TextField("Title", text: $renameText)
                Button("Cancel", role: .cancel) { chatToRename = nil }
                Button("Save") {
                    if let chat = chatToRename {
                        let trimmed = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            viewModel.updateChatTitle(chat.id, newTitle: trimmed)
                        }
                    }
                    chatToRename = nil
                }
            }
            .alert("Delete Chat", isPresented: isDeletePresented) {
                Button("Cancel", role: .cancel) { chatToDelete = nil }
                Button("Delete", role: .destructive) {
                    if let chat = chatToDelete {
                        viewModel.deleteChat(chat.id)
                    }
                    chatToDelete = nil
                }
            } message: {
                Text("Are you sure you want to delete this chat?")
            }
    }

    private var sessionList: some View {
        List(selection: Binding<Chat?>(
            get: { viewModel.currentChat },
            set: { newChat in
                if let newChat = newChat {
                    viewModel.selectChat(newChat)
                }
            }
        )) {
            ForEach(filteredChats) { chat in
                NavigationLink(value: chat) {
                    rowContent(for: chat)
                }
                .tag(chat)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    deleteButton(for: chat)
                        .tint(.red)
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
# 6. MessageView.swift: TextKit Inline Sources, Agent Activity Timeline, Polish
# ===========================================================================
msg_view_path = root / "SwiftChat/Views/MessageView.swift"
msg_view_src = msg_view_path.read_text(encoding="utf-8")

# 6a. Add imports
msg_view_src = "import AVKit\nimport WebKit\nimport UIKit\n" + msg_view_src

# 6b. Add section sheet state in MessageView
state_anchor = "    @State private var showURLFetchSheet = false\n"
state_repl = """    @State private var showURLFetchSheet = false
    @State private var selectedSectionSources: IdentifiableSources? = nil
"""
if state_anchor not in msg_view_src:
    raise SystemExit("MessageView showURLFetchSheet state anchor not found")
msg_view_src = msg_view_src.replace(state_anchor, state_repl, 1)

# 6c. Add section sources sheet presentation
sheet_anchor = """        .sheet(isPresented: $showURLFetchSheet) {
            URLFetchSheetView(urlFetches: message.urlFetches, isDarkMode: isDarkMode)
                .presentationDetents([.medium, .large])
                .presentationBackground(isDarkMode ? Color(hex: "161616") : Color(UIColor.systemGroupedBackground))
        }"""
sheet_repl = """        .sheet(isPresented: $showURLFetchSheet) {
            URLFetchSheetView(urlFetches: message.urlFetches, isDarkMode: isDarkMode)
                .presentationDetents([.medium, .large])
                .presentationBackground(isDarkMode ? Color(hex: "161616") : Color(UIColor.systemGroupedBackground))
        }
        .sheet(item: $selectedSectionSources) { item in
            SourcesSheetView(sources: item.sources, isDarkMode: isDarkMode)
                .presentationDetents([.medium, .large])
        }"""
if sheet_anchor not in msg_view_src:
    raise SystemExit("MessageView sheet anchor not found")
msg_view_src = msg_view_src.replace(sheet_anchor, sheet_repl, 1)

# 6d. Insert AgentActivityTimelineView and contentParts rendering into MessageView body
target_assistant_branch = """                            if !message.contentChunks.isEmpty {
                                ChunkedContentView(chunks: message.contentChunks, isDarkMode: isDarkMode, isStreaming: isLoading && isLastMessage)
                                    .equatable()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                LaTeXMarkdownView(content: message.content, isDarkMode: isDarkMode, isStreaming: isLoading && isLastMessage)
                                    .equatable()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }"""

repl_assistant_branch = """                            if message.role == .assistant && !message.activityItems.isEmpty {
                                AgentActivityTimelineView(
                                    message: message,
                                    isDarkMode: isDarkMode,
                                    isLoading: isLoading,
                                    isLastMessage: isLastMessage
                                )
                                .padding(.bottom, 6)
                            }

                            if !message.contentParts.isEmpty {
                                ForEach(message.contentParts) { part in
                                    switch part.kind {
                                    case .markdown:
                                        if let text = part.markdown, !text.isEmpty {
                                            if !part.sources.isEmpty {
                                                InlineSourcedMarkdownParagraph(
                                                    markdown: text,
                                                    sources: part.sources,
                                                    isDarkMode: isDarkMode,
                                                    onSourcesTap: {
                                                        selectedSectionSources = IdentifiableSources(sources: part.sources)
                                                    }
                                                )
                                            } else {
                                                LaTeXMarkdownView(content: text, isDarkMode: isDarkMode, isStreaming: false)
                                                    .equatable()
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
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

# 6e. Update action buttons check and make icons smaller & bolder
target_action_block = """                // Add action buttons for assistant messages (only when not streaming)
                if message.role == .assistant &&
                   (!message.content.isEmpty || message.thoughts != nil) &&
                   !(isLoading && isLastMessage) {
                    HStack(spacing: 16) {
                        // Sources button - only show if we have web search sources
                        if let webSearchState = message.webSearchState,
                           !webSearchState.sources.isEmpty {
                            SourcesButton(
                                sources: webSearchState.sources,
                                isDarkMode: isDarkMode
                            ) {
                                showSourcesSheet = true
                            }
                        }

                        Button {
                            showRawContentModal = true
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 16))
                                .foregroundColor(isDarkMode ? .white.opacity(0.5) : .black.opacity(0.5))
                                .frame(width: 32, height: 32)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())

                        // Regenerate button - only on the last assistant message
                        if isLastMessage && !viewModel.isLoading && messageIndex > 0 {
                            Button {
                                viewModel.regenerateMessage(at: messageIndex - 1)
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 16))
                                    .foregroundColor(isDarkMode ? .white.opacity(0.5) : .black.opacity(0.5))
                                    .frame(width: 32, height: 32)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        Spacer()
                    }
                    .padding(.vertical, 8)"""

repl_action_block = """                // Add action buttons for assistant messages (only when not streaming)
                if message.role == .assistant &&
                   (!message.content.isEmpty || !message.contentParts.isEmpty || message.thoughts != nil) &&
                   !(isLoading && isLastMessage) {
                    HStack(spacing: 10) {
                        // Sources button - only show if we have web search sources
                        if let webSearchState = message.webSearchState,
                           !webSearchState.sources.isEmpty {
                            SourcesButton(
                                sources: webSearchState.sources,
                                isDarkMode: isDarkMode
                            ) {
                                showSourcesSheet = true
                            }
                        }

                        Button {
                            showRawContentModal = true
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(isDarkMode ? .white.opacity(0.5) : .black.opacity(0.5))
                                .frame(width: 28, height: 28)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())

                        // Regenerate button - only on the last assistant message
                        if isLastMessage && !viewModel.isLoading && messageIndex > 0 {
                            Button {
                                viewModel.regenerateMessage(at: messageIndex - 1)
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(isDarkMode ? .white.opacity(0.5) : .black.opacity(0.5))
                                    .frame(width: 28, height: 28)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        Spacer()
                    }
                    .padding(.vertical, 6)"""

if target_action_block not in msg_view_src:
    raise SystemExit("MessageView action buttons block not found")
msg_view_src = msg_view_src.replace(target_action_block, repl_action_block, 1)

# 6f. Add Helper Structs & Components before SourcesButton
target_sources_button_start = "/// Button showing \"Sources\" with overlapping favicons\nprivate struct SourcesButton: View {"
components_to_insert = r"""// MARK: - Identifiable Sources Wrapper

struct IdentifiableSources: Identifiable {
    let id = UUID()
    let sources: [WebSearchSource]
}

// MARK: - Reusable Favicon Stack

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
        "https://icons.duckduckgo.com/ip3/\(domain).ico"
    }

    var body: some View {
        HStack(spacing: overlap) {
            ForEach(Array(uniqueDomains.enumerated()), id: \.offset) { index, domain in
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

// MARK: - Baseline Inline Sourced Markdown Paragraph (TextKit)

final class SourceClusterImageGenerator {
    static func makePillImage(sources: [WebSearchSource], isDarkMode: Bool) -> UIImage {
        var seen = Set<String>()
        var domains: [String] = []
        for s in sources {
            let d = extractDomain(from: s.url)
            if !seen.contains(d) {
                seen.insert(d)
                domains.append(d)
            }
            if domains.count >= 3 { break }
        }
        if domains.isEmpty { domains = ["web"] }

        let count = domains.count
        let iconSize: CGFloat = 14
        let step: CGFloat = 10
        let paddingH: CGFloat = 4
        let totalW = paddingH * 2 + iconSize + CGFloat(count - 1) * step
        let totalH: CGFloat = 18

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: totalW, height: totalH))
        return renderer.image { ctx in
            // Draw capsule pill background
            let pillRect = CGRect(x: 0, y: 0, width: totalW, height: totalH)
            let pillPath = UIBezierPath(roundedRect: pillRect, cornerRadius: 9)
            let bgColor = isDarkMode ? UIColor(white: 1.0, alpha: 0.12) : UIColor(white: 0.0, alpha: 0.06)
            bgColor.setFill()
            pillPath.fill()

            // Draw circular icons from left to right
            for (idx, _) in domains.enumerated() {
                let x = paddingH + CGFloat(idx) * step
                let y = (totalH - iconSize) / 2
                let iconRect = CGRect(x: x, y: y, width: iconSize, height: iconSize)

                let circlePath = UIBezierPath(ovalIn: iconRect)
                let circleBg = isDarkMode ? UIColor(white: 0.15, alpha: 1.0) : UIColor.white
                circleBg.setFill()
                circlePath.fill()

                let strokeColor = isDarkMode ? UIColor(white: 1.0, alpha: 0.25) : UIColor(white: 0.0, alpha: 0.15)
                strokeColor.setStroke()
                circlePath.lineWidth = 0.75
                circlePath.stroke()

                let globeConfig = UIImage.SymbolConfiguration(pointSize: 9, weight: .regular)
                if let globe = UIImage(systemName: "globe", withConfiguration: globeConfig) {
                    let tinted = globe.withTintColor(isDarkMode ? UIColor(white: 0.7, alpha: 1.0) : UIColor(white: 0.4, alpha: 1.0), renderingMode: .alwaysOriginal)
                    let globeRect = CGRect(x: x + (iconSize - 9) / 2, y: y + (iconSize - 9) / 2, width: 9, height: 9)
                    tinted.draw(in: globeRect)
                }
            }
        }
    }

    private static func extractDomain(from urlString: String) -> String {
        guard let url = URL(string: urlString), let host = url.host else { return urlString }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }
}

final class SourcedTextView: UITextView {
    override var intrinsicContentSize: CGSize {
        let width = bounds.width > 0 ? bounds.width : (UIScreen.main.bounds.width - 32)
        let fit = sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return CGSize(width: UIView.noIntrinsicMetric, height: ceil(fit.height))
    }
}

struct InlineSourcedMarkdownParagraph: UIViewRepresentable {
    let markdown: String
    let sources: [WebSearchSource]
    let isDarkMode: Bool
    let onSourcesTap: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onSourcesTap: onSourcesTap)
    }

    func makeUIView(context: Context) -> SourcedTextView {
        let textView = SourcedTextView()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        textView.setContentHuggingPriority(.required, for: .vertical)
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: SourcedTextView, context: Context) {
        context.coordinator.onSourcesTap = onSourcesTap
        let attr = buildAttributedString()
        if uiView.attributedText?.string != attr.string || uiView.tag != (isDarkMode ? 1 : 2) {
            uiView.tag = isDarkMode ? 1 : 2
            uiView.attributedText = attr
            uiView.invalidateIntrinsicContentSize()
        }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: SourcedTextView, context: Context) -> CGSize? {
        let width = proposal.width ?? (UIScreen.main.bounds.width - 32)
        let fit = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return CGSize(width: width, height: ceil(fit.height))
    }

    private func buildAttributedString() -> NSAttributedString {
        let baseFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        let textColor = isDarkMode ? UIColor.white.withAlphaComponent(0.92) : UIColor.black.withAlphaComponent(0.92)

        var mString: NSMutableAttributedString
        if let attr = try? AttributedString(markdown: markdown, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
            mString = NSMutableAttributedString(attr)
        } else {
            mString = NSMutableAttributedString(string: markdown)
        }

        let fullRange = NSRange(location: 0, length: mString.length)
        mString.enumerateAttribute(.font, in: fullRange, options: []) { value, range, _ in
            if value == nil {
                mString.addAttribute(.font, value: baseFont, range: range)
            }
        }
        mString.enumerateAttribute(.foregroundColor, in: fullRange, options: []) { value, range, _ in
            if value == nil {
                mString.addAttribute(.foregroundColor, value: textColor, range: range)
            }
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        paragraphStyle.paragraphSpacing = 6
        mString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)

        // Append space and inline NSTextAttachment
        let space = NSAttributedString(string: " ", attributes: [
            .font: baseFont,
            .foregroundColor: textColor
        ])
        mString.append(space)

        let pillImage = SourceClusterImageGenerator.makePillImage(sources: sources, isDarkMode: isDarkMode)
        let attachment = NSTextAttachment()
        attachment.image = pillImage
        attachment.bounds = CGRect(x: 0, y: baseFont.descender + 2, width: pillImage.size.width, height: pillImage.size.height)

        let attachmentString = NSMutableAttributedString(attachment: attachment)
        attachmentString.addAttribute(.link, value: URL(string: "swiftchat-section-sources://tap")!, range: NSRange(location: 0, length: attachmentString.length))
        mString.append(attachmentString)

        return mString
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var onSourcesTap: () -> Void

        init(onSourcesTap: @escaping () -> Void) {
            self.onSourcesTap = onSourcesTap
        }

        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            if URL.scheme == "swiftchat-section-sources" {
                onSourcesTap()
                return false
            }
            return true
        }

        @available(iOS 17.0, *)
        func textView(_ textView: UITextView, primaryActionFor textItem: UITextItem, defaultAction: UIAction) -> UIAction? {
            if case .link(let url) = textItem.content, url.scheme == "swiftchat-section-sources" {
                return UIAction { [weak self] _ in
                    self?.onSourcesTap()
                }
            }
            return defaultAction
        }
    }
}

// MARK: - Rich Media Component Views

struct InlineImageView: View {
    let part: MessageContentPart
    let isDarkMode: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Group {
                if let assetName = part.assetName, let uiImage = UIImage(named: assetName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else if let assetName = part.assetName, let fileURL = Bundle.main.url(forResource: assetName, withExtension: "png") ?? Bundle.main.url(forResource: assetName, withExtension: "jpg"), let uiImage = UIImage(contentsOfFile: fileURL.path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else if let urlString = part.url, let url = URL(string: urlString) {
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
                                .aspectRatio(16/9, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        case .failure:
                            fallbackView
                        @unknown default:
                            fallbackView
                        }
                    }
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
    @State private var isFailed: Bool = false
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                if let urlString = part.url, let url = URL(string: urlString) {
                    if isFailed {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 28))
                                    .foregroundColor(.orange)
                                Text(errorMessage ?? "Video stream unavailable")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Button {
                                    UIApplication.shared.open(url)
                                } label: {
                                    Label("Open Stream", systemImage: "arrow.up.right")
                                        .font(.caption.weight(.medium))
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding()
                        }
                    } else {
                        VideoPlayer(player: player)
                            .onAppear {
                                if player == nil {
                                    setupPlayer(url: url)
                                }
                            }
                            .onDisappear {
                                player?.pause()
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 16))

                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                    }
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

    private func setupPlayer(url: URL) {
        let item = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: item)
        newPlayer.automaticallyWaitsToMinimizeStalling = true
        self.player = newPlayer

        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main) { _ in
            newPlayer.seek(to: .zero)
        }

        NotificationCenter.default.addObserver(forName: .AVPlayerItemFailedToPlayToEndTime, object: item, queue: .main) { notif in
            self.isLoading = false
            self.isFailed = true
            self.errorMessage = (notif.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error)?.localizedDescription ?? "Playback error"
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if item.status == .failed {
                self.isLoading = false
                self.isFailed = true
                self.errorMessage = item.error?.localizedDescription ?? "Playback failed"
            } else {
                self.isLoading = false
            }
        }
    }
}

struct YouTubeWebView: UIViewRepresentable {
    let videoID: String
    @Binding var hasError: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(hasError: $hasError)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = .all

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.layer.cornerRadius = 16
        webView.layer.masksToBounds = true

        if let embedURL = URL(string: "https://www.youtube.com/embed/\(videoID)?playsinline=1&rel=0") {
            var request = URLRequest(url: embedURL)
            request.setValue("https://www.youtube.com/", forHTTPHeaderField: "Referer")
            webView.load(request)
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var hasError: Bool

        init(hasError: Binding<Bool>) {
            _hasError = hasError
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.hasError = true
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.hasError = true
            }
        }
    }
}

struct InlineYouTubeView: View {
    let part: MessageContentPart
    let isDarkMode: Bool
    @State private var hasError: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                if let videoID = part.youtubeVideoID ?? extractYouTubeID(from: part.url) {
                    if hasError {
                        thumbnailFallback(videoID: videoID)
                    } else {
                        YouTubeWebView(videoID: videoID, hasError: $hasError)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                } else {
                    thumbnailFallback(videoID: "M7lc1UVf-VE")
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

    private func thumbnailFallback(videoID: String) -> some View {
        Button {
            let ytURL = URL(string: "https://www.youtube.com/watch?v=\(videoID)")!
            UIApplication.shared.open(ytURL)
        } label: {
            ZStack {
                AsyncImage(url: URL(string: "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg")) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().aspectRatio(16/9, contentMode: .fit)
                    default:
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                            Color.black.opacity(0.4)
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Circle()
                    .fill(Color.red)
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: "play.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .offset(x: 2)
                    }
                    .shadow(radius: 6)
            }
        }
        .buttonStyle(.plain)
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

// MARK: - Agent Activity Timeline Components

struct AgentActivityTimelineView: View {
    let message: Message
    let isDarkMode: Bool
    let isLoading: Bool
    let isLastMessage: Bool

    @State private var isContainerExpanded: Bool = false
    @State private var expandedItemIDs: Set<String> = []
    @State private var hasAutoCollapsed: Bool = false

    private var isCompleted: Bool {
        !isLoading || !message.content.isEmpty || !message.contentParts.isEmpty || message.activityCompletedAt != nil
    }

    private var durationString: String {
        let seconds: Double
        if let start = message.activityStartedAt, let end = message.activityCompletedAt {
            seconds = max(1, end.timeIntervalSince(start))
        } else if let gen = message.generationTimeSeconds {
            seconds = gen
        } else {
            seconds = 38
        }
        let intSec = Int(seconds)
        if intSec >= 60 {
            let m = intSec / 60
            let s = intSec % 60
            return "\(m)m \(s)s"
        } else {
            return "\(intSec)s"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isContainerExpanded.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    if isCompleted {
                        Text("Worked for \(durationString)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(isDarkMode ? .white.opacity(0.6) : .black.opacity(0.6))
                        Image(systemName: isContainerExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(isDarkMode ? .white.opacity(0.4) : .black.opacity(0.4))
                    } else {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 14, height: 14)
                        Text("Working for \(durationString)...")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
                        Image(systemName: isContainerExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(isDarkMode ? .white.opacity(0.4) : .black.opacity(0.4))
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isContainerExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(message.activityItems) { item in
                        AgentActivityRowView(
                            item: item,
                            isDarkMode: isDarkMode,
                            isExpanded: expandedItemIDs.contains(item.id),
                            onToggle: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if expandedItemIDs.contains(item.id) {
                                        expandedItemIDs.remove(item.id)
                                    } else {
                                        expandedItemIDs.insert(item.id)
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.leading, 8)
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            if !isCompleted {
                isContainerExpanded = true
            } else if !hasAutoCollapsed {
                isContainerExpanded = false
                hasAutoCollapsed = true
            }
        }
        .onChange(of: isCompleted) { _, newValue in
            if newValue && !hasAutoCollapsed {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isContainerExpanded = false
                }
                hasAutoCollapsed = true
            }
        }
    }
}

struct AgentActivityRowView: View {
    let item: AgentActivityItem
    let isDarkMode: Bool
    let isExpanded: Bool
    let onToggle: () -> Void

    private var hasNestedDetails: Bool {
        !item.sources.isEmpty || item.toolName != nil || item.toolResultSummary != nil || item.toolArgumentsJSON != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(action: onToggle) {
                HStack(alignment: .center, spacing: 8) {
                    itemIcon
                        .frame(width: 18, height: 18)

                    Text(item.title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(isDarkMode ? .white.opacity(0.85) : .black.opacity(0.85))

                    if hasNestedDetails {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(isDarkMode ? .white.opacity(0.4) : .black.opacity(0.4))
                    }

                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!hasNestedDetails)

            if let summary = item.summary, !isExpanded {
                Text(summary)
                    .font(.caption)
                    .foregroundColor(isDarkMode ? .white.opacity(0.5) : .black.opacity(0.5))
                    .padding(.leading, 26)
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    if !item.sources.isEmpty {
                        ActivitySearchSourcesView(sources: item.sources, isDarkMode: isDarkMode)
                    }
                    if item.toolName != nil || item.toolResultSummary != nil || item.toolArgumentsJSON != nil {
                        ActivityToolDetailsView(item: item, isDarkMode: isDarkMode)
                    }
                }
                .padding(.leading, 26)
                .padding(.top, 2)
            }
        }
    }

    @ViewBuilder
    private var itemIcon: some View {
        switch item.kind {
        case .github:
            Image(systemName: "curlybraces.square.fill")
                .font(.system(size: 15))
                .foregroundColor(isDarkMode ? .white : .black)
        case .reasoning:
            Image(systemName: "sparkles")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.purple)
        case .webSearch:
            Image(systemName: "globe")
                .font(.system(size: 14))
                .foregroundColor(.blue)
        case .urlFetch:
            Image(systemName: "link")
                .font(.system(size: 13))
                .foregroundColor(.cyan)
        case .toolCall:
            Image(systemName: "wrench.and.screwdriver.fill")
                .font(.system(size: 13))
                .foregroundColor(.orange)
        case .status:
            Image(systemName: "info.circle")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
    }
}

struct ActivitySearchSourcesView: View {
    let sources: [WebSearchSource]
    let isDarkMode: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(sources) { source in
                Button {
                    if let url = URL(string: source.url) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack(spacing: 6) {
                        FaviconView(url: source.url, isDarkMode: isDarkMode)
                            .frame(width: 14, height: 14)
                        Text(domain(from: source.url))
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 2)
    }

    private func domain(from urlString: String) -> String {
        guard let url = URL(string: urlString), let host = url.host else { return urlString }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }
}

struct ActivityToolDetailsView: View {
    let item: AgentActivityItem
    let isDarkMode: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let tool = item.toolName {
                HStack(spacing: 4) {
                    Text("Tool:")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                    Text(tool)
                        .font(.caption.monospaced())
                        .foregroundColor(.primary)
                }
            }
            if let args = item.toolArgumentsJSON {
                Text(args)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(isDarkMode ? Color(hex: "b3b3b3") : Color(hex: "444444"))
                    .padding(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                    .cornerRadius(8)
            }
            if let result = item.toolResultSummary {
                HStack(alignment: .top, spacing: 4) {
                    Text("Result:")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                    Text(result)
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(8)
        .background(isDarkMode ? Color.white.opacity(0.04) : Color.black.opacity(0.03))
        .cornerRadius(10)
    }
}

"""

if target_sources_button_start not in msg_view_src:
    raise SystemExit("MessageView SourcesButton anchor not found")
msg_view_src = msg_view_src.replace(target_sources_button_start, components_to_insert + target_sources_button_start, 1)

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
print("6. MessageView.swift patched: TextKit inline sources, Agent Activity timeline, rich media.")

print("All SwiftChat UI upgrades applied successfully!")
