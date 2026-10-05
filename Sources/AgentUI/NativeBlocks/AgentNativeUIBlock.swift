// Sources/AgentUI/NativeBlocks/AgentNativeUIBlock.swift
import Foundation

public enum AgentNativeBlockAction: Sendable, Equatable, Hashable {
    case openURL(URL)
    case copy(String)
    case hostAction(actionID: String, payload: String?)
    case routeAction(route: String)
}

public struct AgentNativeBlockActionItem: Identifiable, Sendable, Equatable, Hashable {
    public let id: String
    public let title: String
    public let iconSystemName: String?
    public let action: AgentNativeBlockAction

    public init(id: String = UUID().uuidString, title: String, iconSystemName: String? = nil, action: AgentNativeBlockAction) {
        self.id = id
        self.title = title
        self.iconSystemName = iconSystemName
        self.action = action
    }
}

public enum AgentNativeUIBlockFamily: String, Sendable, Equatable, Codable {
    case text
    case markdown
    case card
    case searchResults
    case source
    case summary
    case calculation
    case keyValueList
    case error
}

public struct AgentNativeUIBlock: Identifiable, Sendable, Equatable {
    public let id: String
    public let family: AgentNativeUIBlockFamily
    public let title: String?
    public let subtitle: String?
    public let body: String?
    public let footnote: String?
    public let systemImage: String?
    public let imageURL: URL?
    public let url: URL?
    public let keyValues: [(key: String, value: String)]
    public let actions: [AgentNativeBlockActionItem]
    public let children: [AgentNativeUIBlock]

    public init(
        id: String = UUID().uuidString,
        family: AgentNativeUIBlockFamily,
        title: String? = nil,
        subtitle: String? = nil,
        body: String? = nil,
        footnote: String? = nil,
        systemImage: String? = nil,
        imageURL: URL? = nil,
        url: URL? = nil,
        keyValues: [(key: String, value: String)] = [],
        actions: [AgentNativeBlockActionItem] = [],
        children: [AgentNativeUIBlock] = []
    ) {
        self.id = id
        self.family = family
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.footnote = footnote
        self.systemImage = systemImage
        self.imageURL = imageURL
        self.url = url
        self.keyValues = keyValues
        self.actions = actions
        self.children = children
    }

    public static func == (lhs: AgentNativeUIBlock, rhs: AgentNativeUIBlock) -> Bool {
        lhs.id == rhs.id &&
        lhs.family == rhs.family &&
        lhs.title == rhs.title &&
        lhs.subtitle == rhs.subtitle &&
        lhs.body == rhs.body &&
        lhs.footnote == rhs.footnote &&
        lhs.systemImage == rhs.systemImage &&
        lhs.imageURL == rhs.imageURL &&
        lhs.url == rhs.url &&
        lhs.actions == rhs.actions &&
        lhs.children == rhs.children &&
        lhs.keyValues.map { "\($0.key)=\($0.value)" } == rhs.keyValues.map { "\($0.key)=\($0.value)" }
    }
}
