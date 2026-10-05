# AgentUI SDK

AgentUI is a modular, provider-neutral Swift Package that serves as the single source of truth for conversational AI agent interfaces across Apple platforms (iOS 18+, macOS 15+, visionOS 2+, with iOS 26 Liquid Glass styling).

## Overview

```text
                       AgentUI SDK
                   single UI source of truth
                             |
           +-----------------+-----------------+
           |                 |                 |
           v                 v                 v
    Showcase / UI Lab      Hanlin          Other apps
    deterministic mocks    adapter         adapter
```

- **Clean-room, Independent SDK**: Zero dependency on unlicensed code or proprietary vendor SDKs (OpenAI, Anthropic, Gemini, etc.).
- **Engine-Neutral**: Communicates with host apps solely through `AgentUIRuntimeAdapter` and typed event streams (`AgentUIEvent`).
- **One Continuous Surface Tool Disclosure**: Fixes the detached second-card defect in tool execution inspection.
- **Embedded Results & Mini Apps**: Built-in support for hosting arbitrary interactive widgets with expand-to-sheet and fullscreen modes.
- **Unified Design Tokens**: Semantic design tokens (`AgentUIDesignTokens`) allow instant styling updates across all consuming apps.

## Quick Start

```swift
import SwiftUI
import AgentUI

struct AgentScreen: View {
    @State private var session = AgentUISession(
        runtime: MyCustomRuntimeAdapter(),
        models: [
            AgentModelDescriptor(id: "gpt-4o", displayName: "GPT-4o"),
            AgentModelDescriptor(id: "claude-3-5", displayName: "Claude 3.5 Sonnet")
        ]
    )

    var body: some View {
        AgentChatView(session: session)
    }
}
```

## Documentation

- [Quick Start](Documentation/QuickStart.md)
- [Architecture](Documentation/Architecture.md)
- [Runtime Adapter](Documentation/RuntimeAdapter.md)
- [Tool Surfaces](Documentation/ToolSurfaces.md)
- [Embedded Results](Documentation/EmbeddedResults.md)
- [Theming & Design Tokens](Documentation/Theming.md)
- [Showcase UI Lab](Documentation/Showcase.md)
- [Hanlin Integration](Documentation/HanlinIntegration.md)
- [Hanlin Compatibility Mapping](Documentation/HanlinCompatibility.md)
- [Versioning & Release Policy](Documentation/Versioning.md)
