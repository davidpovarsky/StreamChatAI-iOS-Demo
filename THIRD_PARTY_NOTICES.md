# Third-Party Notices & Licensing Information

This project contains original work and incorporates design and architectural references from open-source projects.

## AgentUI SDK
The AgentUI SDK (`Sources/AgentUI`) is an original, clean-room implementation of a reusable AI agent conversational UI for Apple platforms.
- It does NOT copy, vendor, or redistribute unlicensed source code from the SwiftChat repository.
- It does NOT copy or vendor AGPL-3.0 source code from the OpenClient repository.
- AgentUI maintains zero proprietary model SDK dependencies and is provider-neutral.

## Reference Projects

### SwiftChat
- Repository: https://github.com/sachaservan/SwiftChat
- Reference SHA: `d6f54ccf9e84d2fec672b7b89d5a67dd6ee0f957`
- SwiftChat currently has no declared open-source license.
- Usage: Used solely as a visual and behavioral design baseline for the legacy prototype. None of its application source code is incorporated into the `AgentUI` library.

### OpenClient
- Repository: https://github.com/artcc/openclient-llm
- License: AGPL-3.0
- Usage: Consulted for behavioral and visual reference only. No source code has been copied into the `AgentUI` SDK.

## Third-Party Open Source Libraries (Evaluated for Compatibility)

### Textual
- Repository: https://github.com/tinfoilsh/textual
- License: MIT License

### SwiftMath
- Repository: https://github.com/mgriebling/SwiftMath
- License: MIT License

### OpenAI-Swift Fork
- Repository: https://github.com/tinfoilsh/openai-swift-fork
- License: MIT License
- Note: Evaluated for testing/reference. Not bundled into `AgentUI`.
