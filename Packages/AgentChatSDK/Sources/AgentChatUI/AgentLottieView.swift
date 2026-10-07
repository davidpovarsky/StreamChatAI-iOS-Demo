#if canImport(SwiftUI)
import AgentChatCore
import SwiftUI
#if canImport(Lottie)
import Lottie
#endif

public struct AgentLottieView: View {
    public let name: String
    public let loopMode: Bool
    public let fallbackSystemIcon: String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(name: String, loopMode: Bool = false, fallbackSystemIcon: String = "checkmark.circle.fill") {
        self.name = name
        self.loopMode = loopMode
        self.fallbackSystemIcon = fallbackSystemIcon
    }

    public var body: some View {
        if reduceMotion {
            fallbackIcon
        } else {
            #if canImport(Lottie)
            LottieView(animation: .named(name))
                .playing(loopMode: loopMode ? .loop : .playOnce)
                .frame(width: 48, height: 48)
            #else
            fallbackIcon
            #endif
        }
    }

    private var fallbackIcon: some View {
        Image(systemName: fallbackSystemIcon)
            .font(.system(size: 28))
            .foregroundStyle(.green)
    }
}
#endif
