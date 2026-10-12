# AgentChatSDK Architecture Specification (iOS 27.0+)

## 1. System Overview & Modular DAG

`AgentChatSDK` is organized as a strict directed acyclic graph (DAG) of specialized modules under Swift Package Manager targeting `iOS 27.0+`. The architecture enforces single-responsibility boundaries, pure-Swift core models, and zero direct web view dependencies in the standard rendering pipeline.

```mermaid
graph TD
    AgentChatCore[AgentChatCore<br/>Models, Reducer, Clock, Session]
    AgentChatMotion[AgentChatMotion<br/>Spring Tokens, Modifiers, Indicators]
    AgentChatMarkdown[AgentChatMarkdown<br/>Textual + SwiftMath Engine]
    AgentChatSources[AgentChatSources<br/>Domain Chips, Provenance]
    AgentChatRichMedia[AgentChatRichMedia<br/>Native Images, Audio, Video]
    AgentChatActivity[AgentChatActivity<br/>Hierarchical Activity Disclosure]
    AgentChatToolPresentation[AgentChatToolPresentation<br/>Approvals, Technical Inspector]
    AgentChatResultCards[AgentChatResultCards<br/>Swift Charts, MapKit, Forms, Canvas]
    AgentChatComposer[AgentChatComposer<br/>Input, Attachments, Speech]
    AgentChatCanvas[AgentChatCanvas<br/>Artifact Editor, Document Diff]
    AgentChatUI[AgentChatUI<br/>Chat Shell, NavigationSplitView, Transcript]
    AgentChatSDK[AgentChatSDK<br/>Unified Public Entrypoint]
    AgentChatWebContent[AgentChatWebContent<br/>Optional Isolated WKWebView]
    AgentChatVoiceLiveKit[AgentChatVoiceLiveKit<br/>Optional LiveKit Transport]

    AgentChatCore --> AgentChatMotion
    AgentChatCore --> AgentChatMarkdown
    AgentChatCore --> AgentChatSources
    AgentChatCore --> AgentChatRichMedia
    AgentChatCore --> AgentChatActivity
    AgentChatCore --> AgentChatToolPresentation
    AgentChatCore --> AgentChatResultCards
    AgentChatCore --> AgentChatComposer
    AgentChatCore --> AgentChatCanvas

    AgentChatMotion --> AgentChatActivity
    AgentChatMotion --> AgentChatToolPresentation
    AgentChatMotion --> AgentChatResultCards
    AgentChatMotion --> AgentChatUI

    AgentChatSources --> AgentChatActivity
    AgentChatToolPresentation --> AgentChatActivity

    AgentChatCore --> AgentChatUI
    AgentChatMarkdown --> AgentChatUI
    AgentChatSources --> AgentChatUI
    AgentChatRichMedia --> AgentChatUI
    AgentChatActivity --> AgentChatUI
    AgentChatToolPresentation --> AgentChatUI
    AgentChatResultCards --> AgentChatUI
    AgentChatComposer --> AgentChatUI
    AgentChatCanvas --> AgentChatUI

    AgentChatUI --> AgentChatSDK
    AgentChatCore --> AgentChatWebContent
    AgentChatCore --> AgentChatVoiceLiveKit
```

---

## 2. State Ownership & No-Singleton Guarantees

In legacy implementations, global singletons such as `AgentActivityStore.shared` and `ToolExecutionDemoStore.shared` introduced race conditions, leaky state across test cases, and tight coupling with specific views.

`AgentChatSDK` enforces complete instance-level scoping:
1. **`AgentChatSession` as Scoped Owner**: Each chat window or view hierarchy instantiates an observable `@Observable final class AgentChatSession`. It holds its own conversations, active message drafts, configuration, and event stream subscriptions.
2. **Deterministic Reducer**: State transitions are performed through `AgentEventReducer.reduce(conversation:event:)`, a pure function returning a mutated conversation without side effects.
3. **No Hidden Observers**: Activity runs, tool executions, and approval cards are stored directly in `ChatMessage.agentRun` and `ChatMessage.approvalRequests`. There are no global notification centers, singletons, or background stores.

---

## 3. Event Flow & Life Cycle

The following diagram illustrates how user input flows from the native composer into the session, driving the virtual clock and reducer, and updating native UI components:

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant Composer as AgentComposerView
    participant Session as AgentChatSession
    participant Reducer as AgentEventReducer
    participant Transcript as AgentTranscriptView
    participant Activity as AgentHierarchicalActivityView
    participant Approval as AgentApprovalRequestCard
    participant Results as AgentResultRendererRegistry

    User->>Composer: Types prompt & taps Send
    Composer->>Session: send(text: attachments:)
    Session->>Reducer: .runStarted, .messageCreated
    Reducer-->>Session: Emits updated Conversation
    Session-->>Transcript: Renders User Bubble & Assistant Placeholder
    
    Session->>Reducer: .groupStarted, .operationStarted, .operationCompleted
    Reducer-->>Session: Updates AgentRun hierarchy
    Session-->>Activity: Updates Level 0 Header ("Working for 12s...") [Collapsed]
    
    opt Tool Approval Required
        Session->>Reducer: .approvalRequested(ApprovalRequest)
        Reducer-->>Session: Appends ApprovalRequest to Message
        Session-->>Approval: Displays Action Card in Transcript (Outside Activity)
        User->>Approval: Taps "Approve"
        Approval->>Session: handleAction(.approve(requestID))
        Session->>Reducer: .approvalResolved(requestID, .approved)
    end

    Session->>Reducer: .resultEmitted(AgentResult)
    Reducer-->>Session: Appends Result to Message
    Session-->>Results: Renders Swift Charts / MapKit / Canvas Card
    
    Session->>Reducer: .contentDelta (Markdown streaming)
    Reducer-->>Session: Appends text segment
    Session-->>Transcript: Streams rich markdown response
    
    Session->>Reducer: .runCompleted
    Reducer-->>Session: Sets run status to .completed
    Session-->>Activity: Header updates to "Worked for 1m 24s" [Remains Collapsed]
```

---

## 4. Action & Result Correlation

To ensure reliable, typed interaction without loose string dictionary conversions:
- **`ApprovalRequest`**: Uses stable `UUID` identifiers (`requestID`). Actions dispatch `AgentChatUserAction.approve(requestID)` or `.reject(requestID)`.
- **`AgentResult`**: Every tool output is wrapped in an `AgentResult` with a stable `resultID`, a typed `AgentResultKind` (e.g., `.chart`, `.map`, `.form`, `.canvasDiff`), and a typed payload conforming to `AnySendable`.
- **Action Callbacks**: Actions dispatched from interactive result cards (such as form adjustments or code editor approvals) carry `correlationRunID` and `parentMessageID` ensuring strict causal traceability in multi-agent workflows.
