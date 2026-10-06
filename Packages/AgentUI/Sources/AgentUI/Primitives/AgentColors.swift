//
//  AgentColors.swift
//  AgentUI
//

import SwiftUI
import UIKit

extension Color {
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    public static let agentAccentPrimary = Color(red: 16/255, green: 185/255, blue: 129/255)
    public static let agentBrandDark = Color(hex: "061820")
    public static let agentBrandLight = Color(hex: "EEF3F3")
    public static let agentBrandAccentDark = Color(hex: "004444")
    public static let agentBrandAccentLight = Color(hex: "68C7AC")

    public static let agentBackgroundPrimary = agentBrandDark
    public static let agentChatSurfaceDark = Color(hex: "2C2C2E")
    public static let agentChatSurfaceLight = Color(hex: "F2F2F7")
    public static let agentSidebarButtonBackgroundDark = Color(hex: "2C2C2E")
    public static let agentSidebarButtonBackgroundLight = Color.white
    public static let agentCardSurfaceDark = Color(hex: "1C1C1E")
    public static let agentCardSurfaceLight = Color.white
    public static let agentChatBackgroundDark = Color(hex: "121212")
    public static let agentChatBackgroundLight = Color.white
    public static let agentActionButtonBackgroundDark = Color.white.opacity(0.08)
    public static let agentActionButtonBackgroundLight = Color.black.opacity(0.05)
    public static let agentSidebarBackgroundDark = Color(hex: "121212")
    public static let agentSidebarBackgroundLight = Color.white
    public static let agentSettingsBackgroundDark = Color(hex: "121212")
    public static let agentSettingsBackgroundLight = Color(UIColor.systemGroupedBackground)
    public static let agentSendButtonBackgroundDark = agentBrandDark
    public static let agentSendButtonBackgroundLight = Color.white
    public static let agentSendButtonForegroundDark = Color.white
    public static let agentSendButtonForegroundLight = Color.black

    public static var sendButtonBackgroundDark: Color { agentSendButtonBackgroundDark }
    public static var sendButtonBackgroundLight: Color { agentSendButtonBackgroundLight }
    public static var sendButtonForegroundDark: Color { agentSendButtonForegroundDark }
    public static var sendButtonForegroundLight: Color { agentSendButtonForegroundLight }
    public static var chatSurfaceDark: Color { agentChatSurfaceDark }
    public static var chatSurfaceLight: Color { agentChatSurfaceLight }
    public static var chatBackgroundDark: Color { agentChatBackgroundDark }
    public static var chatBackgroundLight: Color { agentChatBackgroundLight }
    public static var accentPrimary: Color { agentAccentPrimary }
    public static var backgroundPrimary: Color { agentBackgroundPrimary }
    public static var brandDark: Color { agentBrandDark }
    public static var brandLight: Color { agentBrandLight }
    public static var brandAccentDark: Color { agentBrandAccentDark }
    public static var brandAccentLight: Color { agentBrandAccentLight }

    public static func chatSurface(isDarkMode: Bool) -> Color {
        agentChatSurface(isDarkMode: isDarkMode)
    }

    public static func chatBackground(isDarkMode: Bool) -> Color {
        agentChatBackground(isDarkMode: isDarkMode)
    }

    public static func thinkingBackground(isDarkMode: Bool) -> Color {
        agentThinkingBackground(isDarkMode: isDarkMode)
    }

    public static func userMessageBackground(isDarkMode: Bool) -> Color {
        agentUserMessageBackground(isDarkMode: isDarkMode)
    }

    public static func userMessageForeground(isDarkMode: Bool) -> Color {
        agentUserMessageForeground(isDarkMode: isDarkMode)
    }

    public static func actionButtonBackground(isDarkMode: Bool) -> Color {
        agentActionButtonBackground(isDarkMode: isDarkMode)
    }

    public static let agentThinkingBackgroundDark = agentChatSurfaceDark
    public static let agentThinkingBackgroundLight = agentChatSurfaceLight
    public static let agentUserMessageBackgroundDark = agentChatSurfaceDark
    public static let agentUserMessageBackgroundLight = agentChatSurfaceLight
    public static let agentUserMessageForegroundDark = Color.white
    public static let agentUserMessageForegroundLight = Color.black

    public static func agentChatSurface(isDarkMode: Bool) -> Color {
        isDarkMode ? agentChatSurfaceDark : agentChatSurfaceLight
    }

    public static func agentChatBackground(isDarkMode: Bool) -> Color {
        isDarkMode ? agentChatBackgroundDark : agentChatBackgroundLight
    }

    public static func agentThinkingBackground(isDarkMode: Bool) -> Color {
        isDarkMode ? agentThinkingBackgroundDark : agentThinkingBackgroundLight
    }

    public static func agentUserMessageBackground(isDarkMode: Bool) -> Color {
        isDarkMode ? agentUserMessageBackgroundDark : agentUserMessageBackgroundLight
    }

    public static func agentUserMessageForeground(isDarkMode: Bool) -> Color {
        isDarkMode ? agentUserMessageForegroundDark : agentUserMessageForegroundLight
    }

    public static func agentActionButtonBackground(isDarkMode: Bool) -> Color {
        isDarkMode ? agentActionButtonBackgroundDark : agentActionButtonBackgroundLight
    }
}
