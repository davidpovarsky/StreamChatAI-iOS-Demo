# Embedded Results & Mini Apps

AgentUI hosts arbitrary interactive SwiftUI surfaces without hardcoding knowledge of the host application's engines.

## Embedded Session Lifecycle

Host apps implement `AgentEmbeddedResultSession`:

```swift
@MainActor
public protocol AgentEmbeddedResultSession: AnyObject, Identifiable {
    var id: UUID { get }
    var rootView: AnyView { get }
    func tearDown()
}
```

## Sizing Presets & Expansion Modes

- **Presets**: `.automatic` (220pt), `.compact` (140pt), `.regular` (240pt), `.large` (380pt).
- **Expansion**: Supports modal expand to `.sheet`, `.fullScreen`, or `.window`.
- **Teardown**: When the embedded card disappears from the chat, `tearDown()` is triggered.
