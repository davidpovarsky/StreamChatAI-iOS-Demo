//
//  AgentRuntimeAdapter.swift
//  AgentUI
//
//  Runtime-neutral host adapter protocols decoupling AgentUI presentation from specific LLM providers.
//

import Foundation
import Combine
import SwiftUI
import UIKit

@MainActor
public protocol AgentChatRuntimeControlling: AnyObject, ObservableObject {
    var sessions: [AgentChatSessionDescriptor] { get }
    var currentSession: AgentChatSessionDescriptor? { get }
    var isLoading: Bool { get }
    var isThinking: Bool { get }
    var thinkingSummary: String { get }

    // Session Management
    func selectSession(_ session: AgentChatSessionDescriptor)
    func createNewSession()
    func deleteSession(id: String)
    func renameSession(id: String, newTitle: String)

    // Message Actions
    func sendMessage(text: String)
    func cancelGeneration()
    func regenerateMessage(at index: Int)
}

/// Standalone in-memory runtime controller for sample hosts, tests, and previewing without LLM dependencies.
@MainActor
public final class MockAgentRuntimeController: ObservableObject, AgentChatRuntimeControlling, AgentComposerDriving {
    @Published public var sessions: [AgentChatSessionDescriptor] = []
    @Published public var currentSession: AgentChatSessionDescriptor?
    @Published public var isLoading: Bool = false
    @Published public var isThinking: Bool = false
    @Published public var thinkingSummary: String = ""

    // Composer driving
    @Published public var messageText: String = ""
    @Published public var shouldFocusInput: Bool = false
    @Published public var isProcessingAttachment: Bool = false
    @Published public var attachmentError: String? = nil
    @Published public var pendingAttachments: [Attachment] = []
    @Published public var pendingImageThumbnails: [String: String] = [:]
    @Published public var isWebSearchEnabled: Bool = false
    @Published public var currentModel: AgentModelDescriptor
    public var currentModelDescriptor: AgentModelDescriptor { currentModel }
    @Published public var availableModels: [AgentModelDescriptor]

    public var isConversationEmpty: Bool {
        sessions.isEmpty
    }

    public init(
        sessions: [AgentChatSessionDescriptor] = [
            AgentChatSessionDescriptor(id: "demo-1", title: "Welcome to AgentUI", createdAt: Date(), isBlankChat: false)
        ],
        models: [AgentModelDescriptor] = [
            AgentModelDescriptor(id: "gpt-4.1", displayName: "GPT-4.1", isMultimodal: true),
            AgentModelDescriptor(id: "o4-mini", displayName: "o4-mini", isMultimodal: false)
        ]
    ) {
        self.sessions = sessions
        self.currentSession = sessions.first
        self.availableModels = models
        self.currentModel = models.first ?? AgentModelDescriptor(id: "default", displayName: "Default")
    }

    public func selectSession(_ session: AgentChatSessionDescriptor) {
        currentSession = session
    }

    public func createNewSession() {
        let newSession = AgentChatSessionDescriptor(
            id: UUID().uuidString.lowercased(),
            title: "New Chat",
            createdAt: Date(),
            isBlankChat: true
        )
        sessions.insert(newSession, at: 0)
        currentSession = newSession
    }

    public func deleteSession(id: String) {
        sessions.removeAll { $0.id == id }
        if currentSession?.id == id {
            currentSession = sessions.first
        }
    }

    public func renameSession(id: String, newTitle: String) {
        if let idx = sessions.firstIndex(where: { $0.id == id }) {
            sessions[idx].title = newTitle
            if currentSession?.id == id {
                currentSession?.title = newTitle
            }
        }
    }

    public func sendMessage(text: String) {
        messageText = ""
        pendingAttachments.removeAll()
        pendingImageThumbnails.removeAll()
    }

    public func cancelGeneration() {
        isLoading = false
        isThinking = false
    }

    public func regenerateMessage(at index: Int) {}

    public func removePendingAttachment(id: String) {
        pendingAttachments.removeAll { $0.id == id }
        pendingImageThumbnails.removeValue(forKey: id)
    }

    public func addDocumentAttachment(url: URL, fileName: String) {
        let attachment = Attachment(type: .document, fileName: fileName)
        pendingAttachments.append(attachment)
    }

    public func addImageAttachment(data: Data, fileName: String) {
        let id = UUID().uuidString.lowercased()
        let base64 = data.base64EncodedString()
        let attachment = Attachment(id: id, type: .image, fileName: fileName, base64: base64)
        pendingAttachments.append(attachment)
        pendingImageThumbnails[id] = base64
    }

    public func selectModel(_ model: AgentModelDescriptor) {
        currentModel = model
    }
}
