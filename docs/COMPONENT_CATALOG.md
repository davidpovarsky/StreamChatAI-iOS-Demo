# AgentChatSDK Component Catalog (iOS 27.0+)

This catalog details the modular native components provided by `AgentChatSDK`.

---

## 1. Shell & Navigation Components

### `AgentChatRootView` (`AgentChatUI`)
- **Description**: Main responsive application shell. Renders a native two-column `NavigationSplitView` on iPad and desktop layouts, and a responsive stack on iPhone.
- **States**: Sidebar expanded/collapsed, active conversation selected.
- **User Actions**: Switch conversations, toggle sidebar, start new conversation.
- **Demo Location**: Tab 1 ("Playground"), Tab 2 ("Scenarios").

### `AgentTranscriptView` (`AgentChatUI`)
- **Description**: Smooth virtualized transcript scroll view managing message streams and interactive cards.
- **Features**: Automatic pin-to-bottom on streaming, detached manual scroll detection, and floating scroll-to-bottom button.
- **Demo Location**: All scenario playthroughs.

---

## 2. Activity & Tool Execution Components

### `AgentHierarchicalActivityView` (`AgentChatActivity`)
- **Description**: 3-level hierarchical disclosure showing agent background work without cluttering the chat.
- **Hierarchy**:
  - **Level 0 (Run Header)**: Collapsed by default. Displays live timer `Working for 12s...` or final summary `Worked for 1m 24s`.
  - **Level 1 (Stage / Group)**: Logical execution phases (e.g., `Searching the web`, `Analyzing codebase`).
  - **Level 2 (Operation)**: Specific tool calls, elapsed duration, source domains, and inspection trigger.
- **Invariant**: Remains collapsed unless explicitly tapped by the user. Subsequent stream updates do not force expansion.
- **Demo Location**: Tab 3 ("Gallery" -> "Hierarchical Activity"), Scenarios 1-5, 23.

### `AgentApprovalRequestCard` (`AgentChatToolPresentation`)
- **Description**: High-visibility action card rendered directly in the transcript outside the activity tree for tools requiring explicit confirmation (e.g. database updates, financial transactions).
- **States**: `Pending`, `Approved`, `Rejected`.
- **User Actions**: Tap "Approve" (green checkmark) or "Decline" (red cancel).
- **Demo Location**: Tab 3 ("Gallery" -> "Approval Cards"), Scenario 4 ("Security & Approval Flow").

### `AgentToolInspectorView` (`AgentChatToolPresentation`)
- **Description**: Technical inspector sheet presenting arguments, return values, headers, and credential redactions for audits.
- **Security**: Automatically redacts sensitive bearer tokens, passwords, and private keys.
- **Demo Location**: Inspector button on any expanded Level 2 operation.

---

## 3. Rich Result Cards (`AgentChatResultCards`)

### `ChartResultView`
- **Description**: 100% native interactive data charts powered by Apple's `Swift Charts` framework.
- **Supported Formats**: Bar charts, line charts, area charts, and statistical summaries.
- **User Actions**: Toggle chart type (Bar / Line / Area), hover / tap data points for tooltips.
- **Demo Location**: Tab 3 ("Gallery" -> "Swift Charts"), Scenario 6 ("Interactive Charting").

### `MapResultView`
- **Description**: Native MapKit card rendering interactive pins, route paths, and detailed stop cards.
- **User Actions**: Pan, zoom, select pin to view detail sheet.
- **Demo Location**: Tab 3 ("Gallery" -> "MapKit"), Scenario 7 ("Geographic MapKit").

### `FormResultView`
- **Description**: Dynamic interactive form and pricing calculator.
- **User Actions**: Adjust sliders, toggle options, enter inputs, and tap "Submit Calculation" to return typed action data back to the agent.
- **Demo Location**: Tab 3 ("Gallery" -> "Forms"), Scenario 8 ("Interactive Calculator Form").

### `CanvasResultViews` (Diff & Editor)
- **Description**: Document comparison view highlighting side-by-side or unified additions/deletions, with an integrated syntax-highlighted code editor.
- **User Actions**: Accept/reject revisions, toggle diff views, copy code.
- **Demo Location**: Tab 3 ("Gallery" -> "Canvas Diff"), Scenario 9 ("Canvas Document Diff").

### `NativeMiniAppCard`
- **Description**: Standalone sandboxed widget supporting custom transactional micro-applications (e.g., flight seat selectors, delivery trackers).
- **Demo Location**: Tab 3 ("Gallery" -> "MiniApp"), Scenario 10 ("Interactive MiniApp").

---

## 4. Input & Composer Components

### `AgentComposerView` (`AgentChatComposer`)
- **Description**: Native input toolbar supporting multi-line growing text fields, model picker, attachment tray, and voice input simulation.
- **Controls**: Send button (transforms to stop button during streaming), model selector menu, attachment picker button.
- **Demo Location**: All chat screens.
