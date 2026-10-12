import SwiftUI

public struct AgentThinkingIndicator: View {
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.agentMotionPolicy) private var motionPolicy
    @Environment(\.scenePhase) private var scenePhase
    @State private var phase: Int = 0

    private let dotCount = 3
    private let dotSize: CGFloat = 6
    private let spacing: CGFloat = 4

    public init() {}

    public var isMotionReduced: Bool {
        motionPolicy.effectiveReduceMotion(systemReduceMotion: systemReduceMotion)
    }

    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<dotCount, id: \.self) { index in
                Circle()
                    .fill(Color.secondary)
                    .frame(width: dotSize, height: dotSize)
                    .opacity(isMotionReduced ? 0.6 : (phase == index ? 1.0 : 0.3))
                    .scaleEffect(isMotionReduced ? 1.0 : (phase == index ? 1.15 : 0.85))
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .onAppear {
            guard !isMotionReduced && scenePhase == .active else { return }
            startAnimation()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active && !isMotionReduced {
                startAnimation()
            }
        }
    }

    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            guard scenePhase == .active else {
                timer.invalidate()
                return
            }
            withAnimation(.easeInOut(duration: 0.25)) {
                phase = (phase + 1) % dotCount
            }
        }
    }
}
