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
            updateAllNavigationBars(with: appearance)
        } else {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = isDarkMode ? UIColor(Color.agentBrandDark) : .white
            appearance.shadowColor = .clear
            updateAllNavigationBars(with: appearance)
        }
    }

    private func setupNavigationBarAppearance() {
        Self.setupNavigationBarAppearance(isDarkMode: colorScheme == .dark)
    }

    private static func updateAllNavigationBars(with appearance: UINavigationBarAppearance) {
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        if #available(iOS 15.0, *) {
            UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
        }
    }
}
