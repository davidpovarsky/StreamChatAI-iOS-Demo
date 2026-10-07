import Foundation
import Collections
import AsyncAlgorithms

/// A bounded thread-safe ring buffer for streaming chunks and activity event sequencing,
/// utilizing `Collections.Deque` and `AsyncAlgorithms` for debounced updates.
public final class AsyncEventBuffer<Element: Sendable>: @unchecked Sendable {
    private let capacity: Int
    private var deque: Deque<Element>
    private let lock = NSLock()

    public init(capacity: Int = 100) {
        self.capacity = capacity
        self.deque = Deque<Element>()
    }

    public func append(_ element: Element) {
        lock.lock()
        defer { lock.unlock() }
        if deque.count >= capacity {
            _ = deque.popFirst()
        }
        deque.append(element)
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
}
