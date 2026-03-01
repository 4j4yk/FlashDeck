import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(accentDeck: appViewModel.lastOpenedDeckID)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 30) {
                        hero

                        if let lastDeckID = appViewModel.lastOpenedDeckID,
                           let deck = appViewModel.deck(for: lastDeckID) {
                            SectionHeader(title: "Continue")

                            NavigationLink {
                                DeckBrowserView(deckID: deck.id)
                            } label: {
                                DeckCardView(
                                    deck: deck,
                                    markedCount: appViewModel.markedCount(in: deck.id),
                                    isContinue: true
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        SectionHeader(title: "Decks")

                        VStack(spacing: 18) {
                            ForEach(appViewModel.decks) { deck in
                                NavigationLink {
                                    DeckBrowserView(deckID: deck.id)
                                } label: {
                                    DeckCardView(
                                        deck: deck,
                                        markedCount: appViewModel.markedCount(in: deck.id),
                                        isContinue: false
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        NavigationLink {
                            MarkedCardsView()
                        } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color.white.opacity(0.14))

                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(Color.white.opacity(0.14), lineWidth: 1)

                                    Image(systemName: "bookmark.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundStyle(.white)
                                }
                                .frame(width: 58, height: 58)

                                VStack(alignment: .leading, spacing: 6) {
                                    Text("FOCUSED REVIEW")
                                        .font(.system(.caption2, design: .rounded).weight(.bold))
                                        .foregroundStyle(.white.opacity(0.70))

                                    Text("Marked for Review")
                                        .font(.system(.title3, design: .rounded).weight(.bold))
                                        .foregroundStyle(.white)

                                    Text("Jump into the cards you want to revisit next.")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.80))
                                }

                                Spacer()

                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.14))
                                    Circle()
                                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                                    Text("\(appViewModel.totalMarkedCount())")
                                        .font(.system(.title3, design: .rounded).weight(.bold))
                                        .foregroundStyle(.white)
                                }
                                .frame(width: 52, height: 52)
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(red: 0.21, green: 0.25, blue: 0.35), Color(red: 0.34, green: 0.42, blue: 0.56)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(alignment: .topTrailing) {
                                        Circle()
                                            .fill(Color.white.opacity(0.12))
                                            .frame(width: 150, height: 150)
                                            .blur(radius: 24)
                                            .offset(x: 42, y: -42)
                                    }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                                    .stroke(Color.white.opacity(0.14), lineWidth: 1)
                            )
                            .shadow(color: AppTheme.deepShadowColor.opacity(0.82), radius: 28, x: 0, y: 18)
                        }
                        .buttonStyle(.plain)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Marked for review")
                        .accessibilityValue("\(appViewModel.totalMarkedCount()) cards flagged for another pass.")
                        .accessibilityHint("Double tap to open your focused review list.")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 38)
                }
            }
            .navigationTitle("Study")
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("DAILY REVIEW")
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundStyle(AppTheme.tertiaryText)

            Text("Architecture mastery with almost no friction.")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.primaryText)
                .lineSpacing(2)

            Text("Fast review, clean focus, and enough depth to sharpen real interview and delivery skills.")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(AppTheme.secondaryText)
                .lineSpacing(3)

            HStack(spacing: 10) {
                statChip(title: "Decks", value: "\(appViewModel.decks.count)")
                statChip(title: "Cards", value: "\(appViewModel.decks.reduce(0) { $0 + $1.cards.count })")
                statChip(title: "Marked", value: "\(appViewModel.totalMarkedCount())")
            }
            .padding(.top, 4)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(AppTheme.elevatedSurfaceGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.outlineGradient, lineWidth: 1)
        )
        .shadow(color: AppTheme.shadowColor.opacity(0.72), radius: 24, x: 0, y: 14)
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(Color.white.opacity(0.10))
                .frame(width: 110, height: 110)
                .blur(radius: 18)
                .offset(x: 18, y: -24)
        }
    }

    private func statChip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(.caption2, design: .rounded).weight(.bold))
                .foregroundStyle(AppTheme.tertiaryText)

            Text(value)
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(AppTheme.primaryText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppTheme.surfaceGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.outlineGradient, lineWidth: 1)
        )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let reviewStore = ReviewStore()
        let appViewModel = AppViewModel(reviewStore: reviewStore)

        return HomeView()
            .environmentObject(reviewStore)
            .environmentObject(appViewModel)
    }
}

private struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(.title3, design: .rounded).weight(.bold))
            .foregroundStyle(AppTheme.primaryText)
    }
}
