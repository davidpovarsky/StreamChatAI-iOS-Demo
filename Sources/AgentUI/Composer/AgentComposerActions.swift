// Sources/AgentUI/Composer/AgentComposerActions.swift
#if canImport(SwiftUI)
import SwiftUI

public struct AgentComposerActions: Sendable {
    public var onSend: @Sendable (String, [AgentAttachment]) -> Void
    public var onStop: @Sendable () -> Void
    public var onSelectModel: @Sendable (AgentModelDescriptor) -> Void
    public var onToggleWebSearch: @Sendable () -> Void

    public init(
        onSend: @escaping @Sendable (String, [AgentAttachment]) -> Void = { _, _ in },
        onStop: @escaping @Sendable () -> Void = {},
        onSelectModel: @escaping @Sendable (AgentModelDescriptor) -> Void = { _ in },
        onToggleWebSearch: @escaping @Sendable () -> Void = {}
    ) {
        self.onSend = onSend
        self.onStop = onStop
        self.onSelectModel = onSelectModel
        self.onToggleWebSearch = onToggleWebSearch
    }
}
#endif
