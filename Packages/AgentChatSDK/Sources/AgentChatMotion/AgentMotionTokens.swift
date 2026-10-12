import SwiftUI

// MARK: - Motion Policy

public struct AgentMotionPolicy: Sendable, Equatable {
    public var forceReduceMotion: Bool?

    public init(forceReduceMotion: Bool? = nil) {
        self.forceReduceMotion = forceReduceMotion
    }

    public func effectiveReduceMotion(systemReduceMotion: Bool) -> Bool {
        forceReduceMotion ?? systemReduceMotion
    }
}

// MARK: - Motion Environment Key

private struct AgentMotionPolicyKey: EnvironmentKey {
    static let defaultValue = AgentMotionPolicy()
}

public extension EnvironmentValues {
    var agentMotionPolicy: AgentMotionPolicy {
        get { self[AgentMotionPolicyKey.self] }
        set { self[AgentMotionPolicyKey.self] = newValue }
    }
}

// MARK: - Design Motion Tokens

public enum AgentMotionTokens {
    // Timing durations
    public static let fastDuration: Double = 0.16
    public static let standardDuration: Double = 0.22
    public static let deliberateDuration: Double = 0.28
    public static let layoutDuration: Double = 0.32

    // Springs
    public static let standardSpring = Animation.spring(response: 0.24, dampingFraction: 0.82)
    public static let snappySpring = Animation.snappy(duration: 0.20, extraBounce: 0.05)
    public static let smoothSpring = Animation.smooth(duration: 0.26)
    public static let interactiveSpring = Animation.interactiveSpring(response: 0.22, dampingFraction: 0.86)

    // Fade / Opacity
    public static let quickFade = Animation.easeOut(duration: fastDuration)
    public static let standardFade = Animation.easeInOut(duration: standardDuration)

    // Heights and Reveals
    public static let disclosureAnimation = standardSpring
    public static let cardEntranceAnimation = snappySpring
    public static let composerHeightAnimation = smoothSpring

    // Helper to evaluate animation respecting reduce motion
    public static func animation(
        _ base: Animation,
        reduceMotion: Bool,
        reducedFallback: Animation? = nil
    ) -> Animation? {
        if reduceMotion {
            return reducedFallback ?? .easeOut(duration: 0.12)
        }
        return base
    }
}
