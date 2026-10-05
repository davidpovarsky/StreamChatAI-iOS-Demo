# Versioning & Release Policy

## Current Status

- Current development version: `0.1.0`
- Active development branch: `agent/agentui-sdk`

## Consumer Integration

### During Active Development
Consumers pin to branch or exact commit revision:
```swift
.package(url: "https://github.com/davidpovarsky/StreamChatAI-iOS-Demo.git", branch: "agent/agentui-sdk")
```

### Stable Releases
Following device acceptance and user approval, versions will follow Semantic Versioning (`0.1.0`, `0.2.0`, etc.).

No runtime code downloading is permitted. All updates occur via versioned Swift Package updates.
