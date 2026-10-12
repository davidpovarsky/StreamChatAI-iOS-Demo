# AgentChatSDK Public API Specification (iOS 27.0+)

`AgentChatSDK` provides a modern, Swift 6-compliant API for integrating AI chat interfaces into iOS and iPadOS applications.

---

## 1. Quick Integration

Add `AgentChatSDK` to your Xcode project or `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/davidpovarsky/StreamChatAI-iOS-Demo.git", branch: "agent/swiftchat-sdk-chatgpt-stack-realignment")
]
```

### Basic Embedding in SwiftUI

```swift
import SwiftUI
import AgentChatSDK

struct MyAppChatView: View {
    @State private var session = AgentChatSession()

    var body: some View {
        AgentChatView(session: session)
    }
}
```

---

## 2. Configuration & Runtime Customization

The SDK behavior is configured via `AgentConfiguration`:

```swift
import SwiftUI
import AgentChatSDK

struct ConfiguredChatView: View {
    @State private var session: AgentChatSession

    init() {
        var config = AgentConfiguration.default
        config.enableAttachments = true
        config.enableVoice = true
        config.enableMarkdown = true
        config.enableMath = true
        config.enableToolDisclosure = true
        config.showReasoningTimeline = true
        config.availableModels = [
            AgentModel(id: "gpt-4o", name: "GPT-4o", provider: "OpenAI", isDefault: true),
            AgentModel(id: "claude-3-5-sonnet", name: "Claude 3.5 Sonnet", provider: "Anthropic")
        ]
        
        _session = State(initialValue: AgentChatSession(configuration: config))
    }

    var body: some View {
        AgentChatView(session: session)
    }
}
```

---

## 3. Custom Event Streams & Backend Injection

Hosts connect their own backend models or streaming WebSockets by forwarding events to `session.handleEvent(_:)`:

```swift
Task {
    // 1. Notify that an agent run has started
    session.handleEvent(.runStarted(runID: runID, messageID: assistantMsgID))
    
    // 2. Stream hierarchical steps
    session.handleEvent(.groupStarted(runID: runID, groupID: "research", title: "Searching the web"))
    session.handleEvent(.operationStarted(runID: runID, groupID: "research", opID: "search-1", title: "Querying Apple Developer docs"))
    session.handleEvent(.operationCompleted(runID: runID, groupID: "research", opID: "search-1", status: .success))
    session.handleEvent(.groupCompleted(runID: runID, groupID: "research", status: .success))
    
    // 3. Stream text delta
    session.handleEvent(.contentDelta(messageID: assistantMsgID, text: "Here is what I found..."))
    
    // 4. Conclude run
    session.handleEvent(.runCompleted(runID: runID))
}
```

---

## 4. Registering Custom Result Renderers

Hosts can register custom rich cards dynamically with `AgentResultRendererRegistry`:

```swift
import SwiftUI
import AgentChatCore
import AgentChatResultCards

struct CustomStockTickerCard: View {
    let result: AgentResult

    var body: some View {
        VStack(alignment: .leading) {
            Text("Ticker: \(result.title)")
                .font(.headline)
            Text("Value: \(result.content)")
                .font(.title)
                .foregroundStyle(.green)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// In app startup:
AgentResultRendererRegistry.shared.register(kind: .custom("stock-ticker")) { result in
    AnyView(CustomStockTickerCard(result: result))
}
```

---

## 5. Host Safety & Permissions Contract

- **Zero LLM Key Leakage**: The base SDK does not accept, store, or require API keys. All network transmission and key handling are managed host-side.
- **Offline / Isolated Execution**: The standard package imports no networking libraries or WebKit components, ensuring zero external data leakage.
- **Action Confirmation**: Dangerous tool invocations emit an `ApprovalRequest` card requiring explicit local user confirmation before completing.
