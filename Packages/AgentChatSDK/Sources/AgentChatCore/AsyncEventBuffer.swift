import Foundation
import Collections
import AsyncAlgorithms

/// A bounded thread-safe ring buffer for streaming chunks and activity event sequencing,
/// utilizing `Collections.Deque` and `AsyncAlgorithms` for debounced updates.
public final class AsyncEventBuffer<Element: Sendable>: @unchecked Sendable {
    private let capacity: Int
    private var deque: Deque<Element>
    private let channel = AsyncChannel<Element>()
    private let lock = NSLock()

    public init(capacity: Int = 100) {
        self.capacity = capacity
        self.deque = Deque<Element>()
    }

    public func append(_ element: Element) {
        lock.lock()
        if deque.count >= capacity {
            _ = deque.popFirst()
        }
        deque.append(element)
        lock.unlock()

        Task { [channel] in
            await channel.send(element)
        }
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
    public func debouncedStream(for duration: Duration = .milliseconds(50)) -> some AsyncSequence {
        channel.debounce(for: duration)
    }

    /// Provides a chunked async stream of elements using `AsyncAlgorithms.chunks(ofCount:)`.
    public func chunkedStream(count: Int = 5) -> some AsyncSequence {
        channel.chunks(ofCount: count)
    }
}
