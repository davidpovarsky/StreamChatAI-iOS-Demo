import Foundation

public struct AgentChatAppearance: Sendable, Equatable {
    public var assistantAvatarSystemName: String
    public var userBubbleCornerRadius: Double
    public var cardCornerRadius: Double
    public var adaptiveMaxWidth: Double
    public var showDividers: Bool

    public init(
        assistantAvatarSystemName: String = "sparkles",
        userBubbleCornerRadius: Double = 18.0,
        cardCornerRadius: Double = 14.0,
        adaptiveMaxWidth: Double = 768.0,
        showDividers: Bool = true
    ) {
        self.assistantAvatarSystemName = assistantAvatarSystemName
        self.userBubbleCornerRadius = userBubbleCornerRadius
        self.cardCornerRadius = cardCornerRadius
        self.adaptiveMaxWidth = adaptiveMaxWidth
        self.showDividers = showDividers
    }
}

public struct AgentChatCapabilities: Sendable, Equatable {
    public var supportsMarkdown: Bool
    public var supportsCodeHighlighting: Bool
    public var supportsLaTeXMath: Bool
    public var supportsRemoteImages: Bool
    public var supportsSVG: Bool
    public var supportsCitations: Bool
    public var supportsToolExecution: Bool
    public var supportsRichResults: Bool
    public var supportsVoice: Bool
    public var supportsAttachments: Bool
    public var supportsEmoji: Bool

    public init(
        supportsMarkdown: Bool = true,
        supportsCodeHighlighting: Bool = true,
        supportsLaTeXMath: Bool = true,
        supportsRemoteImages: Bool = true,
        supportsSVG: Bool = true,
        supportsCitations: Bool = true,
        supportsToolExecution: Bool = true,
        supportsRichResults: Bool = true,
        supportsVoice: Bool = true,
        supportsAttachments: Bool = true,
        supportsEmoji: Bool = true
    ) {
        self.supportsMarkdown = supportsMarkdown
        self.supportsCodeHighlighting = supportsCodeHighlighting
        self.supportsLaTeXMath = supportsLaTeXMath
        self.supportsRemoteImages = supportsRemoteImages
        self.supportsSVG = supportsSVG
        self.supportsCitations = supportsCitations
        self.supportsToolExecution = supportsToolExecution
        self.supportsRichResults = supportsRichResults
        self.supportsVoice = supportsVoice
        self.supportsAttachments = supportsAttachments
        self.supportsEmoji = supportsEmoji
    }
}

public struct AgentModelItem: Identifiable, Sendable, Equatable, Hashable {
    public let id: String
    public var displayName: String
    public var description: String?

    public init(id: String, displayName: String, description: String? = nil) {
        self.id = id
        self.displayName = displayName
        self.description = description
    }
}

public struct AgentComposerConfiguration: Sendable, Equatable {
    public var placeholder: String
    public var maxLines: Int
    public var allowAttachments: Bool
    public var allowVoiceInput: Bool
    public var allowEmojiPicker: Bool
    public var availableModels: [AgentModelItem]
    public var selectedModel: AgentModelItem?

    public init(
        placeholder: String = "Ask anything or type a prompt...",
        maxLines: Int = 6,
        allowAttachments: Bool = true,
        allowVoiceInput: Bool = true,
        allowEmojiPicker: Bool = true,
        availableModels: [AgentModelItem] = [
            AgentModelItem(id: "gpt-4o", displayName: "GPT-4o"),
            AgentModelItem(id: "claude-3-7-sonnet", displayName: "Claude 3.7 Sonnet"),
            AgentModelItem(id: "gemini-2-5-pro", displayName: "Gemini 2.5 Pro")
        ],
        selectedModel: AgentModelItem? = nil
    ) {
        self.placeholder = placeholder
        self.maxLines = maxLines
        self.allowAttachments = allowAttachments
        self.allowVoiceInput = allowVoiceInput
        self.allowEmojiPicker = allowEmojiPicker
        self.availableModels = availableModels
        self.selectedModel = selectedModel ?? availableModels.first
    }
}

public struct AgentRenderingConfiguration: Sendable, Equatable {
    public var syntaxTheme: String
    public var codeLineWrapping: Bool
    public var enableAnimations: Bool
    public var respectReduceMotion: Bool

    public init(
        syntaxTheme: String = "atom-one-dark",
        codeLineWrapping: Bool = false,
        enableAnimations: Bool = true,
        respectReduceMotion: Bool = true
    ) {
        self.syntaxTheme = syntaxTheme
        self.codeLineWrapping = codeLineWrapping
        self.enableAnimations = enableAnimations
        self.respectReduceMotion = respectReduceMotion
    }
}

public struct AgentVoiceConfiguration: Sendable, Equatable {
    public var autoStartListening: Bool
    public var silenceDetectionDuration: TimeInterval
    public var speechThreshold: Float

    public init(
        autoStartListening: Bool = false,
        silenceDetectionDuration: TimeInterval = 1.5,
        speechThreshold: Float = 0.5
    ) {
        self.autoStartListening = autoStartListening
        self.silenceDetectionDuration = silenceDetectionDuration
        self.speechThreshold = speechThreshold
    }
}

public struct AgentChatConfiguration: Sendable, Equatable {
    public var appearance: AgentChatAppearance
    public var capabilities: AgentChatCapabilities
    public var composer: AgentComposerConfiguration
    public var rendering: AgentRenderingConfiguration
    public var voice: AgentVoiceConfiguration

    public init(
        appearance: AgentChatAppearance = AgentChatAppearance(),
        capabilities: AgentChatCapabilities = AgentChatCapabilities(),
        composer: AgentComposerConfiguration = AgentComposerConfiguration(),
        rendering: AgentRenderingConfiguration = AgentRenderingConfiguration(),
        voice: AgentVoiceConfiguration = AgentVoiceConfiguration()
    ) {
        self.appearance = appearance
        self.capabilities = capabilities
        self.composer = composer
        self.rendering = rendering
        self.voice = voice
    }
}
