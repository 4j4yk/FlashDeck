import Foundation

private enum DeckImportLimits {
    static let maxDeckIDLength = 80
    static let maxDeckTitleLength = 80
    static let maxDeckSubtitleLength = 120
    static let maxDeckSummaryLength = 320
    static let maxSymbolNameLength = 80
    static let maxCardsPerDeck = 500
    static let maxCardIDLength = 96
    static let maxCardTitleLength = 120
    static let maxPromptLength = 600
    static let maxAnswerLength = 2_400
    static let maxTagsPerCard = 12
    static let maxTagLength = 40
}

struct Deck: Identifiable, Hashable {
    let id: String
    let category: DeckCategory
    let title: String
    let subtitle: String
    let symbolName: String
    let summary: String
    let cards: [FlashCard]
}

enum StudyMode: String, CaseIterable, Identifiable, Hashable {
    case allCards = "All Cards"
    case onlyMarked = "Only Marked"
    case randomTwenty = "Random 20"
    case weakAreas = "Weak Areas"

    var id: String { rawValue }

    var title: String { rawValue }

    var symbolName: String {
        switch self {
        case .allCards:
            return "rectangle.stack.fill"
        case .onlyMarked:
            return "bookmark.fill"
        case .randomTwenty:
            return "shuffle"
        case .weakAreas:
            return "bolt.heart.fill"
        }
    }

    func detailText(cardCount: Int) -> String {
        switch self {
        case .allCards:
            return "\(cardCount) cards in this session"
        case .onlyMarked:
            return "\(cardCount) marked cards"
        case .randomTwenty:
            return "\(cardCount) cards selected at random"
        case .weakAreas:
            return "\(cardCount) cards flagged for another pass"
        }
    }
}

struct StudySession: Identifiable, Hashable {
    let id = UUID()
    let deckID: String
    let deckTitle: String
    let deckCategory: DeckCategory
    let mode: StudyMode
    let cards: [FlashCard]
    let startIndex: Int
}

enum DeckCategory: String, CaseIterable, Identifiable, Codable {
    case systemDesign = "system-design"
    case solutionArchitecture = "solution-architecture"
    case awsServices = "aws-services"
    case custom = "custom"

    var id: String { rawValue }

    static let builtInCases: [DeckCategory] = [
        .systemDesign,
        .solutionArchitecture,
        .awsServices
    ]
}

struct DeckFile: Identifiable, Hashable, Codable {
    let schemaVersion: Int
    let id: String
    let category: DeckCategory
    let title: String
    let subtitle: String
    let symbolName: String
    let summary: String
    let cards: [DeckFileCard]

    init(
        schemaVersion: Int = 1,
        id: String,
        category: DeckCategory,
        title: String,
        subtitle: String,
        symbolName: String,
        summary: String,
        cards: [DeckFileCard]
    ) {
        self.schemaVersion = schemaVersion
        self.id = id
        self.category = category
        self.title = title
        self.subtitle = subtitle
        self.symbolName = symbolName
        self.summary = summary
        self.cards = cards
    }

    init(deck: Deck) {
        self.init(
            id: deck.id,
            category: deck.category,
            title: deck.title,
            subtitle: deck.subtitle,
            symbolName: deck.symbolName,
            summary: deck.summary,
            cards: deck.cards.map(DeckFileCard.init(card:))
        )
    }

    func toDeck() throws -> Deck {
        let trimmedID = id.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSubtitle = subtitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSummary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSymbolName = symbolName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedID.isEmpty == false else {
            throw DeckImportError.invalidDeck("Deck id is required.")
        }

        guard trimmedID.count <= DeckImportLimits.maxDeckIDLength else {
            throw DeckImportError.invalidDeck("Deck id must be \(DeckImportLimits.maxDeckIDLength) characters or fewer.")
        }

        guard trimmedTitle.isEmpty == false else {
            throw DeckImportError.invalidDeck("Deck title is required.")
        }

        guard trimmedTitle.count <= DeckImportLimits.maxDeckTitleLength else {
            throw DeckImportError.invalidDeck("Deck title must be \(DeckImportLimits.maxDeckTitleLength) characters or fewer.")
        }

        guard trimmedSubtitle.count <= DeckImportLimits.maxDeckSubtitleLength else {
            throw DeckImportError.invalidDeck("Deck subtitle must be \(DeckImportLimits.maxDeckSubtitleLength) characters or fewer.")
        }

        guard trimmedSummary.count <= DeckImportLimits.maxDeckSummaryLength else {
            throw DeckImportError.invalidDeck("Deck summary must be \(DeckImportLimits.maxDeckSummaryLength) characters or fewer.")
        }

        guard trimmedSymbolName.count <= DeckImportLimits.maxSymbolNameLength else {
            throw DeckImportError.invalidDeck("Deck symbol names must be \(DeckImportLimits.maxSymbolNameLength) characters or fewer.")
        }

        guard cards.isEmpty == false else {
            throw DeckImportError.invalidDeck("A deck must include at least one card.")
        }

        guard cards.count <= DeckImportLimits.maxCardsPerDeck else {
            throw DeckImportError.invalidDeck("Decks are limited to \(DeckImportLimits.maxCardsPerDeck) cards per import.")
        }

        var uniqueCardIDs = Set<String>()
        let deckCards = try cards.map { card in
            let flashCard = try card.toFlashCard(deckID: trimmedID)
            guard uniqueCardIDs.insert(flashCard.id).inserted else {
                throw DeckImportError.invalidDeck("Duplicate card id \"\(flashCard.id)\" in deck \"\(trimmedID)\".")
            }
            return flashCard
        }

        return Deck(
            id: trimmedID,
            category: category,
            title: trimmedTitle,
            subtitle: trimmedSubtitle,
            symbolName: trimmedSymbolName.isEmpty ? "square.stack.3d.up.fill" : trimmedSymbolName,
            summary: trimmedSummary,
            cards: deckCards
        )
    }

    static let sample = DeckFile(
        id: "custom-kafka-core",
        category: .systemDesign,
        title: "Kafka Core",
        subtitle: "Build stronger event-streaming instincts",
        symbolName: "bolt.horizontal.circle.fill",
        summary: "A small sample deck that demonstrates the JSON format for importing or updating a deck.",
        cards: [
            DeckFileCard(
                id: "kafka-broker",
                title: "Kafka Broker",
                prompt: "What is a Kafka broker and why does it matter in a production cluster?",
                answer: "A broker stores partitions, serves reads and writes, and participates in replication. Capacity, partition placement, and broker count drive throughput, fault isolation, and recovery speed.",
                tags: ["kafka", "messaging", "system-design"]
            ),
            DeckFileCard(
                id: "consumer-groups",
                title: "Consumer Groups",
                prompt: "How do consumer groups scale reads and what tradeoff do they impose?",
                answer: "A partition is consumed by at most one consumer in a group, so adding consumers increases parallelism only up to the partition count. Too few partitions caps throughput; too many increases coordination and storage overhead.",
                tags: ["kafka", "scalability", "tradeoffs"]
            ),
            DeckFileCard(
                id: "exactly-once",
                title: "Exactly-once Semantics",
                prompt: "When should you trust Kafka exactly-once semantics and when is idempotency still required?",
                answer: "Use EOS when Kafka producers, brokers, and consumers all participate correctly in transactions. You still need idempotent downstream writes because external databases and side effects are outside Kafka's transaction boundary.",
                tags: ["kafka", "reliability", "idempotency"]
            )
        ]
    )
}

struct DeckFileCard: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let prompt: String
    let answer: String
    let tags: [String]

    init(id: String, title: String, prompt: String, answer: String, tags: [String]) {
        self.id = id
        self.title = title
        self.prompt = prompt
        self.answer = answer
        self.tags = tags
    }

    init(card: FlashCard) {
        self.init(
            id: card.id,
            title: card.title,
            prompt: card.prompt,
            answer: card.answer,
            tags: card.tags
        )
    }

    func toFlashCard(deckID: String) throws -> FlashCard {
        let trimmedID = id.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAnswer = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedTags = tags
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }

        guard trimmedID.isEmpty == false else {
            throw DeckImportError.invalidDeck("Every card needs an id.")
        }

        guard trimmedID.count <= DeckImportLimits.maxCardIDLength else {
            throw DeckImportError.invalidDeck("Card ids must be \(DeckImportLimits.maxCardIDLength) characters or fewer.")
        }

        guard trimmedTitle.isEmpty == false else {
            throw DeckImportError.invalidDeck("Every card needs a title.")
        }

        guard trimmedTitle.count <= DeckImportLimits.maxCardTitleLength else {
            throw DeckImportError.invalidDeck("Card titles must be \(DeckImportLimits.maxCardTitleLength) characters or fewer.")
        }

        guard trimmedPrompt.isEmpty == false else {
            throw DeckImportError.invalidDeck("Card \"\(trimmedID)\" is missing its prompt.")
        }

        guard trimmedPrompt.count <= DeckImportLimits.maxPromptLength else {
            throw DeckImportError.invalidDeck("Card prompts must be \(DeckImportLimits.maxPromptLength) characters or fewer.")
        }

        guard trimmedAnswer.isEmpty == false else {
            throw DeckImportError.invalidDeck("Card \"\(trimmedID)\" is missing its answer.")
        }

        guard trimmedAnswer.count <= DeckImportLimits.maxAnswerLength else {
            throw DeckImportError.invalidDeck("Card answers must be \(DeckImportLimits.maxAnswerLength) characters or fewer.")
        }

        guard normalizedTags.count <= DeckImportLimits.maxTagsPerCard else {
            throw DeckImportError.invalidDeck("Cards can include at most \(DeckImportLimits.maxTagsPerCard) tags.")
        }

        if normalizedTags.contains(where: { $0.count > DeckImportLimits.maxTagLength }) {
            throw DeckImportError.invalidDeck("Each tag must be \(DeckImportLimits.maxTagLength) characters or fewer.")
        }

        return FlashCard(
            id: trimmedID,
            deckID: deckID,
            title: trimmedTitle,
            prompt: trimmedPrompt,
            answer: trimmedAnswer,
            tags: normalizedTags
        )
    }
}

enum DeckImportError: LocalizedError {
    case invalidDeck(String)
    case duplicateCardIDs([String])

    var errorDescription: String? {
        switch self {
        case let .invalidDeck(message):
            return message
        case let .duplicateCardIDs(cardIDs):
            return "Card ids must stay globally unique. Update these duplicates and try again: \(cardIDs.joined(separator: ", "))"
        }
    }
}
