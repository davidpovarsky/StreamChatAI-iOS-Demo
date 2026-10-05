# Hanlin Integration Guide

## Overview

Hanlin consumes `AgentUI` through an adapter layer (`Packages/HanlinAgentUIAdapter`). Hanlin maps its run transcripts, tools, and mini apps into `AgentUIEvent` and surface registries.

## Dependency Direction

```text
Hanlin -> AgentUI (Clean dependency)
AgentUI -> None (No knowledge of Hanlin)
```

## Adding AgentUI to Hanlin

In Hanlin's `Package.swift` or Xcode project:

```swift
.package(url: "https://github.com/davidpovarsky/StreamChatAI-iOS-Demo.git", branch: "agent/agentui-sdk")
```

Wrap existing engines (Swift Mini Apps, ScriptUI, NativeScript, Expo) with `AgentEmbeddedResultSession` implementations.
