#if canImport(AgentChatActivity)
@_exported import AgentChatActivity
#endif
#if canImport(AgentChatCore)
@_exported import AgentChatCore
#endif
#if canImport(AgentChatIntegrations)
@_exported import AgentChatIntegrations
#endif
#if canImport(AgentChatMedia)
@_exported import AgentChatMedia
#endif
#if canImport(AgentChatRendering)
@_exported import AgentChatRendering
#endif
#if canImport(AgentChatRichResults)
@_exported import AgentChatRichResults
#endif
#if canImport(AgentChatUI)
@_exported import AgentChatUI
#endif
#if canImport(AgentChatVoice)
@_exported import AgentChatVoice
#endif

public enum AgentChatSDKInfo {
    public static let version = "1.0.0"
    public static let identifier = "com.davidpovarsky.AgentChatSDK"
}
