# AgentChatSDK iOS Native Demo

A **100% native SwiftUI Chat UI SDK** designed for modern Apple platforms (minimum **iOS/iPadOS 27.0+**), featuring **hierarchical agent activity disclosures** (collapsed by default), rich interactive result cards, and an offline deterministic visual demo laboratory.

---

## Highlights

- **100% Native SwiftUI Shell**: Original, clean, premium SwiftUI interface inspired by modern AI assistants, without legacy wrappers, web shells, or third-party chat framework bloat.
- **Hierarchical Agent Activity**: Collapsed by default (`Worked for 2m 51s` or `Working for 1m 24s`). Users explicitly disclose phases (Planning, Research, Verification, Coding) and tool operations. Streaming tokens never force disclosures open or closed.
- **Action-Required Approvals**: Prominent permission cards (e.g. Calendar / Reminders write requests) visible directly in the transcript even while the activity tree remains closed.
- **Rich Interactive Result Cards**: Cleanly separated from tool history, including Swift Charts, MapKit route pins, interactive form calculators, document diff canvas, audio waveform player, and declarative miniapps.
- **Zero WebKit in Base Product**: WebKit is isolated into an optional standalone package (`AgentChatWebContent`). The base SDK renders native link/video previews with external browser handoff.
- **Deterministic Offline Visual Demo**: All 26 end-to-end scenarios execute through the real SDK component tree, state models, and event reducers without needing an LLM API key, account, or internet connection.
- **ShipSwift Micro-Interactions**: Native springs, sensory feedback, skeleton shimmer, and `.matchedTransitionSource` transitions with full support for `@Environment(\.accessibilityReduceMotion)`.

---

## Architecture Overview

```text
AgentChatCore                    (value models, typed events, reducers, protocols)
     |-- AgentChatMotion         (SwiftUI design tokens, springs, accessibility)
     |-- AgentChatMarkdown       (Textual + SwiftMath adapters, Hebrew RTL math)
     |-- AgentChatSources        (citations, domain favicon chips, sources sheet)
     |-- AgentChatRichMedia      (Kingfisher images, Exyte SVGView, AVKit video)
     |-- AgentChatActivity       (run > group > operation; collapsed disclosure)
     |-- AgentChatToolPresentation (inspector, approval card, error/retry)
     |-- AgentChatResultCards    (typed native cards + renderer registry)
     |-- AgentChatComposer       (multiline input, model picker, attachments tray)
     |-- AgentChatCanvas         (document/code diff, inspector, revisions)
     |-- AgentChatVoice          (voice UI and mock provider)
     `-- AgentChatUI             (root split view, sidebar, transcript, rows)
                  |
             AgentChatSDK        (public facade + entrypoint + host integration)
                  |
         StreamChatAIDemo        (Showroom app with 4 tabs and 26 scenarios)
```

---

## Quick Start (Embedding in Host Application)

```swift
import SwiftUI
import AgentChatSDK

@MainActor
struct HostChatView: View {
    @StateObject private var session = AgentChatSession()

    var body: some View {
        AgentChatView(
            session: session,
            configuration: session.configuration,
            onAction: { action in
                print("Received user action: \(action.kind)")
            }
        )
    }
}
```

---

## Showcase Sections

The demo host application contains 4 tabs:

1. **Playground**: Full chat window with active composer. Type any message to start an offline event-streamed reply with live stop/retry controls.
2. **Scenarios (26)**: Interactive scenario catalog exercising all 26 specified workflows (research, parallel execution, approval accept/deny, error retry, cancellation, charts, maps, forms, and canvas diffs).
3. **Gallery**: Visual inventory of every component across Light/Dark modes, narrow iPhone / regular iPad widths, and Hebrew RTL.
4. **Motion Lab**: Motion foundation test bench comparing spring transitions, thinking indicators, skeleton shimmer, and reduce-motion overrides.

---

## Building the Unsigned IPA

CI automatically builds the unsigned device Release IPA using GitHub Actions:

- Artifacts:
  - `AgentChatSDK-Native-Demo-IPA` (`AgentChatSDK-Native-Demo-unsigned.ipa`)
  - `StreamChatAI-Demo-IPA` (fallback compatibility mirror)
  - `Snapshots-IPA` (visual baseline snapshots)

To install on an iPad or iPhone, sign the unsigned IPA using your preferred sideloading or signing tool (e.g. Sideloadly, AltStore, or Xcode).

---

## Documentation

- [Architecture & DAG Specification](docs/ARCHITECTURE.md)
- [Public SDK API Reference](docs/PUBLIC_SDK_API.md)
- [Component Catalog](docs/COMPONENT_CATALOG.md)
- [Hierarchical Agent Activity](docs/AGENT_ACTIVITY_HIERARCHY.md)
- [Motion & Micro-Interactions](docs/MOTION_SPEC.md)
- [Demo Scenarios (26 Workflows)](docs/DEMO_SCENARIOS.md)
- [Rendering & Dependencies](docs/RENDERING_AND_DEPENDENCIES.md)
- [CI & Unsigned IPA Guide](docs/CI_AND_IPA.md)
- [Test Coverage Report](docs/TEST_COVERAGE.md)
- [Third-Party Notices](THIRD_PARTY_NOTICES.md)
