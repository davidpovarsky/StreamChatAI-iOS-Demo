//
//  AgentChatView.swift
//  AgentUI
//
//  Extracted top-level chat container and shell entry point for the reusable AgentUI package.
//

import SwiftUI
import UIKit

public struct AgentChatView<SidebarContent: View, DetailContent: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Binding public var columnVisibility: NavigationSplitViewVisibility
    @Binding public var preferredCompactColumn: NavigationSplitViewColumn

    @ViewBuilder public let sidebar: () -> SidebarContent
    @ViewBuilder public let detail: () -> DetailContent

    public init(
        columnVisibility: Binding<NavigationSplitViewVisibility>? = nil,
        preferredCompactColumn: Binding<NavigationSplitViewColumn>? = nil,
        @ViewBuilder sidebar: @escaping () -> SidebarContent,
        @ViewBuilder detail: @escaping () -> DetailContent
    ) {
        self._columnVisibility = columnVisibility ?? .constant(.automatic)
        self._preferredCompactColumn = preferredCompactColumn ?? .constant(.detail)
        self.sidebar = sidebar
        self.detail = detail
    }

    public var body: some View {
        NavigationSplitView(
            columnVisibility: $columnVisibility,
            preferredCompactColumn: $preferredCompactColumn
        ) {
            sidebar()
        } detail: {
            detail()
        }
        .onAppear {
            if horizontalSizeClass == .compact {
                columnVisibility = .detailOnly
                preferredCompactColumn = .detail
            }
            setupNavigationBarAppearance()
        }
        .onChange(of: colorScheme) { _, _ in
            setupNavigationBarAppearance()
        }
    }

    public static func setupNavigationBarAppearance(isDarkMode: Bool) {
        if #available(iOS 26, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.shadowColor = .clear
            updateAllNavigationBars(with: appearance, isDarkMode: isDarkMode)
        } else {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = isDarkMode ? UIColor(Color.agentBrandDark) : .white
            appearance.shadowColor = .clear
            updateAllNavigationBars(with: appearance, isDarkMode: isDarkMode)
        }
    }

    private func setupNavigationBarAppearance() {
        Self.setupNavigationBarAppearance(isDarkMode: colorScheme == .dark)
    }

    private static func updateAllNavigationBars(with appearance: UINavigationBarAppearance, isDarkMode: Bool) {
        let tintColor: UIColor = isDarkMode ? .white : .black
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        if #available(iOS 15.0, *) {
            UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
        }
        UINavigationBar.appearance().tintColor = tintColor
    }
}

// MARK: - AgentMenuToXButton

public struct AgentMenuToXButton: View {
    public let isX: Bool

    public init(isX: Bool) {
        self.isX = isX
    }

    public var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 18, height: 2)
                .rotationEffect(.degrees(isX ? 45 : 0))
                .offset(y: isX ? 0 : -6)
            Rectangle()
                .frame(width: 18, height: 2)
                .opacity(isX ? 0 : 1)
            Rectangle()
                .frame(width: 18, height: 2)
                .rotationEffect(.degrees(isX ? -45 : 0))
                .offset(y: isX ? 0 : 6)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isX)
    }
}

// MARK: - AgentRoundedCorner

public struct AgentRoundedCorner: Shape {
    public var radius: CGFloat = .infinity
    public var corners: UIRectCorner = .allCorners

    public init(radius: CGFloat = .infinity, corners: UIRectCorner = .allCorners) {
        self.radius = radius
        self.corners = corners
    }

    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Shell Extensions

public extension View {
    func corners(_ corners: UIRectCorner) -> some View {
        clipShape(AgentRoundedCorner(radius: 15, corners: corners))
    }

    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder
    func applyTransparentToolbarIfAvailable() -> some View {
        if #available(iOS 26, *) {
            self.toolbarBackground(.hidden, for: .navigationBar)
        } else {
            self
        }
    }
}

public extension Animation {
    init(curve: UIView.AnimationCurve, duration: Double) {
        switch curve {
        case .easeInOut:
            self = .easeInOut(duration: duration)
        case .easeIn:
            self = .easeIn(duration: duration)
        case .easeOut:
            self = .easeOut(duration: duration)
        case .linear:
            self = .linear(duration: duration)
        @unknown default:
            self = .easeInOut(duration: duration)
        }
    }
}
