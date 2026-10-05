# Custom Tool Surfaces

## Tool Execution Disclosure Architecture

When tools execute, the primary UI is the domain-specific tool presentation. Technical call details (arguments, results, errors) can be inspected via an expandable disclosure.

### Critical Surface Bug Fix
Unlike legacy prototypes which rendered expanded inspection details in a detached secondary card below the tool, `ToolExecutionDisclosure` renders inside **one continuous glass surface**:

```text
+--------------------------------------+
| [tool-provided UI]                v  |
|                                      |
| Tool call                            |
| search_repositories                  |
|                                      |
| Arguments                            |
| { "query": "AgentUI" }               |
+--------------------------------------+
```

## Registering Custom Tool Surfaces

```swift
let registry = AgentToolSurfaceRegistry.shared

registry.registerToolHandler("github.search") { context in
    HStack(spacing: 8) {
        Image(systemName: "chevron.left.forwardslash.chevron.right")
        Text("GitHub Code Search")
    }
}
```
