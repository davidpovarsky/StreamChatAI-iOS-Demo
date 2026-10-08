#if canImport(Network)
import Network
#endif
#if canImport(Combine)
import Combine
#endif
import SwiftUI

@MainActor
class NetworkMonitor: ObservableObject {
    @Published private(set) var isConnected = true
#if canImport(Network)
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
#else
    init() {}
#endif
}
