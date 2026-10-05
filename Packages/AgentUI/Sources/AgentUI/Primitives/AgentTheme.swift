//
//  AgentTheme.swift
//  AgentUI
//

import SwiftUI

public enum AgentTheme {
    public enum Dimensions {
        public static let sidebarWidth: CGFloat = 300
        public static let paddingExtraSmall: CGFloat = 4
        public static let paddingSmall: CGFloat = 8
        public static let paddingMedium: CGFloat = 12
        public static let paddingLarge: CGFloat = 16
        public static let paddingExtraLarge: CGFloat = 24

        public static let cornerRadiusSmall: CGFloat = 8
        public static let cornerRadiusMedium: CGFloat = 12
        public static let cornerRadiusLarge: CGFloat = 16
    }

    public enum Animations {
        public static let defaultDuration: Double = 0.25
        public static let mediumDuration: Double = 0.3
        public static let longDuration: Double = 0.6
        public static let copyFeedbackDuration: Double = 1.5

        public static let springResponse: Double = 0.3
        public static let springDamping: Double = 0.75
        public static let springResponseFast: Double = 0.2
        public static let springDampingHigh: Double = 0.9
    }
}
