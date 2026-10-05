# Third-Party Notices & Licensing Information

This project contains original work and incorporates design and architectural references from open-source projects.

## AgentUI SDK
The AgentUI SDK (`Sources/AgentUI`) is an original, clean-room implementation of a reusable AI agent conversational UI for Apple platforms.
- It does NOT copy, vendor, or redistribute unlicensed source code from the SwiftChat repository.
- It does NOT copy or vendor AGPL-3.0 source code from the OpenClient repository.
- AgentUI maintains zero external package dependencies (`Package.swift` has 0 dependencies) and is completely provider-neutral.

## Reference Projects

### SwiftChat
- Repository: https://github.com/sachaservan/SwiftChat
- Reference SHA: `d6f54ccf9e84d2fec672b7b89d5a67dd6ee0f957`
- SwiftChat currently has no declared open-source license.
- Usage: Consulted solely as a visual and behavioral design baseline for the legacy prototype. None of its application source code is incorporated into the `AgentUI` library.

### OpenClient
- Repository: https://github.com/artcc/openclient-llm
- License: AGPL-3.0
- Usage: Consulted for behavioral and visual reference only. No source code has been copied into the `AgentUI` SDK.

## Evaluated References (Not Vendored Dependencies)

The following libraries were evaluated for markdown and math parsing patterns. The AgentUI SDK implements its own standalone, clean-room pure-Swift AST tokenizers and typesetting engines (`AgentMarkdownParser`, `AgentMathParser`):

### Textual
- Repository: https://github.com/tinfoilsh/textual
- License: MIT License
- Status: Evaluated reference only. Not an SPM dependency.

### SwiftMath
- Repository: https://github.com/mgriebling/SwiftMath
- License: MIT License
- Status: Evaluated reference only. Not an SPM dependency.

### OpenAI-Swift Fork
- Repository: https://github.com/tinfoilsh/openai-swift-fork
- License: MIT License
- Status: Evaluated reference only. Not an SPM dependency.
