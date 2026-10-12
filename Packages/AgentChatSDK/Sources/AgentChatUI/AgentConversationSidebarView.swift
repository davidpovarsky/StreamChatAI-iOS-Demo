import SwiftUI
import AgentChatCore

public struct AgentConversationSidebarView: View {
    @Binding public var conversations: [Conversation]
    @Binding public var selectedConversationId: ConversationID?
    public let onNewConversation: () -> Void
    public let onDeleteConversation: (ConversationID) -> Void

    @State private var searchText = " "
    @State private var showingRenameAlert = false
    @State private var renamingConversationId: ConversationID?
    @State private var renameText = ""

    public init(
        conversations: Binding<[Conversation]>,
        selectedConversationId: Binding<ConversationID?>,
        onNewConversation: @escaping () -> Void,
        onDeleteConversation: @escaping (ConversationID) -> Void
    ) {
        self._conversations = conversations
        self._selectedConversationId = selectedConversationId
        self.onNewConversation = onNewConversation
        self.onDeleteConversation = onDeleteConversation
    }

    private var filteredConversations: [Conversation] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return conversations
        }
        return conversations.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.lastMessagePreview.localizedCaseInsensitiveContains(query)
        }
    }

    private var pinnedConversations: [Conversation] {
        filteredConversations.filter { $0.isPinned }
    }

    private var recentConversations: [Conversation] {
        filteredConversations.filter { !$0.isPinned }
    }

    public var body: some View {
        List(selection: $selectedConversationId) {
            if !pinnedConversations.isEmpty {
                Section("Pinned") {
                    ForEach(pinnedConversations) { conv in
                        conversationRow(for: conv)
                    }
                }
            }

            Section("Recent Chats") {
                ForEach(recentConversations) { conv in
                    conversationRow(for: conv)
                }
            }
        }
        .listStyle(.sidebar)
        .searchable(text: $searchText, prompt: "Search chats...")
        .navigationTitle("Conversations")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: onNewConversation) {
                    Image(systemName: "square.and.pencil")
                }
                .accessibilityLabel("New conversation")
            }
        }
        .alert("Rename Chat", isPresented: $showingRenameAlert) {
            TextField("Chat Title", text: $renameText)
            Button("Save") {
                if let id = renamingConversationId, let idx = conversations.firstIndex(where: { $0.id == id }) {
                    conversations[idx].title = renameText
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    @ViewBuilder
    private func conversationRow(for conv: Conversation) -> some View {
        NavigationLink(value: conv.id) {
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(conv.title)
                        .font(.system(size: 14, weight: conv.id == selectedConversationId ? .semibold : .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Spacer()
                    if conv.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }

                Text(conv.lastMessagePreview)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.vertical, 2)
        }
        .contextMenu {
            Button {
                if let idx = conversations.firstIndex(where: { $0.id == conv.id }) {
                    conversations[idx].isPinned.toggle()
                }
            } label: {
                Label(conv.isPinned ? "Unpin" : "Pin", systemImage: conv.isPinned ? "pin.slash" : "pin")
            }

            Button {
                renamingConversationId = conv.id
                renameText = conv.title
                showingRenameAlert = true
            } label: {
                Label("Rename", systemImage: "pencil")
            }

            Button(role: .destructive) {
                onDeleteConversation(conv.id)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDeleteConversation(conv.id)
            } label: {
                Label("Delete", systemImage: "trash")
            }

            Button {
                if let idx = conversations.firstIndex(where: { $0.id == conv.id }) {
                    conversations[idx].isPinned.toggle()
                }
            } label: {
                Label(conv.isPinned ? "Unpin" : "Pin", systemImage: "pin")
            }
            .tint(.orange)
        }
    }
}
