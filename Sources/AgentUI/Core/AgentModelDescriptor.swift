// Sources/AgentUI/Core/AgentModelDescriptor.swift
import Foundation

public struct AgentModelDescriptor: Identifiable, Sendable, Equatable, Hashable {
    public let id: String
    public let displayName: String
    public let providerName: String?
    public let iconSystemName: String
    public let supportsWebSearch: Bool
    public let supportsVision: Bool
    public let supportsTools: Bool
    public let contextWindowTokens: Int?

    public init(
        id: String,
        displayName: String,
        providerName: String? = nil,
        iconSystemName: String = "cpu",
        supportsWebSearch: Bool = true,
        supportsVision: Bool = true,
        supportsTools: Bool = true,
        contextWindowTokens: Int? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.providerName = providerName
        self.iconSystemName = iconSystemName
        self.supportsWebSearch = supportsWebSearch
        self.supportsVision = supportsVision
        self.supportsTools = supportsTools
        self.contextWindowTokens = contextWindowTokens
    }

    public static let `default` = AgentModelDescriptor(
        id: "default-model",
        displayName: "Agent Default",
        iconSystemName: "sparkles"
    )
}
