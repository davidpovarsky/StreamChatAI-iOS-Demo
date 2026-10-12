# Deterministic Demo Scenarios Catalog (26 Scenarios)

The `StreamChatAIDemo` application includes 26 offline, deterministic, reproducible scenarios driven by `DeterministicDemoDriver` and `VirtualClock`. These allow verification of every UI state, event stream, approval flow, and result card without an external LLM API or internet connection.

---

## Catalog of Scenarios

| # | ID | Title | User Prompt | Key Feature / Verification Focus |
|---|---|---|---|---|
| 01 | `01_plain_chat` | Plain Streamed Chat | "Tell me about the design philosophy of Apple platforms." | Content streaming deltas, markdown headers, and stop/retry controls. |
| 02 | `02_web_research` | Web Research (8 Sources) | "Research native UI libraries for Apple platforms in 2026." | Hierarchical activity (collapsed by default), 8 search domain chips (`[developer.apple.com]`, `[swift.org]`, etc.). |
| 03 | `03_multistage_reasoning` | Multistage Reasoning | "Plan a migration of a legacy chat SDK to native iOS 27 SwiftUI." | 3 sequential groups (`Planning`, `Coding`, `Verification`) under one Level 0 run header. |
| 04 | `04_parallel_work` | Parallel Concurrent Tasks | "Run security and performance audits in parallel." | Concurrent operations (`security_scanner` and `perf_analyzer`) updating simultaneously. |
| 05 | `05_tool_inspection` | Tool Call Inspection | "Fetch recent GitHub commits for davidpovarsky/StreamChatAI-iOS-Demo." | Technical inspector sheet with credential token redaction (`ghp_secretTokenExample123`). |
| 06 | `06_approval_accept` | Approval Card (Accept) | "Add Design Review to my calendar for Tuesday 10:30 AM." | Dedicated action card visible outside activity tree; tap "Approve". |
| 07 | `07_approval_deny` | Approval Card (Deny) | "Delete all completed tasks in Reminders." | Dedicated action card; tap "Decline" to cancel operation cleanly. |
| 08 | `08_tool_failure_retry` | Tool Failure & Retry | "Connect to live model endpoint." | Simulated 504 Gateway Timeout with error badge and retry action button. |
| 09 | `09_tool_cancel` | Tool Cancellation | "Start long database indexing." | User-initiated cancellation halts running animation immediately. |
| 10 | `10_markdown_streaming` | Markdown Streaming | "Show markdown syntax formatting." | Tables, code blocks, syntax highlighting, and bullet points parsed live. |
| 11 | `11_math_rtl` | LaTeX Math & Hebrew RTL | "הסבר על משוואת שרדינגר בעברית." | Mixed Hebrew RTL text containing embedded `$$i\hbar\frac{\partial}{\partial t}\Psi = \hat{H}\Psi$$` rendered via SwiftMath. |
| 12 | `12_images_svg` | Images & SVG Diagram | "Show the system architecture diagram and icon." | Native Kingfisher image caching and Exyte SVG vector diagram rendering. |
| 13 | `13_video_audio` | Inline Video & Audio Player | "Play tutorial video and audio recording." | Native AVKit video player and audio waveform scrubbing card. |
| 14 | `14_file_artifact` | File Artifact & Share Sheet | "Export the architecture spec as PDF." | Document download card with file size and native `ShareLink`. |
| 15 | `15_chart_interactions` | Interactive Swift Charts | "Analyze monthly token throughput." | Apple Swift Charts card with interactive Bar, Line, Area toggle and data totals. |
| 16 | `16_map_route` | Native MapKit Route | "Show route between Apple Park and Infinite Loop." | Native MapKit card with annotations, pins, and selected location details. |
| 17 | `17_native_form` | Interactive Form Calculator | "Calculate team subscription cost." | Dynamic interactive form with Sliders, Toggles, Segmented Pickers, and Submit button. |
| 18 | `18_canvas_revisions` | Canvas Document Revisions | "Revise paragraph 2 of the SDK overview." | Document diff card highlighting additions and deletions with accept/reject buttons. |
| 19 | `19_skills_mcp` | Discovered Tools & MCP | "Discover available Model Context Protocol (MCP) tools." | Discovered tools catalog displaying 6 connected MCP servers. |
| 20 | `20_health_reminders` | HealthKit & Reminders Cards | "Show my health summary and reminder list." | Domain-specific HealthKit metric ring and EventKit reminder list cards. |
| 21 | `21_voice_ui` | Realtime Voice Interface | "Start voice consultation mode." | Audio waveform animation and simulated ambient listening state transitions. |
| 22 | `22_rich_ui_miniapp` | Declarative MiniApp UI | "Display project dashboard mini app." | Sandboxed interactive multi-tab mini widget embedded in chat transcript. |
| 23 | `23_html_youtube_fallback` | External Video Fallback (Zero WebKit) | "Play external YouTube video." | Native SwiftUI preview thumbnail with external Safari `openURL` handoff (no WKWebView). |
| 24 | `24_multi_session` | Multi-Session Isolation | "Open a separate isolated session." | Verifies per-session state scoping without cross-session data leakage. |
| 25 | `25_stress_long_chat` | Stress Test: Long Chat | "Generate multiple turn conversation." | Exercises `LazyVStack` virtualization and anchor stability under rapid turns. |
| 26 | `26_permissions_errors` | Permissions & Error Recovery | "Request microphone permission." | Graceful error boundary displaying permission alert without crashing the app. |

---

## Playback Controls

In the Demo app, every scenario can be controlled using the top playback toolbar:
- **Play / Pause**: Halts or resumes virtual clock time.
- **Step**: Advances execution by exactly one event.
- **Speed**: Slider toggles between `0.5x`, `1.0x`, `2.0x`, and `5.0x` speeds.
- **Reset**: Clears session messages and resets state back to empty.
- **Composer Send**: In addition to selecting a scenario from the picker, users can type arbitrary prompts into the composer in Tab 1 ("Playground") to receive simulated streamed replies.
