//
//  AgentChatSidebarView.swift
//  AgentUI
//
//  Authoritative session list matching ManifoldKit Advanced SessionListView architecture.
//

import SwiftUI

public struct AgentChatSessionDescriptor: Identifiable, Hashable, Sendable {
    public let id: String
    public var title: String
    public let createdAt: Date
    public var isBlankChat: Bool

    public init(id: String, title: String, createdAt: Date = Date(), isBlankChat: Bool = false) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.isBlankChat = isBlankChat
    }
}

public struct AgentChatSidebarView: View {
    public let sessions: [AgentChatSessionDescriptor]
    public let currentSessionId: String?
    public let onSelectSession: (AgentChatSessionDescriptor) -> Void
    public let onDeleteSession: (String) -> Void
    public let onRenameSession: (String, String) -> Void
    public let onCreateNewSession: (() -> Void)?
    public let searchFilter: ((AgentChatSessionDescriptor, String) -> Bool)?

    @State private var sessionToDelete: AgentChatSessionDescriptor?
    @State private var sessionToRename: AgentChatSessionDescriptor?
    @State private var renameText: String = ""
    @State private var searchText: String = ""

    public init(
        sessions: [AgentChatSessionDescriptor],
        currentSessionId: String?,
        onSelectSession: @escaping (AgentChatSessionDescriptor) -> Void,
        onDeleteSession: @escaping (String) -> Void,
        onRenameSession: @escaping (String, String) -> Void,
        onCreateNewSession: (() -> Void)? = nil,
        searchFilter: ((AgentChatSessionDescriptor, String) -> Bool)? = nil
    ) {
        self.sessions = sessions
        self.currentSessionId = currentSessionId
        self.onSelectSession = onSelectSession
        self.onDeleteSession = onDeleteSession
        self.onRenameSession = onRenameSession
        self.onCreateNewSession = onCreateNewSession
        self.searchFilter = searchFilter
    }

    private var filteredSessions: [AgentChatSessionDescriptor] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return sessions }
        return sessions.filter { session in
            if let customFilter = searchFilter {
                return customFilter(session, trimmed)
            }
            return session.title.lowercased().contains(trimmed)
        }
    }

    private var selectionBinding: Binding<AgentChatSessionDescriptor?> {
        Binding(
            get: { sessions.first { $0.id == currentSessionId } },
            set: { newSession in
                if let newSession = newSession {
                    onSelectSession(newSession)
                }
            }
        )
    }

    private var isRenamePresented: Binding<Bool> {
        Binding(
            get: { sessionToRename != nil },
            set: { if !$0 { sessionToRename = nil } }
        )
    }

    private var isDeletePresented: Binding<Bool> {
        Binding(
            get: { sessionToDelete != nil },
            set: { if !$0 { sessionToDelete = nil } }
        )
    }

    public var body: some View {
        mainContent
            .searchable(text: $searchText, prompt: "Search chats")
            .alert("Rename Chat", isPresented: isRenamePresented) {
                TextField("Chat title", text: $renameText)
                Button("Cancel", role: .cancel) { sessionToRename = nil }
                Button("Rename") {
                    if let session = sessionToRename {
                        onRenameSession(session.id, renameText)
                    }
                    sessionToRename = nil
                }
            }
            .alert("Delete Chat?", isPresented: isDeletePresented, presenting: sessionToDelete) { session in
                Button("Delete", role: .destructive) {
                    onDeleteSession(session.id)
                    if sessions.count <= 1 {
                        onCreateNewSession?()
                    }
                    sessionToDelete = nil
                }
                Button("Cancel", role: .cancel) { sessionToDelete = nil }
            } message: { session in
                Text("This will permanently delete \"\(session.title)\" and all its messages.")
            }
            .frame(minWidth: AgentTheme.Dimensions.sidebarWidth)
    }

    @ViewBuilder
    private var mainContent: some View {
        if sessions.isEmpty && searchText.isEmpty {
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
        } else if filteredSessions.isEmpty && !searchText.isEmpty {
            if #available(iOS 17.0, *) {
                ContentUnavailableView.search(text: searchText)
            } else {
                Text("No results for \"\(searchText)\"")
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
                ForEach(filteredSessions) { session in
                    rowContent(for: session)
                        .tag(session)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            deleteButton(for: session)
                        }
                        .swipeActions(edge: .leading) {
                            renameButton(for: session)
                                .tint(.blue)
                        }
                        .contextMenu {
                            renameButton(for: session)
                            deleteButton(for: session)
                        }
                }
            }
        }
        .accessibilityIdentifier("session-list")
    }

    @ViewBuilder
    private func rowContent(for session: AgentChatSessionDescriptor) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(session.title)
                    .font(.headline)
                    .lineLimit(1)
                if session.isBlankChat {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 6, height: 6)
                }
            }

            Text(session.createdAt, style: .relative)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(session.title), created \(session.createdAt, style: .relative) ago")
        .accessibilityIdentifier("session-row")
    }

    private func deleteButton(for session: AgentChatSessionDescriptor) -> some View {
        Button(role: .destructive) {
            sessionToDelete = session
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    private func renameButton(for session: AgentChatSessionDescriptor) -> some View {
        Button {
            sessionToRename = session
            renameText = session.title
        } label: {
            Label("Rename", systemImage: "pencil")
        }
    }
}
