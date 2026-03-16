import SwiftUI

struct MarkedCardsView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @EnvironmentObject private var reviewStore: ReviewStore

    @State private var searchText = ""
    @State private var isSelecting = false
    @State private var selectedIDs: Set<String> = []

    private var sections: [AppViewModel.CardSection] {
        appViewModel.markedSections(searchText: searchText)
    }

    private var visibleCardIDs: Set<String> {
        Set(sections.flatMap(\.cards).map(\.id))
    }

    private var visibleSelectedIDs: Set<String> {
        selectedIDs.intersection(visibleCardIDs)
    }

    private var hasSearchText: Bool {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    private var emptyState: (symbolName: String, title: String, message: String) {
        if hasSearchText, reviewStore.allMarkedIDs().isEmpty == false {
            return (
                symbolName: "magnifyingglass",
                title: "No marked cards found",
                message: "Try a broader search to find a marked card in your review list."
            )
        }

        return (
            symbolName: "bookmark.slash",
            title: "Nothing marked yet",
            message: "Mark cards in any deck to build a focused review session."
        )
    }

    var body: some View {
        ZStack {
            AppBackground()

            if sections.isEmpty {
                EmptyStateView(
                    symbolName: emptyState.symbolName,
                    title: emptyState.title,
                    message: emptyState.message
                )
                .padding(.horizontal, 20)
            } else {
                List {
                    Section {
                        summaryCard
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                    ForEach(sections) { section in
                        Section(section.deck.title) {
                            ForEach(Array(section.cards.enumerated()), id: \.element.id) { index, card in
                                if isSelecting {
                                    row(for: card, deck: section.deck, cards: section.cards, index: index)
                                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 14, trailing: 0))
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                } else {
                                    row(for: card, deck: section.deck, cards: section.cards, index: index)
                                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 14, trailing: 0))
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button("Unmark", role: .destructive) {
                                                reviewStore.unmark(card.id)
                                                Haptics.selection()
                                            }
                                        }
                                }
                            }
                        }
                        .textCase(nil)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: AppTheme.rootTabBarClearance)
                }
            }
        }
        .navigationTitle("Marked")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search marked cards")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isSelecting || sections.isEmpty == false {
                    Button(isSelecting ? "Done" : "Select") {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                            isSelecting.toggle()
                            if isSelecting == false {
                                selectedIDs.removeAll()
                            }
                        }
                    }
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                if isSelecting, visibleSelectedIDs.isEmpty == false {
                    Button("Unmark") {
                        reviewStore.unmarkMany(Array(visibleSelectedIDs))
                        selectedIDs.removeAll()
                        isSelecting = false
                        Haptics.success()
                    }
                }
            }
        }
        .onChange(of: sections.flatMap(\.cards).map(\.id)) { _, _ in
            reconcileSelection()
        }
    }

    @ViewBuilder
    private func row(for card: FlashCard, deck: Deck, cards: [FlashCard], index: Int) -> some View {
        if isSelecting {
            Button {
                toggleSelection(card.id)
            } label: {
                CardRowView(
                    card: card,
                    accentDeck: deck.category,
                    isSelecting: true,
                    isSelected: selectedIDs.contains(card.id)
                )
            }
            .buttonStyle(.plain)
        } else {
            NavigationLink {
                StudyView(
                    session: StudySession(
                        deckID: deck.id,
                        deckTitle: deck.title,
                        deckCategory: deck.category,
                        mode: .onlyMarked,
                        cards: cards,
                        startIndex: index
                    )
                )
            } label: {
                CardRowView(card: card, accentDeck: deck.category)
            }
            .buttonStyle(.plain)
        }
    }

    private var summaryCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "bookmark.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 6) {
                Text("Focused review")
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white)

                Text("Keep the cards that need another pass close at hand.")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.white.opacity(0.84))
            }

            Spacer()

            Text("\(reviewStore.allMarkedIDs().count)")
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundStyle(.white)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.30, green: 0.34, blue: 0.43), Color(red: 0.45, green: 0.54, blue: 0.69)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.14), radius: 28, x: 0, y: 16)
        .padding(.horizontal, 20)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Focused review")
        .accessibilityValue("\(reviewStore.allMarkedIDs().count) cards marked for review.")
    }

    private func toggleSelection(_ cardID: String) {
        if selectedIDs.contains(cardID) {
            selectedIDs.remove(cardID)
        } else {
            selectedIDs.insert(cardID)
        }
        Haptics.selection()
    }

    private func reconcileSelection() {
        selectedIDs = visibleSelectedIDs
    }
}

struct MarkedCardsView_Previews: PreviewProvider {
    static var previews: some View {
        let reviewStore = ReviewStore()
        reviewStore.mark("system-scalability")
        reviewStore.mark("aws-lambda")
        let appViewModel = AppViewModel(reviewStore: reviewStore)

        return NavigationStack {
            MarkedCardsView()
                .environmentObject(reviewStore)
                .environmentObject(appViewModel)
        }
    }
}
