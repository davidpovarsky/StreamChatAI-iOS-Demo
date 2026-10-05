# Versioning & Release Policy

## Current Status

- Current development version: `0.1.0` (Pre-1.0 development phase, do not tag 1.0.0 yet)
- Hardening branch: `agent/agentui-sdk-hardening-v2`

## Consumer Integration

### During Active Development
Consumers pin to branch or exact commit revision:
```swift
.package(url: "https://github.com/davidpovarsky/StreamChatAI-iOS-Demo.git", branch: "agent/agentui-sdk-hardening-v2")
```

### Stable Releases
Following physical device verification and user sign-off, releases will follow Semantic Versioning (`0.1.0`, `0.2.0`, etc.).
No runtime code downloading is permitted. All updates occur strictly via versioned Swift Package updates.
