// Sources/AgentUI/Session/AgentDraft.swift
import Foundation

public struct AgentDraft: Sendable, Equatable {
    public var text: String
    public var attachments: [AgentAttachment]
    public var isSubmitting: Bool

    public init(
        text: String = "",
        attachments: [AgentAttachment] = [],
        isSubmitting: Bool = false
    ) {
        self.text = text
        self.attachments = attachments
        self.isSubmitting = isSubmitting
    }

    public var isEmpty: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && attachments.isEmpty
    }

    public mutating func clear() {
        text = ""
        attachments = []
        isSubmitting = false
    }
}
