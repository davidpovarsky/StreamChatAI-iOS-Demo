//
//  ChatSidebar.swift
//  SwiftChat
//
//  Created on 03/25/26.
//  Copyright © 2026 Sacha Servan-Schreiber. All rights reserved.
//

import SwiftUI

/// Sidebar session list matching ManifoldKit Advanced SessionListView architecture
struct ChatSidebar: View {
    @ObservedObject var viewModel: ChatViewModel

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
                Text("This will permanently delete \"\(chat.title)\" and all its messages.")
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
        .accessibilityLabel("\(chat.title), created \(chat.createdAt, style: .relative) ago")
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
