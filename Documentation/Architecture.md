# AgentUI Architecture

## Principles

1. **Presentation Separation**: AgentUI owns rendering, layout, glass materials, animations, and session presentation state. The host app owns model connectivity, credentials, and tool execution engines.
2. **Neutral Event Streams**: Interaction flows through `AgentUIEvent` values yielded by an `AsyncThrowingStream`.
3. **Continuous Glass Surface**: Tool disclosures and card widgets render as single continuous surfaces without detached sub-cards.
4. **Custom Tool & Embedded Registries**: Host apps register custom tool UI or mini apps by handler ID.

## Subsystems

- `AgentUI/Core`: Models, IDs, messages, attachments, sources, and neutral events.
- `AgentUI/Session`: `@Observable` session state managing conversation history, drafts, and active streaming.
- `AgentUI/Theme`: Centralized semantic tokens (`AgentUIDesignTokens`) and theme overrides.
- `AgentUI/Chat`: Message list, assistant rows, user bubbles, and chat shell.
- `AgentUI/Composer`: Multiline input, model menu, attachment menu, mic, and send/stop controls.
- `AgentUI/Tools`: Tool execution disclosures, technical inspection views, and surface registries.
- `AgentUI/Embedded`: Interactive mini app hosts, sizing presets, and expansion affordances.
