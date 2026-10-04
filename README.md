# StreamChatAI iOS Demo

A tiny iOS demo of GetStream's `StreamChatAI` Swift package.

The app uses the real `StreamingMessageView`, `AITypingIndicatorView`, and `ComposerView` components from:
https://github.com/GetStream/stream-chat-swift-ai

No API key or backend is required. Replies are simulated locally so the UI can be tested immediately.

## Build
GitHub Actions builds an unsigned device IPA and uploads it as the `StreamChatAI-Demo-IPA` artifact.

Target: iOS 16+
