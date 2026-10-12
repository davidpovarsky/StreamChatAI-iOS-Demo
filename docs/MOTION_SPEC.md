# AgentChatMotion Specification (iOS 27.0+)

`AgentChatMotion` encapsulates motion design tokens, interactive transitions, and accessibility compliance across the SDK.

---

## 1. Motion Tokens & Physics

All animations are defined in `AgentMotionTokens` using native iOS spring physics:

| Token | Physics | Response | Damping Ratio | Usage |
| :--- | :--- | :--- | :--- | :--- |
| `subtleSpring` | `.spring(response:dampingRatio:)` | `0.32s` | `0.82` | Button presses, disclosure chevrons, chips |
| `messageEntrance` | `.spring(response:dampingRatio:)` | `0.40s` | `0.78` | Incoming user and assistant message bubble appearance |
| `cardExpand` | `.spring(response:dampingRatio:)` | `0.45s` | `0.75` | Result card expansion, inspector sheet presentation |
| `errorShake` | `.spring(response:dampingRatio:)` | `0.35s` | `0.60` | One-shot validation errors, rejected approval cards |

---

## 2. Accessibility & Reduce Motion

### System Compliance
Every motion modifier observes `@Environment(\.accessibilityReduceMotion)`. When enabled:
1. All translational movements (e.g. vertical bubble slides, card pop-ins) are replaced by instant opacity fades (`0.15s` duration).
2. The error shake effect is disabled.
3. The pulsing thinking indicator becomes a static indicator dot.

### Override for Deterministic Testing
`AgentMotionTokens.reduceMotionOverride: Bool?` allows automated UI snapshot test runners to force `reduceMotion = true` regardless of host simulator accessibility state, ensuring 100% deterministic pixel comparison.

---

## 3. ShipSwift Recipe Provenance & Evaluation

We evaluated patterns from `ShipSwift` (licensed under MIT, Copyright 2024-2026 SignerLabs):

### Incorporated Patterns:
- **Clean Spring Damping Curves**: Tuned response and damping parameters directly into `AgentMotionTokens` for natural iOS momentum.
- **Card Zoom Transitions**: Matched transition source logic for full-screen media inspection.
- **Subtle Haptic Feedback**: Light impact haptics on approval card decisions and accordion disclosure taps.

### Excluded Effects & Justification:
- **Overly Dramatic Bounces**: High bounciness and bouncy rubber-band effects were rejected as they distract users in professional AI chat contexts.
- **Excessive Particle Emitters & Confetti**: Heavy GPU particle systems were excluded to prevent thermal throttling and battery drain during long streaming sessions.
- **Heavy Third-Party Animation Libraries**: Direct dependencies on legacy visual-effects packages (`Pow`) were eliminated in favor of 100% native SwiftUI spring APIs.
