import SwiftUI

private enum WalkthroughStorageKeys {
    static let didShow = "flashdeck.didShowWalkthrough.v1"
    static let resetNonce = "flashdeck.appResetNonce"
}

private enum RootTab: Hashable {
    case decks
    case review
}

struct RootTabView: View {
    @AppStorage(WalkthroughStorageKeys.didShow) private var didShowWalkthrough = false
    @AppStorage(WalkthroughStorageKeys.resetNonce) private var appResetNonce = 0
    @State private var isShowingWalkthrough = false
    @State private var selection: RootTab = .decks

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tag(RootTab.decks)
                .tabItem {
                    Label("Decks", systemImage: "rectangle.grid.1x2.fill")
                }

            NavigationStack {
                MarkedCardsView()
            }
                .tag(RootTab.review)
                .tabItem {
                    Label("Review", systemImage: "bookmark.fill")
                }
        }
        .tint(AppTheme.accentColor(for: .custom))
        .task {
            guard didShowWalkthrough == false, isShowingWalkthrough == false else { return }
            isShowingWalkthrough = true
        }
        .onChange(of: didShowWalkthrough) { _, newValue in
            guard newValue == false else { return }
            guard isShowingWalkthrough == false else { return }
            isShowingWalkthrough = true
        }
        .onChange(of: appResetNonce) { _, _ in
            selection = .decks
            isShowingWalkthrough = true
        }
        .fullScreenCover(isPresented: $isShowingWalkthrough) {
            WalkthroughView {
                didShowWalkthrough = true
                isShowingWalkthrough = false
            }
        }
    }
}

struct RootTabView_Previews: PreviewProvider {
    static var previews: some View {
        let reviewStore = ReviewStore()
        let appViewModel = AppViewModel(reviewStore: reviewStore)
        let defaults = UserDefaults(suiteName: "RootTabViewPreview")!
        let appearanceStore = AppearanceStore(defaults: defaults)
        defaults.set(true, forKey: WalkthroughStorageKeys.didShow)

        return RootTabView()
            .environmentObject(reviewStore)
            .environmentObject(appViewModel)
            .environmentObject(appearanceStore)
            .defaultAppStorage(defaults)
    }
}

private struct WalkthroughPage: Identifiable {
    let id = UUID()
    let symbolName: String
    let eyebrow: String
    let title: String
    let detail: String
    let bullets: [String]
}

private struct WalkthroughView: View {
    let onFinish: () -> Void

    @State private var pageIndex = 0

    private let pages: [WalkthroughPage] = [
        WalkthroughPage(
            symbolName: "rectangle.grid.1x2.fill",
            eyebrow: "WELCOME",
            title: "Start from decks, not settings.",
            detail: "The Decks tab is the home base for built-in decks, custom imports, and quick return into your last session.",
            bullets: [
                "Tap any deck card to browse or study it.",
                "Use Continue to jump back into the last deck you opened.",
                "The bookmark tab is only for cards you flagged for another pass."
            ]
        ),
        WalkthroughPage(
            symbolName: "rectangle.portrait.on.rectangle.portrait.fill",
            eyebrow: "STUDY",
            title: "Cards are built for touch-first review.",
            detail: "Study mode keeps one card on screen at a time so review stays fast, with Actions available when you do not want to rely on gestures alone.",
            bullets: [
                "Tap a card to flip between the prompt and the answer.",
                "Swipe left or right to move through the current session.",
                "Mark a card when you want it to appear again in focused review."
            ]
        ),
        WalkthroughPage(
            symbolName: "sparkles",
            eyebrow: "ASSIST",
            title: "Assist stays grounded to the deck.",
            detail: "Explain, Compare, Quiz Me, and Feedback are scoped to the current card and use local deck knowledge instead of generic chat.",
            bullets: [
                "Import Deck JSON to add cards.",
                "Import Knowledge JSON to improve assist for an existing deck.",
                "Knowledge files do not create a new deck by themselves."
            ]
        ),
        WalkthroughPage(
            symbolName: "circle.lefthalf.filled",
            eyebrow: "PREFERENCES",
            title: "Adjust appearance without changing how you study.",
            detail: "Appearance controls stay separate so you can switch Light, Dark, Reading, or E-Ink styling without hunting through the More menu.",
            bullets: [
                "Use the paintbrush button on the home screen for Appearance.",
                "Use the More menu for import, export, About, and maintenance tasks.",
                "Everything important in this build works offline."
            ]
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(accentDeck: .custom)

                VStack(spacing: 24) {
                    HStack {
                        Text("\(pageIndex + 1) of \(pages.count)")
                            .font(.system(.footnote, design: .rounded).weight(.semibold))
                            .foregroundStyle(AppTheme.tertiaryText)

                        Spacer()

                        Button("Skip") {
                            onFinish()
                        }
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(AppTheme.secondaryText)
                    }

                    TabView(selection: $pageIndex) {
                        ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                            WalkthroughPageCard(page: page)
                                .tag(index)
                                .padding(.horizontal, 4)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))

                    HStack(spacing: 12) {
                        if pageIndex > 0 {
                            Button {
                                withAnimation(.easeInOut(duration: 0.24)) {
                                    pageIndex -= 1
                                }
                            } label: {
                                Text("Back")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(WalkthroughSecondaryButtonStyle())
                        }

                        Button {
                            if pageIndex == pages.count - 1 {
                                onFinish()
                            } else {
                                withAnimation(.easeInOut(duration: 0.24)) {
                                    pageIndex += 1
                                }
                            }
                        } label: {
                            Text(pageIndex == pages.count - 1 ? "Start Studying" : "Next")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(WalkthroughPrimaryButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 20)
            }
            .interactiveDismissDisabled()
        }
    }
}

private struct WalkthroughPageCard: View {
    let page: WalkthroughPage

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(AppTheme.secondarySurface)

                Image(systemName: page.symbolName)
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
            }
            .frame(width: 84, height: 84)

            VStack(alignment: .leading, spacing: 10) {
                Text(page.eyebrow)
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(AppTheme.tertiaryText)

                Text(page.title)
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundStyle(AppTheme.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Text(page.detail)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 12) {
                ForEach(page.bullets, id: \.self) { bullet in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(AppTheme.accentColor(for: .custom))
                            .frame(width: 8, height: 8)
                            .padding(.top, 6)

                        Text(bullet)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(AppTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(AppTheme.elevatedSurfaceGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.outlineGradient, lineWidth: 1)
        )
        .shadow(color: AppTheme.shadowColor.opacity(0.72), radius: 24, x: 0, y: 14)
    }
}

private struct WalkthroughPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded).weight(.bold))
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppTheme.accentColor(for: .custom).opacity(configuration.isPressed ? 0.78 : 1))
            )
            .foregroundStyle(Color.white)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

private struct WalkthroughSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded).weight(.semibold))
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppTheme.secondarySurface.opacity(configuration.isPressed ? 0.88 : 1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.outlineGradient, lineWidth: 1)
            )
            .foregroundStyle(AppTheme.primaryText)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
