# AgentUI Quick Start Guide

`AgentUI` is a standalone, reusable Swift Package that encapsulates the complete, approved UI layer of the SwiftChat client without altering any visual invariants, Liquid Glass geometries, animations, or system presentations.

## Package Integration

Add `AgentUI` as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(path: "Packages/AgentUI")
]
```

Or reference it in your Xcode project via **Package Dependencies**.

## Architecture & Reusable Surfaces

`AgentUI` exposes modular UI layers:

1. **Top-Level Shell / Container (`AgentChatView`)**:
   Provides the navigation split view, compact / regular size-class transitions, and navigation bar material appearances.

2. **Sidebar Session Navigation (`AgentChatSidebarView`)**:
   Provides session listing, swipe-to-delete, inline rename dialogs, search filtering, and the exact 300 pt width geometry.

3. **Message List (`AgentMessageListView`)**:
   Provides lazy scrolling message presentation, safe-area inset composer placement, iPad 600 pt width clamping, and the native `.buttonStyle(.glass)` scroll-to-bottom control.

4. **Message Presentation (`AgentMessageView`)**:
   Renders user and assistant messages, thinking/reasoning blocks, web search status boxes, URL fetch boxes, multi-part rich media (images, videos, YouTube), LaTeX math, and citation clusters.

5. **Composer (`AgentComposerView`)**:
   Renders the iOS 26 Liquid Glass composer with `RoundedRectangle(cornerRadius: 26)`, circular action buttons, pulsing voice recording, model selection menu, attachment previews, and multimodal pickers.

## Example Consumption

```swift
import SwiftUI
import AgentUI

struct ContentView: View {
    @StateObject private var driver = CustomAgentDriver()
    @State private var messageText = ""

    var body: some View {
        AgentChatView(
            sidebar: {
                AgentChatSidebarView(
                    sessions: driver.sessions,
                    currentSessionId: driver.currentSessionId,
                    onSelectSession: { driver.selectSession($0) },
                    onDeleteSession: { driver.deleteSession(id: $0) },
                    onRenameSession: { driver.renameSession(id: $0, newTitle: $1) },
                    onCreateNewSession: { driver.createNewSession() }
                )
            },
            detail: {
                AgentMessageListView(
                    isDarkMode: false,
                    messageCount: driver.messages.count,
                    messageContent: {
                        ForEach(driver.messages) { message in
                            AgentMessageView(
                                id: message.id,
                                role: message.role,
                                content: message.content,
                                thoughts: message.thoughts,
                                isThinking: message.isThinking,
                                isDarkMode: false,
                                webSearchState: message.webSearchState,
                                attachments: message.attachments,
                                contentParts: message.contentParts,
                                onCopy: { UIPasteboard.general.string = message.content }
                            )
                        }
                    },
                    composerContent: {
                        AgentComposerView(
                            messageText: $messageText,
                            driver: driver
                        )
                    }
                )
            }
        )
    }
}
```
