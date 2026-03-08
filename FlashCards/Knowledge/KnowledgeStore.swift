import Foundation

final class KnowledgeStore {
    static let shared = KnowledgeStore()

    private let bundle: Bundle
    private let decoder: JSONDecoder
    private let customKnowledgeStore: CustomKnowledgeStore
    private let lock = NSLock()
    private var bundledDocuments: [String: [KnowledgeDocument]]
    private var importedDocuments: [String: [KnowledgeDocument]]
    private var startupNotices: [PersistenceNotice]

    init(bundle: Bundle = .main, customKnowledgeStore: CustomKnowledgeStore = CustomKnowledgeStore()) {
        self.bundle = bundle
        self.decoder = JSONDecoder()
        self.customKnowledgeStore = customKnowledgeStore
        self.bundledDocuments = [:]
        self.importedDocuments = [:]
        self.startupNotices = []
        self.bundledDocuments = loadBundledKnowledge()
        let importedLoad = customKnowledgeStore.loadDocumentMap()
        self.importedDocuments = importedLoad.documents
        self.startupNotices = importedLoad.notices
    }

    func documents(for request: CardAssistRequest) -> [KnowledgeDocument] {
        let imported = lock.withLock { importedDocuments }
        let bundled = lock.withLock { bundledDocuments }

        if let runtime = imported[request.deckID], runtime.isEmpty == false {
            return runtime
        }

        if let runtime = imported[request.deckCategory.rawValue], runtime.isEmpty == false {
            return runtime
        }

        if let bundled = bundled[request.deckID], bundled.isEmpty == false {
            return bundled
        }

        if let bundled = bundled[request.deckCategory.rawValue], bundled.isEmpty == false {
            return bundled
        }

        return synthesizeDocuments(deckID: request.deckID, cards: request.deckCards)
    }

    func importKnowledgeDeckFile(_ deckFile: KnowledgeDeckFile) throws -> KnowledgeDeckFile {
        let validated = try deckFile.validated()
        try customKnowledgeStore.upsert(validated)

        lock.withLock {
            importedDocuments[validated.deckID] = validated.documents
        }

        Task {
            await CardAssistCache.shared.invalidate(deckID: validated.deckID)
        }

        return validated
    }

    func consumeStartupNotices() -> [PersistenceNotice] {
        lock.withLock {
            let notices = startupNotices
            startupNotices = []
            return notices
        }
    }

    private func loadBundledKnowledge() -> [String: [KnowledgeDocument]] {
        let resourceNames: [(String, String)] = [
            (DeckCategory.systemDesign.rawValue, "SystemDesignKnowledge"),
            (DeckCategory.solutionArchitecture.rawValue, "SolutionArchitectureKnowledge"),
            (DeckCategory.awsServices.rawValue, "AWSKnowledge")
        ]

        var result: [String: [KnowledgeDocument]] = [:]

        for (deckID, resourceName) in resourceNames {
            let url = bundle.url(forResource: resourceName, withExtension: "json", subdirectory: "Knowledge")
                ?? bundle.url(forResource: resourceName, withExtension: "json")

            guard let url,
                  let data = try? Data(contentsOf: url),
                  let deckFile = try? decoder.decode(KnowledgeDeckFile.self, from: data) else {
                continue
            }

            let documents = deckFile.documents.map { document in
                KnowledgeDocument(
                    id: document.id,
                    deckID: document.deckID ?? deckFile.deckID,
                    title: document.title,
                    aliases: document.aliases,
                    tags: document.tags,
                    summary: document.summary,
                    keyPoints: document.keyPoints,
                    examples: document.examples,
                    compareTo: document.compareTo,
                    pitfalls: document.pitfalls,
                    avoidWhen: document.avoidWhen
                )
            }

            result[deckID] = documents
        }

        return result
    }

    private func synthesizeDocuments(deckID: String, cards: [FlashCard]) -> [KnowledgeDocument] {
        cards.map { card in
            KnowledgeDocument(
                id: card.id,
                deckID: deckID,
                title: card.title,
                aliases: [],
                tags: card.tags,
                summary: firstSentence(in: card.answer) ?? card.answer,
                keyPoints: [card.answer],
                examples: [],
                compareTo: [],
                pitfalls: [],
                avoidWhen: []
            )
        }
    }

    private func firstSentence(in text: String) -> String? {
        let cleaned = text.replacingOccurrences(of: "\n", with: " ")
        guard let sentence = cleaned.split(separator: ".", omittingEmptySubsequences: true).first else {
            return nil
        }

        let trimmed = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return nil }
        return trimmed + "."
    }
}

final class CustomKnowledgeStore {
    struct LoadResult {
        let documents: [String: [KnowledgeDocument]]
        let notices: [PersistenceNotice]
    }

    private let fileManager: FileManager
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let directoryName = "FlashCards"
    private let storageFilename = "custom-knowledge.json"
    private let baseDirectoryURL: URL?

    init(fileManager: FileManager = .default, baseDirectoryURL: URL? = nil) {
        self.fileManager = fileManager
        self.baseDirectoryURL = baseDirectoryURL
    }

    func loadDocumentMap() -> LoadResult {
        let outcome = loadKnowledgeDeckFiles()
        let documents = outcome.deckFiles.reduce(into: [:]) { result, deckFile in
            result[deckFile.deckID] = deckFile.documents
        }
        return LoadResult(documents: documents, notices: outcome.notices)
    }

    func upsert(_ deckFile: KnowledgeDeckFile) throws {
        var deckFiles = loadKnowledgeDeckFiles().deckFiles.filter { $0.deckID != deckFile.deckID }
        deckFiles.append(deckFile)

        try persist(deckFiles, to: storageURL())
    }

    private struct KnowledgeDeckLoadOutcome {
        let deckFiles: [KnowledgeDeckFile]
        let notices: [PersistenceNotice]
    }

    private func loadKnowledgeDeckFiles() -> KnowledgeDeckLoadOutcome {
        guard let url = try? storageURL(),
              fileManager.fileExists(atPath: url.path) else {
            return KnowledgeDeckLoadOutcome(deckFiles: [], notices: [])
        }

        do {
            let data = try Data(contentsOf: url, options: [.mappedIfSafe])
            let deckFiles = try decoder.decode([KnowledgeDeckFile].self, from: data)
            return sanitize(deckFiles, sourceURL: url)
        } catch {
            let backupURL = backupStore(at: url, suffix: "corrupt")
            return KnowledgeDeckLoadOutcome(
                deckFiles: [],
                notices: [
                    PersistenceNotice(
                        title: "Imported knowledge reset",
                        message: "The custom knowledge store was unreadable and has been moved to \(backupURL.lastPathComponent). Re-import any knowledge JSON you still need."
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

    private func sanitize(_ deckFiles: [KnowledgeDeckFile], sourceURL: URL) -> KnowledgeDeckLoadOutcome {
        var validDecks: [KnowledgeDeckFile] = []
        var invalidDecks: [String] = []

        for deckFile in deckFiles {
            do {
                validDecks.append(try deckFile.validated())
            } catch {
                invalidDecks.append(deckFile.deckID)
            }
        }

        guard invalidDecks.isEmpty == false else {
            return KnowledgeDeckLoadOutcome(deckFiles: validDecks, notices: [])
        }

        let backupURL = backupStore(at: sourceURL, suffix: "invalid")
        try? persist(validDecks, to: sourceURL)

        return KnowledgeDeckLoadOutcome(
            deckFiles: validDecks,
            notices: [
                PersistenceNotice(
                    title: "Imported knowledge repaired",
                    message: "Removed \(invalidDecks.count) invalid knowledge deck(s): \(summarizedNames(in: invalidDecks)). A backup of the previous store was saved as \(backupURL.lastPathComponent)."
                )
            ]
        )
    }

    private func persist(_ deckFiles: [KnowledgeDeckFile], to url: URL) throws {
        let data = try encoder.encode(deckFiles)
        try data.write(to: url, options: [.atomic])
    }

    private func backupStore(at url: URL, suffix: String) -> URL {
        let timestamp = Int(Date().timeIntervalSince1970)
        let backupURL = url.deletingLastPathComponent()
            .appendingPathComponent("custom-knowledge-\(suffix)-\(timestamp).json", isDirectory: false)
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

private extension NSLock {
    func withLock<T>(_ operation: () -> T) -> T {
        lock()
        defer { unlock() }
        return operation()
    }
}
