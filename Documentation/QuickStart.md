# Quick Start Guide

## Installation via Swift Package Manager

Add `AgentUI` to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/davidpovarsky/StreamChatAI-iOS-Demo.git", branch: "agent/agentui-sdk")
]
```

Or in Xcode via **File > Add Package Dependencies**.

## Embedding Agent Chat

```swift
import SwiftUI
import AgentUI

struct ContentView: View {
    @State private var session = AgentUISession(
        runtime: MyRuntime(),
        models: [
            AgentModelDescriptor(id: "gpt-4o", displayName: "GPT-4o", iconSystemName: "sparkles")
        ]
    )

    var body: some View {
        AgentChatView(session: session)
    }
}
```
