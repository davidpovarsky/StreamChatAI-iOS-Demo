import Foundation

public struct AgentChatAppearanceConfiguration: Sendable, Equatable {
    public var assistantName: String
    public var assistantAvatarSystemName: String
    public var userAvatarSystemName: String
    public var adaptiveMaxWidth: Double
    public var showModelSelector: Bool
    public var showAddPopover: Bool
    public var userBubbleCornerRadius: Double
    public var showDividers: Bool

    public init(
        assistantName: String = "Assistant",
        assistantAvatarSystemName: String = "sparkle",
        userAvatarSystemName: String = "person.fill",
        adaptiveMaxWidth: Double = 760.0,
        showModelSelector: Bool = true,
        showAddPopover: Bool = true,
        userBubbleCornerRadius: Double = 18.0,
        showDividers: Bool = false
    ) {
        self.assistantName = assistantName
        self.assistantAvatarSystemName = assistantAvatarSystemName
        self.userAvatarSystemName = userAvatarSystemName
        self.adaptiveMaxWidth = adaptiveMaxWidth
        self.showModelSelector = showModelSelector
        self.showAddPopover = showAddPopover
        self.userBubbleCornerRadius = userBubbleCornerRadius
        self.showDividers = showDividers
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

public struct AgentChatCapabilitiesConfiguration: Sendable, Equatable {
    public var supportsMarkdown: Bool
    public var supportsCodeHighlighting: Bool
    public var supportsLaTeXMath: Bool
    public var supportsRemoteImages: Bool
    public var supportsSVG: Bool
    public var supportsCitations: Bool
    public var supportsToolExecution: Bool
    public var supportsVoice: Bool
    public var supportsEmoji: Bool
    public var supportsAttachments: Bool

    public init(
        supportsMarkdown: Bool = true,
        supportsCodeHighlighting: Bool = true,
        supportsLaTeXMath: Bool = true,
        supportsRemoteImages: Bool = true,
        supportsSVG: Bool = true,
        supportsCitations: Bool = true,
        supportsToolExecution: Bool = true,
        supportsVoice: Bool = true,
        supportsEmoji: Bool = true,
        supportsAttachments: Bool = true
    ) {
        self.supportsMarkdown = supportsMarkdown
        self.supportsCodeHighlighting = supportsCodeHighlighting
        self.supportsLaTeXMath = supportsLaTeXMath
        self.supportsRemoteImages = supportsRemoteImages
        self.supportsSVG = supportsSVG
        self.supportsCitations = supportsCitations
        self.supportsToolExecution = supportsToolExecution
        self.supportsVoice = supportsVoice
        self.supportsEmoji = supportsEmoji
        self.supportsAttachments = supportsAttachments
    }
}

public struct AgentChatRenderingConfiguration: Sendable, Equatable {
    public var codeLineWrapping: Bool
    public var enableAnimations: Bool
    public var respectReduceMotion: Bool

    public init(
        codeLineWrapping: Bool = true,
        enableAnimations: Bool = true,
        respectReduceMotion: Bool = true
    ) {
        self.codeLineWrapping = codeLineWrapping
        self.enableAnimations = enableAnimations
        self.respectReduceMotion = respectReduceMotion
    }
}

public struct AgentChatConfiguration: Sendable, Equatable {
    public var appearance: AgentChatAppearanceConfiguration
    public var features: AgentChatFeaturesConfiguration
    public var capabilities: AgentChatCapabilitiesConfiguration
    public var rendering: AgentChatRenderingConfiguration
    public var availableModels: [ModelType]
    public var defaultModel: ModelType

    public init(
        appearance: AgentChatAppearanceConfiguration = AgentChatAppearanceConfiguration(),
        features: AgentChatFeaturesConfiguration = AgentChatFeaturesConfiguration(),
        capabilities: AgentChatCapabilitiesConfiguration = AgentChatCapabilitiesConfiguration(),
        rendering: AgentChatRenderingConfiguration = AgentChatRenderingConfiguration(),
        availableModels: [ModelType] = [.gpt4o, .gpt4oMini, .o1, .o3Mini],
        defaultModel: ModelType = .gpt4o
    ) {
        self.appearance = appearance
        self.features = features
        self.capabilities = capabilities
        self.rendering = rendering
        self.availableModels = availableModels
        self.defaultModel = defaultModel
    }
}
