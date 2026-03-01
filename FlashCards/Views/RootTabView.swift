import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Decks", systemImage: "rectangle.grid.1x2.fill")
                }

            NavigationStack {
                MarkedCardsView()
            }
                .tabItem {
                    Label("Review", systemImage: "bookmark.fill")
                }
        }
        .tint(Color(red: 0.21, green: 0.48, blue: 0.93))
    }
}

struct RootTabView_Previews: PreviewProvider {
    static var previews: some View {
        let reviewStore = ReviewStore()
        let appViewModel = AppViewModel(reviewStore: reviewStore)

        return RootTabView()
            .environmentObject(reviewStore)
            .environmentObject(appViewModel)
    }
}
