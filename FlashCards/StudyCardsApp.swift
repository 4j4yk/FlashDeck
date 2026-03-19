import SwiftUI
import UIKit

@main
struct StudyCardsApp: App {
    @StateObject private var reviewStore: ReviewStore
    @StateObject private var appViewModel: AppViewModel
    @StateObject private var appearanceStore: AppearanceStore

    init() {
        let reviewStore = ReviewStore()
        _reviewStore = StateObject(wrappedValue: reviewStore)
        _appViewModel = StateObject(wrappedValue: AppViewModel(reviewStore: reviewStore))
        _appearanceStore = StateObject(wrappedValue: AppearanceStore.shared)
        Self.configureTabBarAppearance()
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(reviewStore)
                .environmentObject(appViewModel)
                .environmentObject(appearanceStore)
                .preferredColorScheme(appearanceStore.preferredColorScheme)
                .task(id: appearanceStore.renderKey) {
                    Self.configureTabBarAppearance()
                }
        }
    }

    private static func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = AppTheme.usesTabBarBlur ? UIBlurEffect(style: .systemUltraThinMaterial) : nil
        appearance.backgroundColor = AppTheme.tabBarBackgroundColor
        appearance.shadowColor = AppTheme.tabBarShadowUIColor

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
