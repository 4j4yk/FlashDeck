import Combine
import Foundation

final class AppViewModel: ObservableObject {
    struct CardSection: Identifiable {
        let deck: Deck
        let cards: [FlashCard]

        var id: DeckCategory { deck.id }
    }

    let decks: [Deck]
    @Published private(set) var lastOpenedDeckID: DeckCategory?

    private let reviewStore: ReviewStore
    private let defaults: UserDefaults
    private let lastDeckKey = "flashcards.lastOpenedDeckID"
    private var cancellables: Set<AnyCancellable> = []

    init(reviewStore: ReviewStore, defaults: UserDefaults = .standard) {
        self.reviewStore = reviewStore
        self.defaults = defaults
        self.decks = SeedDecks.all
        self.lastOpenedDeckID = DeckCategory(rawValue: defaults.string(forKey: lastDeckKey) ?? "")

        reviewStore.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func deck(for deckID: DeckCategory) -> Deck? {
        guard let deck = decks.first(where: { $0.id == deckID }) else { return nil }
        return Deck(
            id: deck.id,
            title: deck.title,
            subtitle: deck.subtitle,
            symbolName: deck.symbolName,
            summary: deck.summary,
            cards: enrich(deck.cards)
        )
    }

    func cards(for deckID: DeckCategory, searchText: String = "") -> [FlashCard] {
        guard let deck = deck(for: deckID) else { return [] }
        return filter(deck.cards, searchText: searchText)
    }

    func markedSections(searchText: String = "") -> [CardSection] {
        decks.compactMap { deck in
            let cards = filter(enrich(deck.cards).filter(\.isMarkedForReview), searchText: searchText)
            guard cards.isEmpty == false else { return nil }
            return CardSection(
                deck: Deck(
                    id: deck.id,
                    title: deck.title,
                    subtitle: deck.subtitle,
                    symbolName: deck.symbolName,
                    summary: deck.summary,
                    cards: cards
                ),
                cards: cards
            )
        }
    }

    func markedCount(in deckID: DeckCategory) -> Int {
        guard let deck = deck(for: deckID) else { return 0 }
        return deck.cards.filter(\.isMarkedForReview).count
    }

    func totalMarkedCount() -> Int {
        reviewStore.allMarkedIDs().count
    }

    func setLastOpenedDeck(_ deckID: DeckCategory) {
        lastOpenedDeckID = deckID
        defaults.set(deckID.rawValue, forKey: lastDeckKey)
    }

    private func enrich(_ cards: [FlashCard]) -> [FlashCard] {
        cards.map { card in
            var updated = card
            updated.isMarkedForReview = reviewStore.isMarked(card.id)
            return updated
        }
    }

    private func filter(_ cards: [FlashCard], searchText: String) -> [FlashCard] {
        guard searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            return cards
        }
        return cards.filter { $0.matches(searchText) }
    }
}
