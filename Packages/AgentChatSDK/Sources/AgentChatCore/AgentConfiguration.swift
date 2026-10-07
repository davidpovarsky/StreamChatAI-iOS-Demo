import Foundation

public struct AgentChatAppearanceConfiguration: Sendable, Equatable {
    public var assistantName: String
    public var assistantAvatarSystemName: String
    public var userAvatarSystemName: String
    public var adaptiveMaxWidth: Double
    public var showModelSelector: Bool
    public var showAddPopover: Bool

    public init(
        assistantName: String = "Assistant",
        assistantAvatarSystemName: String = "sparkle",
        userAvatarSystemName: String = "person.fill",
        adaptiveMaxWidth: Double = 760.0,
        showModelSelector: Bool = true,
        showAddPopover: Bool = true
    ) {
        self.assistantName = assistantName
        self.assistantAvatarSystemName = assistantAvatarSystemName
        self.userAvatarSystemName = userAvatarSystemName
        self.adaptiveMaxWidth = adaptiveMaxWidth
        self.showModelSelector = showModelSelector
        self.showAddPopover = showAddPopover
    }
}

public struct AgentChatFeaturesConfiguration: Sendable, Equatable {
    public var enableWebSearch: Bool
    public var enableVoiceMode: Bool
    public var enableEmojiPicker: Bool
    public var enableToolExecutionDisclosure: Bool
    public var enableActivityTimeline: Bool
    public var enableInlineSources: Bool
    public var enableRichMedia: Bool

    public init(
        enableWebSearch: Bool = true,
        enableVoiceMode: Bool = true,
        enableEmojiPicker: Bool = true,
        enableToolExecutionDisclosure: Bool = true,
        enableActivityTimeline: Bool = true,
        enableInlineSources: Bool = true,
        enableRichMedia: Bool = true
    ) {
        self.enableWebSearch = enableWebSearch
        self.enableVoiceMode = enableVoiceMode
        self.enableEmojiPicker = enableEmojiPicker
        self.enableToolExecutionDisclosure = enableToolExecutionDisclosure
        self.enableActivityTimeline = enableActivityTimeline
        self.enableInlineSources = enableInlineSources
        self.enableRichMedia = enableRichMedia
    }
}

public struct AgentChatConfiguration: Sendable, Equatable {
    public var appearance: AgentChatAppearanceConfiguration
    public var features: AgentChatFeaturesConfiguration
    public var availableModels: [ModelType]
    public var defaultModel: ModelType

    public init(
        appearance: AgentChatAppearanceConfiguration = AgentChatAppearanceConfiguration(),
        features: AgentChatFeaturesConfiguration = AgentChatFeaturesConfiguration(),
        availableModels: [ModelType] = [.gpt4o, .gpt4oMini, .o1, .o3Mini],
        defaultModel: ModelType = .gpt4o
    ) {
        self.appearance = appearance
        self.features = features
        self.availableModels = availableModels
        self.defaultModel = defaultModel
    }
}
