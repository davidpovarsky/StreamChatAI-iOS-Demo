import SwiftUI

// MARK: - Message & Card Transitions

public struct AgentMessageEntranceModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.agentMotionPolicy) private var motionPolicy
    @State private var isAppeared = false

    public init() {}

    public var isMotionReduced: Bool {
        motionPolicy.effectiveReduceMotion(systemReduceMotion: systemReduceMotion)
    }

    public func body(content: Content) -> some View {
        content
            .opacity(isAppeared ? 1 : (isMotionReduced ? 0.3 : 0))
            .offset(y: isAppeared || isMotionReduced ? 0 : 8)
            .onAppear {
                if isMotionReduced {
                    isAppeared = true
                } else {
                    withAnimation(AgentMotionTokens.snappySpring) {
                        isAppeared = true
                    }
                }
            }
    }
}

public struct AgentCardEntranceModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.agentMotionPolicy) private var motionPolicy
    @State private var isAppeared = false

    public init() {}

    public var isMotionReduced: Bool {
        motionPolicy.effectiveReduceMotion(systemReduceMotion: systemReduceMotion)
    }

    public func body(content: Content) -> some View {
        content
            .opacity(isAppeared ? 1 : 0)
            .scaleEffect(isAppeared || isMotionReduced ? 1.0 : 0.98)
            .onAppear {
                if isMotionReduced {
                    withAnimation(.easeOut(duration: 0.12)) {
                        isAppeared = true
                    }
                } else {
                    withAnimation(AgentMotionTokens.standardSpring) {
                        isAppeared = true
                    }
                }
            }
    }
}

// MARK: - One-Shot Shake on Error

public struct AgentShakeEffect: GeometryEffect {
    public var amount: CGFloat = 8
    public var shakesPerUnit: CGFloat = 3
    public var animatableData: CGFloat

    public init(shakes: CGFloat, amount: CGFloat = 8) {
        self.animatableData = shakes
        self.amount = amount
    }

    public func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * shakesPerUnit),
            y: 0
        ))
    }
}

// MARK: - Skeleton Shimmer

public struct AgentShimmerModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.agentMotionPolicy) private var motionPolicy
    @State private var phase: CGFloat = 0

    public var isMotionReduced: Bool {
        motionPolicy.effectiveReduceMotion(systemReduceMotion: systemReduceMotion)
    }

    public init() {}

    public func body(content: Content) -> some View {
        if isMotionReduced {
            content.opacity(0.8)
        } else {
            content
                .overlay(
                    GeometryReader { geo in
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.white.opacity(0.2),
                                Color.clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geo.size.width * 2)
                        .offset(x: -geo.size.width + (geo.size.width * 2 * phase))
                    }
                )
                .mask(content)
                .onAppear {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
        }
    }
}

// MARK: - View Extensions

public extension View {
    func agentMessageEntrance() -> some View {
        modifier(AgentMessageEntranceModifier())
    }

    func agentCardEntrance() -> some View {
        modifier(AgentCardEntranceModifier())
    }

    func agentShimmer() -> some View {
        modifier(AgentShimmerModifier())
    }

    func agentShake(trigger: CGFloat) -> some View {
        modifier(AgentShakeEffect(shakes: trigger))
    }
}
