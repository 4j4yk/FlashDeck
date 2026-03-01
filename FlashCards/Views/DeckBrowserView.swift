import SwiftUI

struct DeckBrowserView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @EnvironmentObject private var reviewStore: ReviewStore

    let deckID: DeckCategory

    @State private var searchText = ""
    @State private var isSelecting = false
    @State private var selectedIDs: Set<String> = []
    @State private var selectedSession: StudySession?

    private var deck: Deck? {
        appViewModel.deck(for: deckID)
    }

    private var cards: [FlashCard] {
        appViewModel.cards(for: deckID, searchText: searchText)
    }

    var body: some View {
        ZStack {
            AppBackground(accentDeck: deckID)

            if let deck {
                List {
                    Section {
                        overviewCard(deck: deck)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                    if cards.isEmpty {
                        EmptyStateView(
                            symbolName: "magnifyingglass",
                            title: "No cards found",
                            message: "Try a broader search or clear the current query."
                        )
                        .listRowInsets(EdgeInsets(top: 28, leading: 20, bottom: 0, trailing: 20))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    } else {
                        ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                            row(for: card, index: index, studyCards: cards)
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 14, trailing: 0))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(reviewStore.isMarked(card.id) ? "Unmark" : "Mark") {
                                        reviewStore.toggle(card.id)
                                        Haptics.selection()
                                    }
                                    .tint(reviewStore.isMarked(card.id) ? .gray : AppTheme.accentColor(for: deckID))
                                }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle(deck?.title ?? "Deck")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search cards")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if cards.isEmpty == false {
                    Menu {
                        ForEach(StudyMode.allCases) { mode in
                            let session = studySession(for: mode)
                            Button {
                                selectedSession = session
                            } label: {
                                Label(mode.title, systemImage: mode.symbolName)
                            }
                            .disabled(session == nil)
                        }
                    } label: {
                        Label("Study", systemImage: "play.fill")
                    }
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(isSelecting ? "Done" : "Select") {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                        isSelecting.toggle()
                        if isSelecting == false {
                            selectedIDs.removeAll()
                        }
                    }
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                if isSelecting, selectedIDs.isEmpty == false {
                    Button(batchActionTitle) {
                        applyBatchAction()
                    }
                }
            }
        }
        .onAppear {
            appViewModel.setLastOpenedDeck(deckID)
        }
        .navigationDestination(item: $selectedSession) { session in
            StudyView(session: session)
        }
    }

    @ViewBuilder
    private func row(for card: FlashCard, index: Int, studyCards: [FlashCard]) -> some View {
        if isSelecting {
            Button {
                toggleSelection(card.id)
            } label: {
                CardRowView(
                    card: card,
                    accentDeck: deckID,
                    isSelecting: true,
                    isSelected: selectedIDs.contains(card.id)
                )
            }
            .buttonStyle(.plain)
        } else {
            if let session = studySession(for: .allCards, from: studyCards, startIndex: index) {
                NavigationLink {
                    StudyView(session: session)
                } label: {
                    CardRowView(card: card, accentDeck: deckID)
                }
                .buttonStyle(.plain)
            } else {
                CardRowView(card: card, accentDeck: deckID)
            }
        }
    }

    private var batchActionTitle: String {
        let selectedCards = cards.filter { selectedIDs.contains($0.id) }
        let shouldMark = selectedCards.contains(where: { reviewStore.isMarked($0.id) == false })
        return shouldMark ? "Mark" : "Unmark"
    }

    private func toggleSelection(_ cardID: String) {
        if selectedIDs.contains(cardID) {
            selectedIDs.remove(cardID)
        } else {
            selectedIDs.insert(cardID)
        }
        Haptics.selection()
    }

    private func applyBatchAction() {
        let ids = Array(selectedIDs)
        let shouldMark = cards
            .filter { selectedIDs.contains($0.id) }
            .contains(where: { reviewStore.isMarked($0.id) == false })

        if shouldMark {
            reviewStore.markMany(ids)
        } else {
            reviewStore.unmarkMany(ids)
        }

        Haptics.success()
        selectedIDs.removeAll()
        isSelecting = false
    }

    private func studySession(
        for mode: StudyMode,
        from sourceCards: [FlashCard]? = nil,
        startIndex: Int = 0
    ) -> StudySession? {
        let baseCards = sourceCards ?? cards

        let sessionCards: [FlashCard]
        switch mode {
        case .allCards:
            sessionCards = baseCards
        case .onlyMarked:
            sessionCards = baseCards.filter(\.isMarkedForReview)
        case .randomTwenty:
            sessionCards = Array(baseCards.shuffled().prefix(20))
        case .weakAreas:
            sessionCards = baseCards.filter(\.isMarkedForReview).shuffled()
        }

        guard sessionCards.isEmpty == false else { return nil }

        return StudySession(
            deckID: deckID,
            deckTitle: deck?.title ?? "Deck",
            mode: mode,
            cards: sessionCards,
            startIndex: min(max(startIndex, 0), max(sessionCards.count - 1, 0))
        )
    }

    private func overviewCard(deck: Deck) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("DECK")
                        .font(.system(.caption2, design: .rounded).weight(.bold))
                        .foregroundStyle(.white.opacity(0.70))

                    Text(deck.title)
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)

                    Text(deck.subtitle)
                        .font(.system(.headline, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.90))

                    Text(deck.summary)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.80))
                }

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.16))
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.16), lineWidth: 1)
                    Image(systemName: deck.symbolName)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white.opacity(0.94))
                }
                .frame(width: 58, height: 58)
            }

            HStack(spacing: 12) {
                infoPill("\(deck.cards.count) cards")
                infoPill("\(appViewModel.markedCount(in: deckID)) marked")
                if isSelecting {
                    infoPill("\(selectedIDs.count) selected")
                }
            }
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(AppTheme.gradient(for: deckID))
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(Color.white.opacity(0.14))
                        .frame(width: 170, height: 170)
                        .blur(radius: 24)
                        .offset(x: 40, y: -50)
                }
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
        .shadow(color: AppTheme.deepShadowColor.opacity(0.82), radius: 28, x: 0, y: 18)
        .padding(.horizontal, 20)
    }

    private func infoPill(_ text: String) -> some View {
        Text(text)
            .font(.system(.caption2, design: .rounded).weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.16), in: Capsule())
    }
}

struct DeckBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        let reviewStore = ReviewStore()
        let appViewModel = AppViewModel(reviewStore: reviewStore)

        return NavigationStack {
            DeckBrowserView(deckID: .systemDesign)
                .environmentObject(reviewStore)
                .environmentObject(appViewModel)
        }
    }
}
