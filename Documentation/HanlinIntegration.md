# Future Hanlin Integration Handoff Note

> **Note on Scope**: The Hanlin AI repository is strictly frozen and was not modified during this hardening pass. This document provides the integration specifications and contract details for a future Hanlin integration pass.

## 1. Branch & Package Revision
- **Hardening Branch**: `agent/agentui-sdk-hardening-v2`
- **Repository**: `https://github.com/davidpovarsky/StreamChatAI-iOS-Demo.git`
- **Recommended SPM Dependency**: Pin to exact git commit SHA of `agent/agentui-sdk-hardening-v2`.

## 2. Public APIs for Host Runtime Adapter
Host applications integrate via `AgentUIRuntimeAdapter`:
```swift
@MainActor
public protocol AgentUIRuntimeAdapter: Sendable {
    func send(request: AgentSendRequest) async throws -> AsyncThrowingStream<AgentUIEvent, Error>
    func cancel(requestID: String) async
}
```

The adapter maps runtime events to typed `AgentUIEvent`:
- `.requestStarted(id:)`
- `.textDelta(id:text:)`
- `.contentBlockAdded(id:block:)`
- `.contentBlockUpdated(id:block:)`
- `.activityStarted(id:sessionID:kind:title:summary:)`
- `.activityUpdated(id:sessionID:status:summary:)`
- `.activityEnded(id:sessionID:status:)`
- `.sourcesDiscovered(messageID:sources:)`
- `.toolExecutionStarted(id:messageID:execution:)`
- `.toolExecutionUpdated(id:messageID:execution:)`
- `.toolExecutionEnded(id:messageID:execution:)`
- `.toolCancelled(id:messageID:)`
- `.requestCancelled(id:)`
- `.requestCompleted(id:)`
- `.requestFailed(id:error:)`

## 3. Surface Registries (Owned & Injected)
To support multiple independent windows without global state cross-talk, registries are owned per-chat instance or injected by the host:

```swift
let tools = AgentToolSurfaceRegistry()
let embedded = AgentEmbeddedSurfaceRegistry()

// Register host-specific tool views:
tools.registerToolHandler("hanlin.sefaria") { context in
    // Render Sefaria custom card
}

// Register host-specific embedded mini apps / result sessions:
embedded.registerResolver(for: "hanlin.scriptui") { descriptor in
    // Return an AgentEmbeddedResultSession instance
}
```

Pass registries directly into `AgentChatView` / `AgentChatScreen`:
```swift
AgentChatView(
    session: session,
    surfaces: tools,
    embeddedSurfaces: embedded,
    hostActions: hostActions
)
```

## 4. Host Action Hooks
Interactive actions within embedded cards and native blocks route to the host via `AgentHostActions`:
```swift
@MainActor
public protocol AgentHostActions: AnyObject, Sendable {
    func openURL(_ url: URL)
    func requestSheet(_ request: AgentPresentationRequest)
    func requestFullScreen(_ request: AgentPresentationRequest)
    func requestWindow(_ request: AgentPresentationRequest)
    func performAction(_ action: AgentHostAction)
}
```

- **Window Requests**: On iPadOS / macOS, host apps handle multi-window requests via `requestWindow`.
- **Sheet & FullScreen**: Handled either locally by `AgentExpansionCoordinator` or intercepted by the host.
- **Custom Actions**: Custom action IDs (e.g. `save`, `reset`, `execute_script`) are dispatched with payload to `performAction`.

## 5. API Gaps & Future Recommendations
1. **Physical Device Touch Testing**: The zoom gesture transitions and drag-down dismissals have simulator and unit test coverage, but physical iPad testing is recommended before 1.0 release.
2. **Audio Input Streaming**: `AgentComposerView` contains mic UI affordances; live streaming speech-to-text integration should be wired by the host adapter.
3. **Multi-Window Scene Bridging**: On visionOS and iPadOS, connecting `requestWindow` to `openWindow(id:)` requires host app SwiftUI `WindowGroup` scene definitions.
