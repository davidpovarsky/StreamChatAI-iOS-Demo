#if canImport(SwiftUI)
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

extension Color {
    // Accent colors
    public static let accentPrimary = Color(red: 16/255, green: 185/255, blue: 129/255) // #10B981

    // Brand colors
    public static let brandDark = Color(hex: "061820")
    public static let brandLight = Color(hex: "EEF3F3")
    public static let brandAccentDark = Color(hex: "004444")
    public static let brandAccentLight = Color(hex: "68C7AC")

    // App surface colors
    public static let backgroundPrimary = Color.brandDark
    public static let chatSurfaceDark = Color(hex: "2C2C2E")
    public static let chatSurfaceLight = Color(hex: "F2F2F7")
    public static let sidebarButtonBackgroundDark = Color(hex: "2C2C2E")
    public static let sidebarButtonBackgroundLight = Color.white
    public static let cardSurfaceDark = Color(hex: "1C1C1E")
    public static let cardSurfaceLight = Color.white
    public static let chatBackgroundDark = Color(hex: "121212")
    public static let chatBackgroundLight = Color.white
    public static let actionButtonBackgroundDark = Color.white.opacity(0.08)
    public static let actionButtonBackgroundLight = Color.black.opacity(0.05)
    public static let sidebarBackgroundDark = Color(hex: "121212")
    public static let sidebarBackgroundLight = Color.white
    public static let settingsBackgroundDark = Color(hex: "121212")
#if canImport(UIKit)
    public static let settingsBackgroundLight = Color(UIColor.systemGroupedBackground)
#else
    public static let settingsBackgroundLight = Color(hex: "F2F2F7")
#endif
    public static let sendButtonBackgroundDark = Color.brandDark
    public static let sendButtonBackgroundLight = Color.white
    public static let sendButtonForegroundDark = Color.white
    public static let sendButtonForegroundLight = Color.black

    // Reasoning and messaging surfaces
    public static let thinkingBackgroundDark = chatSurfaceDark
    public static let thinkingBackgroundLight = chatSurfaceLight
    public static let userMessageBackgroundDark = chatSurfaceDark
    public static let userMessageBackgroundLight = chatSurfaceLight
    public static let userMessageForegroundDark = Color.white
    public static let userMessageForegroundLight = Color.black

    // Adaptive accent color
#if canImport(UIKit)
    public static let adaptiveAccent = Color(UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            return .white
        } else {
            return UIColor(Color.accentPrimary)
        }
    })
#else
    public static let adaptiveAccent = Color.white
#endif

    // Convenience helpers for common surfaces
    public static func chatSurface(isDarkMode: Bool) -> Color {
        isDarkMode ? chatSurfaceDark : chatSurfaceLight
    }

    public static func sidebarButtonBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? sidebarButtonBackgroundDark : sidebarButtonBackgroundLight
    }

    public static func cardSurface(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? cardSurfaceDark : cardSurfaceLight
    }

    public static func chatBackground(isDarkMode: Bool) -> Color {
        isDarkMode ? chatBackgroundDark : chatBackgroundLight
    }

    public static func sidebarBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? sidebarBackgroundDark : sidebarBackgroundLight
    }

    public static func settingsBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? settingsBackgroundDark : settingsBackgroundLight
    }

    public static func thinkingBackground(isDarkMode: Bool) -> Color {
        isDarkMode ? thinkingBackgroundDark : thinkingBackgroundLight
    }

    public static func userMessageBackground(isDarkMode: Bool) -> Color {
        isDarkMode ? userMessageBackgroundDark : userMessageBackgroundLight
    }

    public static func userMessageForeground(isDarkMode: Bool) -> Color {
        isDarkMode ? userMessageForegroundDark : userMessageForegroundLight
    }

    public static func actionButtonBackground(isDarkMode: Bool) -> Color {
        isDarkMode ? actionButtonBackgroundDark : actionButtonBackgroundLight
    }
}
#endif
