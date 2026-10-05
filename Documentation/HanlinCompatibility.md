# Hanlin Compatibility Matrix

This document defines the direct contract mapping between Hanlin AI domain types and AgentUI SDK presentation models:

| Hanlin Type / Concept | AgentUI Presentation Model | Description |
|---|---|---|
| `AgentRun` / transcript stream | `AgentUIEvent` stream | Mapped via `HanlinAgentUIRuntimeAdapter` |
| `HanlinToolExecutionPresentationDescriptor` | `AgentToolExecution` | Tool presentation descriptor with inspection |
| `HanlinExecutionPresentationFamilyID` | `handlerID: String` | Registered in `AgentToolSurfaceRegistry` |
| `HanlinEmbeddedPresentationDescriptor` | `AgentEmbeddedPresentationDescriptor` | Interactive embedded card metadata |
| `HanlinEmbeddedSizingPreference` | `AgentEmbeddedSizingPreference` | Sizing presets (`compact`, `regular`, `large`) |
| `HanlinExpansionDescriptor` | `AgentExpansionDescriptor` | Allowed expansion modes (`sheet`, `fullScreen`) |
| `HanlinEmbeddedResultPayload` | `AgentEmbeddedPayload` | Raw payload dictionary and actions |
| `HanlinEmbeddedContentAction` | `AgentEmbeddedContentAction` | Interactive button callbacks |
| `HanlinEmbeddedResultSession` | `AgentEmbeddedResultSession` | Session protocol wrapper providing `rootView` |
| `NativeUIBlock` | `AgentNativeUIBlock` | Clean structured card / calculation / search block |
| Hanlin Route / Launch Request | `AgentHostActions` | Presentation callbacks back to host router |
| Evidence / Resources | `AgentSource` | Citations cluster and sources sheet data |
