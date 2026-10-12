# Test Coverage & Verification Matrix (iOS 27.0+)

## 1. Test Architecture & Suites

The test suite covers core business logic, reducer state transitions, virtual clock scheduling, and visual snapshots across targets:

| Target | Test File | Test Case Scope | Verification Focus |
| :--- | :--- | :--- | :--- |
| `AgentChatSDKTests` | `AgentChatSDKTests.swift` | Canonical Models & Reducer | Stable IDs, monotonic run status, non-leaking user disclosure state, event idempotency. |
| `AgentChatSDKTests` | `AgentChatSDKTests.swift` | Hierarchical Activity Flow | Level 0 run header collapsed by default; Level 1 groups; Level 2 operations. |
| `AgentChatSDKTests` | `AgentChatSDKTests.swift` | Approval State Machine | Pending -> Approved / Rejected state transitions; visibility outside activity tree. |
| `AgentChatSDKTests` | `AgentChatSDKTests.swift` | Rich Result Registry | Typed card registration, fallback on unknown schema, no crash on invalid payload. |
| `AgentChatSDKTests` | `AgentChatSDKTests.swift` | Native Visual Snapshots | 22 visual states across Light, Dark, RTL Hebrew, and iPad Regular widths. |
| `AgentChatMathComparisonTests` | `MathComparisonTests.swift` | LaTeX & Markdown Engine | SwiftMath vs iosMath rendering fidelity; streaming LaTeX equations; RTL mixed prose. |

---

## 2. Automated Snapshot Baselines

Golden snapshots are verified under `Packages/AgentChatSDK/Tests/`:
- **`AgentChatSDKTests/__Snapshots__/`**:
  - `01_EmptyInitialChat`
  - `02_UserMessageBubble`
  - `03_StreamedAssistantMessage`
  - `04_ActivityCollapsedDefault` (`Worked for...`)
  - `05_ActivityExpandedHierarchy`
  - `06_ApprovalRequestCard`
  - `07_ChartResultCard`
  - `08_MapResultCard`
  - `09_FormCalculatorCard`
  - `10_CanvasDiffCard`
  - `11_MiniAppDashboardCard`
  - `12_LaTeXMathMixedHebrew`
  - `13_SourceChipsWebSearch`
  - `14_ToolTechnicalInspector`
  - `15_Dark_MessageBubble`
  - `16_Dark_ActivityHierarchy`
  - `17_Dark_ChartCard`
  - `18_Dark_MapCard`
  - `19_RTL_Hebrew_Transcript`
  - `20_RTL_Hebrew_Activity`
  - `21_iPadRegularWidth_SplitView`
  - `22_iPadRegularWidth_CanvasInspector`
- **`AgentChatMathComparisonTests/__Snapshots__/`**:
  - LaTeX equation comparisons across Light/Dark/RTL.

---

## 3. Manual Verification Checklist

In addition to automated tests, the following manual flows are verified in `StreamChatAIDemo`:
- [x] **Composer Arbitrary Send**: Typing in the Playground composer streams simulated responses without freezing UI.
- [x] **Playback Controls**: Step, Pause, Resume, and Speed slider accurately throttle `DeterministicDemoDriver`.
- [x] **Component Gallery**: Light/Dark toggle and Hebrew RTL preview render without clipped labels.
- [x] **Motion Lab**: Reduce Motion toggle disables spring entrance transitions and replaces them with instant fades.
- [x] **Zero WebKit Invariant**: YouTube links render native preview fallback without initializing WebKit processes.

---

## 4. Outstanding Limitations

1. **Host Live LLM Backend**: The SDK provides deterministic offline drivers; integration with live OpenAI / Anthropic streaming APIs requires host-side network adapters.
2. **Audio Waveform Recording**: Voice consultation mode is demonstrated with mock audio waveforms; real live microphone input requires host entitlement `NSMicrophoneUsageDescription`.
3. **MapKit Route Rendering**: In simulator environments, Apple Park route tiles require internet access or local cached map assets.
