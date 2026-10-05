//
//  AgentComposerDriving.swift
//  AgentUI
//
//  State and action protocol driving the reusable agent composer.
//

import SwiftUI
import UIKit

public struct AgentModelDescriptor: Identifiable, Codable, Hashable, Equatable, Sendable {
    public let id: String
    public let displayName: String
    public let fullName: String
    public let iconName: String
    public let isMultimodal: Bool

    public init(
        id: String,
        displayName: String,
        fullName: String = "",
        iconName: String = "",
        isMultimodal: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.fullName = fullName.isEmpty ? displayName : fullName
        self.iconName = iconName
        self.isMultimodal = isMultimodal
    }
}

@MainActor
public protocol AgentComposerDriving: AnyObject, ObservableObject {
    var isLoading: Bool { get }
    var isProcessingAttachment: Bool { get }
    var attachmentError: String? { get set }
    var shouldFocusInput: Bool { get set }

    var pendingAttachments: [Attachment] { get }
    var pendingImageThumbnails: [String: String] { get }
    func removePendingAttachment(id: String)
    func addDocumentAttachment(url: URL, fileName: String)
    func addImageAttachment(data: Data, fileName: String)

    var isConversationEmpty: Bool { get }
    var isWebSearchEnabled: Bool { get set }

    var currentModel: AgentModelDescriptor { get }
    var availableModels: [AgentModelDescriptor] { get }
    func selectModel(_ model: AgentModelDescriptor)

    func sendMessage(text: String)
    func cancelGeneration()

    var isAudioRecording: Bool { get }
    var isAudioTranscribing: Bool { get }
    func toggleAudioRecording()
}

extension AgentComposerDriving {
    public var isAudioRecording: Bool { false }
    public var isAudioTranscribing: Bool { false }
    public func toggleAudioRecording() {}
}
