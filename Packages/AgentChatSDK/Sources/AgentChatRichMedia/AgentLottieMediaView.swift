#if canImport(SwiftUI)
import SwiftUI
#if canImport(Lottie)
import Lottie
#endif
#if canImport(Pow)
import Pow
#endif
import AgentChatCore

/// Additive vector animation view backed by `Lottie-spm` and subtle `Pow` transitions.
/// Respects accessibility Reduce Motion settings.
public struct AgentLottieMediaView: View {
    public let animationName: String
    public let isLooping: Bool
    public let isDarkMode: Bool
    public let size: CGSize

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        animationName: String,
        isLooping: Bool = true,
        isDarkMode: Bool = false,
        size: CGSize = CGSize(width: 80, height: 80)
    ) {
        self.animationName = animationName
        self.isLooping = isLooping
        self.isDarkMode = isDarkMode
        self.size = size
    }

    public var body: some View {
        Group {
            if reduceMotion {
                staticFallback
            } else {
                animatedView
            }
        }
        .frame(width: size.width, height: size.height)
    }

    @ViewBuilder
    private var animatedView: some View {
#if canImport(Lottie)
        LottieView(animation: .named(animationName))
            .playbackMode(isLooping ? .playing(.toProgress(1, loopMode: .loop)) : .playing(.toProgress(1, loopMode: .playOnce)))
            .resizable()
            .aspectRatio(contentMode: .fit)
#else
        staticFallback
#endif
    }

    private var staticFallback: some View {
        Image(systemName: "sparkles")
            .font(.system(size: min(size.width, size.height) * 0.5))
            .foregroundStyle(isDarkMode ? .cyan : .blue)
    }
}
#endif
