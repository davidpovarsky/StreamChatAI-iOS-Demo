import SwiftUI
import AgentChatSDK

public struct MotionLabView: View {
    @State private var reduceMotionOverride = false
    @State private var triggerShake: CGFloat = 0
    @State private var isCardVisible = true

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Section("Accessibility & Policy") {
                    Toggle("Force Reduce Motion", isOn: $reduceMotionOverride)
                        .tint(.blue)
                }

                Section("Micro-Animations") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Thinking Dots Indicator")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        AgentThinkingIndicator()
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("2. Loading Skeleton Shimmer")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.15))
                            .frame(height: 36)
                            .agentShimmer()
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("3. One-Shot Error Shake")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            Text("Validation Failed")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.red)
                                .padding(8)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color.red.opacity(0.1)))
                                .agentShake(trigger: triggerShake)

                            Spacer()

                            Button("Trigger Shake") {
                                withAnimation(AgentMotionTokens.snappySpring) {
                                    triggerShake += 1
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("4. Card Entrance Spring")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            if isCardVisible {
                                Text("Native Entrance Transition")
                                    .font(.system(size: 13, weight: .medium))
                                    .padding(8)
                                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue.opacity(0.12)))
                                    .agentCardEntrance()
                            }
                            Spacer()
                            Button("Replay") {
                                isCardVisible = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isCardVisible = true
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Motion Lab")
            .navigationBarTitleDisplayMode(.inline)
            .environment(\.agentMotionPolicy, AgentMotionPolicy(forceReduceMotion: reduceMotionOverride))
        }
    }
}
