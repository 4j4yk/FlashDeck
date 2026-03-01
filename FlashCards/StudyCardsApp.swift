import SwiftUI

@main
struct StudyCardsApp: App {
    @StateObject private var reviewStore: ReviewStore
    @StateObject private var appViewModel: AppViewModel

    init() {
        let reviewStore = ReviewStore()
        _reviewStore = StateObject(wrappedValue: reviewStore)
        _appViewModel = StateObject(wrappedValue: AppViewModel(reviewStore: reviewStore))
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(reviewStore)
                .environmentObject(appViewModel)
        }
    }
}
