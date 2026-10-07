# AgentChatSDK Architecture Specification

`AgentChatSDK` is a modular, reusable Swift Package that provides an agentic AI chat interface for iOS applications. It transforms the chat surface from simple text bubbles into a multimodal conversational canvas supporting live reasoning timelines, expandable tool disclosures, syntax-highlighted code, LaTeX math, remote media, vector graphics, and realtime voice.

---

## 1. Package Graph & Modularity

```mermaid
flowchart TD
    subgraph App Layer
        DemoApp[Host Demo App]
        ExternalApp[External Host App]
    end

    subgraph AgentChatSDK Umbrella
        SDK[AgentChatSDK]
    end

    subgraph Core
        Core[AgentChatCore]
    end

    subgraph Features
        Activity[AgentChatActivity]
        RichResults[AgentChatRichResults]
        Rendering[AgentChatRendering]
        Media[AgentChatMedia]
        Voice[AgentChatVoice]
        VoiceLiveKit[AgentChatVoiceLiveKit]
        UI[AgentChatUI]
        Integrations[AgentChatIntegrations]
    end

    DemoApp --> SDK
    ExternalApp --> SDK

    SDK --> UI
    SDK --> Integrations
    SDK --> Core

    UI --> Core
    UI --> Activity
    UI --> RichResults
    UI --> Rendering
    UI --> Media
    UI --> Voice

    Activity --> Core
    RichResults --> Core
    RichResults --> Activity
    Rendering --> Core
    Media --> Core
    Voice --> Core
    VoiceLiveKit --> Voice
    Integrations --> UI
    Integrations --> Core
```

---

## 2. Module Responsibilities

| Module | Purpose & Scope |
|---|---|
| **`AgentChatCore`** | Foundation domain models, message contracts, generation states, event types (`AgentActivityEvent`), configuration structs, and the observable `AgentChatSession`. No UI dependencies. |
| **`AgentChatActivity`** | Agent reasoning timeline, live step execution tracker, status indicators, and elapsed time chips (`AgentActivityTimelineView`, `AgentActivityStore`). |
| **`AgentChatRichResults`** | Expandable tool execution disclosure cards (`ToolExecutionDisclosure`), inspection view (`ToolCallInspectionView`), and registry for custom tool renderers (`AgentToolRendererRegistry`). |
| **`AgentChatRendering`** | Specialized multimodal text and graphic renderers: AST Markdown parser (`AgentMarkdownParser`), code syntax highlighting (`AgentCodeBlockView`), native LaTeX equations (`AgentMathView`), SVG vector graphics (`AgentSVGView`), and citation clusters (`InlineSectionSourcesView`). |
| **`AgentChatMedia`** | Cached remote image loading, image galleries with preview sheet (`AgentRemoteImageView`), video thumbnail players (`AgentVideoMediaView`), and fallback views. |
| **`AgentChatVoice`** | Voice session abstraction (`AgentVoiceSessionProvider`), state machine, deterministic mock provider (`AgentMockVoiceProvider`), and interactive glowing voice orb (`AgentVoiceOrbView`). |
| **`AgentChatVoiceLiveKit`** | Optional WebRTC/LiveKit voice provider target (`LiveKitVoiceSessionProvider`). |
| **`AgentChatUI`** | Top-level ChatGPT-style conversation view (`AgentChatView`), message rows (`AgentMessageRowView`), multiline composer (`AgentComposerView`), emoji picker (`AgentEmojiPicker`), and model selector. |
| **`AgentChatIntegrations`** | Adapters for GetStream `StreamChatAI` and deterministic test drivers (`DeterministicDemoDriver`). |
| **`AgentChatSDK`** | Umbrella module providing `@_exported` imports of all public targets. |

---

## 3. Public API & Consumption

External host apps integrate `AgentChatSDK` via Swift Package Manager:

```swift
// In your host SwiftUI View:
import AgentChatSDK
import SwiftUI

struct MyChatView: View {
    @StateObject private var session = AgentChatSession(
        configuration: AgentChatConfiguration()
    )

    var body: some View {
        AgentChatView(
            session: session,
            configuration: session.configuration
        )
    }
}
```

### Event & Streaming Pipeline
When an agent or backend runtime executes actions:
1. `session.startAssistantMessage()` creates an active message slot.
2. `session.publishEvent(.reasoningStarted(...))` updates the live reasoning timeline.
3. `session.publishEvent(.webSearchStarted(...))` and `.sourceDiscovered(...)` populate search chips.
4. `session.publishEvent(.toolStarted(...))` and `.toolCompleted(...)` populate interactive tool cards.
5. `session.appendToken(...)` or `session.appendBlock(...)` streams tokens and heterogeneous blocks into the message.
6. `session.completeAssistantMessage()` marks generation complete.

---

## 4. Tool Execution & Custom Renderer Registry

The SDK decouples tool execution UI from internal types through `AgentToolRendererRegistry`:

```swift
public struct FlightBookingRenderer: AnyAgentToolRenderer {
    public var supportedToolIDs: Set<String> { ["book_flight", "search_flights"] }

    public func render(call: AgentToolCall, result: AgentToolResult?) -> AnyView {
        AnyView(FlightCardView(call: call, result: result))
    }
}

// Register once at app launch:
AgentToolRendererRegistry.shared.register(FlightBookingRenderer())
```

When a tool result arrives, `AgentRichResultView` looks up the custom renderer; if none is registered, it gracefully renders the fallback generic inspection card inside `ToolExecutionDisclosure`.

---

## 5. Voice Architecture

Voice mode uses a provider pattern:
- `AgentVoiceSessionProvider` protocol defines `startSession()`, `stopSession()`, `sendAudio()`, and publishers for `state` and `audioLevel`.
- `AgentMockVoiceProvider` provides a zero-network deterministic state machine for previews and tests.
- `LiveKitVoiceSessionProvider` provides live WebRTC audio transport without coupling the core chat UI to WebRTC binaries.

---

## 6. Host vs. SDK Separation

- **The SDK is the product**: All models, views, renderers, adapters, and configuration options live in `Packages/AgentChatSDK`.
- **The Demo App is the host**: `StreamChatAIDemo` simply adds `Packages/AgentChatSDK` as a package dependency in `project.yml`, imports `AgentChatSDK` in `ContentView.swift`, and exercises the public API without reaching into internals.
