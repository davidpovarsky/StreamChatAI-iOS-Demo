import Foundation
import Collections
import AsyncAlgorithms

/// A bounded thread-safe ring buffer for streaming chunks and activity event sequencing,
/// utilizing `Collections.Deque` and `AsyncAlgorithms` for debounced and chunked updates.
public final class AsyncEventBuffer<Element: Sendable>: @unchecked Sendable {
    private let capacity: Int
    private var deque: Deque<Element>
    private let channel = AsyncChannel<Element>()
    private let inputContinuation: AsyncStream<Element>.Continuation
    private var forwardingTask: Task<Void, Never>?
    private let lock = NSLock()

    public init(capacity: Int = 100) {
        self.capacity = capacity
        self.deque = Deque<Element>()
        let (stream, continuation) = AsyncStream.makeStream(of: Element.self)
        self.inputContinuation = continuation
        let channelRef = self.channel
        self.forwardingTask = Task {
            for await element in stream {
                await channelRef.send(element)
            }
        }
    }

    deinit {
        inputContinuation.finish()
        forwardingTask?.cancel()
    }

    public func append(_ element: Element) {
        lock.lock()
        if deque.count >= capacity {
            _ = deque.popFirst()
        }
        deque.append(element)
        lock.unlock()

        inputContinuation.yield(element)
    }

    public var allElements: [Element] {
        lock.lock()
        defer { lock.unlock() }
        return Array(deque)
    }

    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        deque.removeAll()
    }

    public var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return deque.count
    }

    /// Provides a debounced async stream of elements using `AsyncAlgorithms.debounce(for:)`
    /// to avoid UI stuttering during high-frequency token generation.
    public func debouncedStream(for duration: Duration = .milliseconds(50)) -> AsyncStream<Element> {
        let debounced = channel.debounce(for: duration)
        return AsyncStream { continuation in
            let task = Task {
                for await item in debounced {
                    continuation.yield(item)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    /// Provides a chunked async stream of elements using `AsyncAlgorithms.chunks(ofCount:)`.
    public func chunkedStream(count: Int = 5) -> AsyncStream<[Element]> {
        let chunked = channel.chunks(ofCount: count)
        return AsyncStream { continuation in
            let task = Task {
                for await chunk in chunked {
                    continuation.yield(Array(chunk))
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
