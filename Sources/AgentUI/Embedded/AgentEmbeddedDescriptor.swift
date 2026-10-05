// Sources/AgentUI/Embedded/AgentEmbeddedDescriptor.swift
import Foundation

public enum AgentEmbeddedSizePreset: String, Sendable, Equatable, Codable {
    case automatic
    case compact
    case regular
    case large

    public var defaultHeight: Double {
        switch self {
        case .automatic: return 220
        case .compact: return 140
        case .regular: return 240
        case .large: return 380
        }
    }
}

public struct AgentEmbeddedSizingPreference: Sendable, Equatable, Codable {
    public let preset: AgentEmbeddedSizePreset
    public let idealHeight: Double?
    public let maxHeight: Double?

    public init(
        preset: AgentEmbeddedSizePreset = .automatic,
        idealHeight: Double? = nil,
        maxHeight: Double? = nil
    ) {
        self.preset = preset
        self.idealHeight = idealHeight
        self.maxHeight = maxHeight
    }

    public static let `default` = AgentEmbeddedSizingPreference(preset: .automatic)
}

public enum AgentExpansionMode: String, Sendable, Equatable, Codable {
    case sheet
    case fullScreen
    case window
}

public struct AgentExpansionDescriptor: Sendable, Equatable, Codable {
    public let allowedModes: [AgentExpansionMode]
    public let preferredMode: AgentExpansionMode
    public let supportsInlineCollapse: Bool

    public init(
        allowedModes: [AgentExpansionMode] = [.sheet, .fullScreen],
        preferredMode: AgentExpansionMode = .sheet,
        supportsInlineCollapse: Bool = true
    ) {
        self.allowedModes = allowedModes
        self.preferredMode = preferredMode
        self.supportsInlineCollapse = supportsInlineCollapse
    }

    public static let `default` = AgentExpansionDescriptor()
}

public struct AgentEmbeddedPresentationDescriptor: Identifiable, Sendable, Equatable {
    public let id: AgentEmbeddedID
    public let handlerID: String
    public let title: String?
    public let sizing: AgentEmbeddedSizingPreference
    public let expansion: AgentExpansionDescriptor
    public let payload: AgentEmbeddedPayload

    public init(
        id: AgentEmbeddedID = AgentEmbeddedID(),
        handlerID: String,
        title: String? = nil,
        sizing: AgentEmbeddedSizingPreference = .default,
        expansion: AgentExpansionDescriptor = .default,
        payload: AgentEmbeddedPayload
    ) {
        self.id = id
        self.handlerID = handlerID
        self.title = title
        self.sizing = sizing
        self.expansion = expansion
        self.payload = payload
    }
}
