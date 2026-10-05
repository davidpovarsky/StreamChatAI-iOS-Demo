# Runtime Adapter Guide

## Protocol Definition

```swift
@MainActor
public protocol AgentUIRuntimeAdapter: AnyObject, Sendable {
    func send(_ request: AgentSendRequest) -> AsyncThrowingStream<AgentUIEvent, Error>
    func cancel(requestID: AgentRequestID) async
}
```

## Emitting Events

Host applications yield events during the lifecycle of an agent turn:

1. `.requestStarted(requestID)`
2. `.assistantMessageStarted(messageID)`
3. `.activityStarted(messageID, item)` (reasoning or search progress)
4. `.toolStarted(messageID, execution)`
5. `.toolCompleted(messageID, toolCallID, resultSummary)`
6. `.sourceDiscovered(messageID, source)`
7. `.assistantTextDelta(messageID, text)` (yielded incrementally)
8. `.requestCompleted(requestID)`

### One-Time Auto-Collapse
The first `.assistantTextDelta` token causes the active activity timeline to auto-collapse exactly once into the summary ("Worked for Xs"). If the user manually re-opens the timeline, subsequent text tokens do not force it closed.
