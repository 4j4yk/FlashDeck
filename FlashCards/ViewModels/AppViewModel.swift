import Combine
import Foundation

struct PersistenceNotice: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String
}

final class AppViewModel: ObservableObject {
    struct CardSection: Identifiable {
        let deck: Deck
        let cards: [FlashCard]

        var id: String { deck.id }
    }

    @Published private(set) var decks: [Deck] = []
    @Published private(set) var lastOpenedDeckID: String?
    @Published private(set) var startupNotice: PersistenceNotice?

    private let reviewStore: ReviewStore
    private let defaults: UserDefaults
    private let customDeckStore: CustomDeckStore
    private let knowledgeStore: KnowledgeStore
    private let lastDeckKey = "flashcards.lastOpenedDeckID"
    private var cancellables: Set<AnyCancellable> = []

    init(
        reviewStore: ReviewStore,
        defaults: UserDefaults = .standard,
        customDeckStore: CustomDeckStore = CustomDeckStore(),
        knowledgeStore: KnowledgeStore = .shared
    ) {
        self.reviewStore = reviewStore
        self.defaults = defaults
        self.customDeckStore = customDeckStore
        self.knowledgeStore = knowledgeStore
        self.lastOpenedDeckID = defaults.string(forKey: lastDeckKey)

        let customDeckLoad = customDeckStore.loadDecks()
        startupNotice = Self.combinedNotice(from: customDeckLoad.notices + knowledgeStore.consumeStartupNotices())
        reloadDecks(customDecks: customDeckLoad.decks)

        reviewStore.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func deck(for deckID: String) -> Deck? {
        guard let deck = rawDeck(for: deckID) else { return nil }
        return Deck(
            id: deck.id,
            category: deck.category,
            title: deck.title,
            subtitle: deck.subtitle,
            symbolName: deck.symbolName,
            summary: deck.summary,
            cards: enrich(deck.cards)
        )
    }

    func cards(for deckID: String, searchText: String = "") -> [FlashCard] {
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
                    category: deck.category,
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

    func markedCount(in deckID: String) -> Int {
        guard let deck = deck(for: deckID) else { return 0 }
        return deck.cards.filter(\.isMarkedForReview).count
    }

    func totalMarkedCount() -> Int {
        reviewStore.allMarkedIDs().count
    }

    func setLastOpenedDeck(_ deckID: String) {
        lastOpenedDeckID = deckID
        defaults.set(deckID, forKey: lastDeckKey)
    }

    func deckFile(for deckID: String) -> DeckFile? {
        deck(for: deckID).map(DeckFile.init(deck:))
    }

    func sampleDeckFile() -> DeckFile {
        .sample
    }

    func knowledgeDeckFile(for deckID: String) -> KnowledgeDeckFile? {
        guard let deck = deck(for: deckID) else { return nil }
        return knowledgeStore.knowledgeDeckFile(
            for: deck.id,
            deckCategory: deck.category,
            deckCards: deck.cards
        )
    }

    func importDeckFile(_ deckFile: DeckFile) throws {
        let importedDeck = try deckFile.toDeck()
        try validateUniqueCardIDs(for: importedDeck)
        try customDeckStore.upsert(DeckFile(deck: importedDeck))
        reloadDecks()
        setLastOpenedDeck(importedDeck.id)
    }

    func importKnowledgeDeckFile(_ deckFile: KnowledgeDeckFile) throws -> KnowledgeDeckFile {
        try knowledgeStore.importKnowledgeDeckFile(deckFile)
    }

    func consumeStartupNotice() -> PersistenceNotice? {
        defer { startupNotice = nil }
        return startupNotice
    }

    func resetLocalData() async {
        defaults.removeObject(forKey: lastDeckKey)
        lastOpenedDeckID = nil
        startupNotice = nil

        try? customDeckStore.clear()
        knowledgeStore.resetImportedKnowledge()
        reloadDecks(customDecks: [])

        await CardAssistCache.shared.clearAll()
    }

    private func rawDeck(for deckID: String) -> Deck? {
        decks.first(where: { $0.id == deckID })
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

    private func reloadDecks(customDecks: [Deck]? = nil) {
        let builtIns = SeedDecks.all
        let customDecks = customDecks ?? customDeckStore.loadDecks().decks

        var deckByID = Dictionary(uniqueKeysWithValues: builtIns.map { ($0.id, $0) })
        customDecks.forEach { deckByID[$0.id] = $0 }

        let builtInOrder = Dictionary(uniqueKeysWithValues: builtIns.enumerated().map { ($1.id, $0) })
        decks = deckByID.values.sorted { lhs, rhs in
            let lhsIndex = builtInOrder[lhs.id]
            let rhsIndex = builtInOrder[rhs.id]

            switch (lhsIndex, rhsIndex) {
            case let (lhs?, rhs?):
                return lhs < rhs
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            case (nil, nil):
                return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }
        }
    }

    private func validateUniqueCardIDs(for importedDeck: Deck) throws {
        let existingIDs = Set(
            decks
                .filter { $0.id != importedDeck.id }
                .flatMap(\.cards)
                .map(\.id)
        )

        let duplicates = Array(
            Set(importedDeck.cards.map(\.id).filter { existingIDs.contains($0) })
        ).sorted()

        guard duplicates.isEmpty else {
            throw DeckImportError.duplicateCardIDs(duplicates)
        }
    }

    private static func combinedNotice(from notices: [PersistenceNotice]) -> PersistenceNotice? {
        guard notices.isEmpty == false else { return nil }

        let message = notices
            .map { "\($0.title): \($0.message)" }
            .joined(separator: "\n\n")

        return PersistenceNotice(
            title: "Recovered local data",
            message: message
        )
    }
}

final class CustomDeckStore {
    struct LoadResult {
        let decks: [Deck]
        let notices: [PersistenceNotice]
    }

    private let fileManager: FileManager
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let directoryName = "FlashCards"
    private let storageFilename = "custom-decks.json"
    private let baseDirectoryURL: URL?

    init(fileManager: FileManager = .default, baseDirectoryURL: URL? = nil) {
        self.fileManager = fileManager
        self.baseDirectoryURL = baseDirectoryURL
    }

    func loadDecks() -> LoadResult {
        let outcome = loadDeckFiles()
        let decks = outcome.deckFiles.compactMap { try? $0.toDeck() }
        return LoadResult(decks: decks, notices: outcome.notices)
    }

    func upsert(_ deckFile: DeckFile) throws {
        var deckFiles = loadDeckFiles().deckFiles.filter { $0.id != deckFile.id }
        deckFiles.append(deckFile)

        try persist(deckFiles, to: storageURL())
    }

    func clear() throws {
        let url = try storageURL()
        guard fileManager.fileExists(atPath: url.path) else { return }
        try fileManager.removeItem(at: url)
    }

    private struct DeckFileLoadOutcome {
        let deckFiles: [DeckFile]
        let notices: [PersistenceNotice]
    }

    private func loadDeckFiles() -> DeckFileLoadOutcome {
        guard let url = try? storageURL(),
              fileManager.fileExists(atPath: url.path) else {
            return DeckFileLoadOutcome(deckFiles: [], notices: [])
        }

        do {
            let data = try Data(contentsOf: url, options: [.mappedIfSafe])
            let decoded = try decoder.decode([DeckFile].self, from: data)
            return sanitize(decoded, sourceURL: url)
        } catch {
            let backupURL = backupStore(at: url, suffix: "corrupt")
            return DeckFileLoadOutcome(
                deckFiles: [],
                notices: [
                    PersistenceNotice(
                        title: "Imported decks reset",
                        message: "The custom deck store was unreadable and has been moved to \(backupURL.lastPathComponent). Re-import any deck JSON you still need."
                    )
                ]
            )
        }
    }

    private func storageURL() throws -> URL {
        let baseURL: URL
        if let baseDirectoryURL {
            baseURL = baseDirectoryURL
        } else {
            baseURL = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
        }
        let directoryURL = baseURL.appendingPathComponent(directoryName, isDirectory: true)

        if fileManager.fileExists(atPath: directoryURL.path) == false {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }

        return directoryURL.appendingPathComponent(storageFilename, isDirectory: false)
    }

    private func sanitize(_ decoded: [DeckFile], sourceURL: URL) -> DeckFileLoadOutcome {
        var validDecks: [DeckFile] = []
        var invalidEntries: [String] = []

        for deckFile in decoded {
            do {
                _ = try deckFile.toDeck()
                validDecks.append(deckFile)
            } catch {
                invalidEntries.append(deckFile.title.isEmpty ? deckFile.id : deckFile.title)
            }
        }

        guard invalidEntries.isEmpty == false else {
            return DeckFileLoadOutcome(deckFiles: decoded, notices: [])
        }

        let backupURL = backupStore(at: sourceURL, suffix: "invalid")
        try? persist(validDecks, to: sourceURL)

        return DeckFileLoadOutcome(
            deckFiles: validDecks,
            notices: [
                PersistenceNotice(
                    title: "Imported decks repaired",
                    message: "Removed \(invalidEntries.count) invalid imported deck(s): \(summarizedNames(in: invalidEntries)). A backup of the previous store was saved as \(backupURL.lastPathComponent)."
                )
            ]
        )
    }

    private func persist(_ deckFiles: [DeckFile], to url: URL) throws {
        let data = try encoder.encode(deckFiles)
        try data.write(to: url, options: [.atomic])
    }

    private func backupStore(at url: URL, suffix: String) -> URL {
        let timestamp = Int(Date().timeIntervalSince1970)
        let backupURL = url.deletingLastPathComponent()
            .appendingPathComponent("custom-decks-\(suffix)-\(timestamp).json", isDirectory: false)
        try? fileManager.moveItem(at: url, to: backupURL)
        return backupURL
    }

    private func summarizedNames(in values: [String]) -> String {
        let trimmed = values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }

        guard trimmed.count > 2 else {
            return trimmed.joined(separator: ", ")
        }

        return trimmed.prefix(2).joined(separator: ", ") + ", and \(trimmed.count - 2) more"
    }
}
