//
//  ChatView.swift
//  SwiftChat
//
//  Created on 03/25/26.
//  Copyright © 2026 Sacha Servan-Schreiber. All rights reserved.
//


import SwiftUI


// MARK: - ChatContainer

/// The primary SwiftUI container that holds the main chat interface and sidebar navigation using NavigationSplitView.
public struct ChatContainer: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject public var viewModel: ChatViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject private var settings = SettingsManager.shared

    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic
    @State private var preferredCompactColumn: NavigationSplitViewColumn = .detail
    @State private var messageText = ""

    public init() {}

    private var toolbarContentColor: Color {
        colorScheme == .dark ? Color.white : Color.black
    }

    var body: some View {
        NavigationSplitView(
            columnVisibility: $columnVisibility,
            preferredCompactColumn: $preferredCompactColumn
        ) {
            sidebar
        } detail: {
            detailColumn
        }
        .environmentObject(viewModel)
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
        .onChange(of: viewModel.currentChat?.id) { _, _ in
            if horizontalSizeClass == .compact {
                columnVisibility = .detailOnly
                preferredCompactColumn = .detail
            }
        }
        .fullScreenCover(isPresented: $viewModel.showImageViewer) {
            ImageViewerOverlay(
                images: viewModel.imageViewerImages,
                initialIndex: viewModel.imageViewerIndex,
                onDismiss: { viewModel.showImageViewer = false }
            )
        }
    }

    private var sidebar: some View {
        VStack(spacing: 0) {
            if horizontalSizeClass == .compact {
                Button(action: createNewChat) {
                    Label("New Chat", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .accessibilityLabel("New Chat")
                .accessibilityIdentifier("new-chat-button")
            }

            ChatSidebar(viewModel: viewModel)
        }
        .navigationTitle("Chats")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: createNewChat) {
                    Label("New Chat", systemImage: "plus")
                }
                .accessibilityLabel("New Chat")
                .accessibilityIdentifier("new-chat-button")
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }

    private var detailColumn: some View {
        ChatListView(
            isDarkMode: colorScheme == .dark,
            isLoading: viewModel.isLoading,
            viewModel: viewModel,
            messageText: $messageText
        )
        .background(Color.chatBackground(isDarkMode: colorScheme == .dark))
        .navigationTitle(viewModel.currentChat?.title ?? "SwiftChat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if horizontalSizeClass == .compact {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        preferredCompactColumn = .sidebar
                    } label: {
                        Label("Show Sidebar", systemImage: "sidebar.leading")
                    }
                    .accessibilityLabel("Show Sidebar")
                    .accessibilityIdentifier("show-sidebar-button")
                }
            }

            if !(viewModel.currentChat?.isBlankChat ?? true) {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: createNewChat) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(toolbarContentColor)
                    }
                }
            }
        }
    }

    private func createNewChat() {
        let language = settings.selectedLanguage == "System" ? nil : settings.selectedLanguage
        viewModel.createNewChat(language: language)
        messageText = ""
        if horizontalSizeClass == .compact {
            columnVisibility = .detailOnly
            preferredCompactColumn = .detail
        }
    }

    private func setupNavigationBarAppearance() {
        if #available(iOS 26, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.shadowColor = .clear
            updateAllNavigationBars(with: appearance)
        } else {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = colorScheme == .dark ? UIColor(Color.backgroundPrimary) : .white
            appearance.shadowColor = .clear
            updateAllNavigationBars(with: appearance)
        }
    }

    private func updateAllNavigationBars(with appearance: UINavigationBarAppearance) {
        let tintColor: UIColor = colorScheme == .dark ? .white : .black
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = tintColor
    }
}

// MARK: - WelcomeView

struct WelcomeView: View {
    let isDarkMode: Bool

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("Start a conversation")
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
        }
        .padding(.top, 24)
        .padding(.bottom, 4)
    }
}

// MARK: - Helper Views

/// Animated button that transforms between a menu icon and an X
struct MenuToXButton: View {
    let isX: Bool

    var body: some View {
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

/// A shape for custom corner rounding
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

/// Extension for applying rounded corners to views
extension View {
    func corners(_ corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: 15, corners: corners))
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

// Helper extension to convert UIView.AnimationCurve to SwiftUI Animation
extension Animation {
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
