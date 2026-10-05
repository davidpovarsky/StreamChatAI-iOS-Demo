# Theming & Design Tokens

## Design Propagation

All visual measurements and spacing across AgentUI are parameterized via `AgentUIDesignTokens`:

- `messageSpacing`
- `bubbleCornerRadius`
- `composerCornerRadius`
- `toolDisclosureCornerRadius`
- `controlButtonSize`
- `sourceFaviconSize`

### Overriding Theme

```swift
AgentChatView(session: session)
    .agentUITheme(
        AgentUITheme(
            accentColor: .indigo,
            userBubbleBackground: .indigo
        )
    )
```

Updating `AgentUIDesignTokens` in the SDK updates every consuming app upon package resolution.
