import Foundation

enum CardAssistAction: String, CaseIterable, Identifiable, Codable, Hashable {
    case explain
    case compare
    case quizMe = "quiz-me"
    case feedback

    var id: String { rawValue }

    var title: String {
        switch self {
        case .explain:
            return "Explain"
        case .compare:
            return "Compare"
        case .quizMe:
            return "Quiz Me"
        case .feedback:
            return "Feedback"
        }
    }

    var systemImage: String {
        switch self {
        case .explain:
            return "text.alignleft"
        case .compare:
            return "arrow.left.arrow.right"
        case .quizMe:
            return "questionmark.bubble"
        case .feedback:
            return "checklist"
        }
    }
}

struct CardAssistRequest: Hashable, Codable {
    let action: CardAssistAction
    let deckID: String
    let deckTitle: String
    let deckCategory: DeckCategory
    let deckCards: [FlashCard]
    let cardID: String
    let cardTitle: String
    let prompt: String
    let answer: String
    let tags: [String]
    let userInput: String?

    var cacheKey: String {
        let hash = CardAssistCache.hash(for: userInput)
        return "\(deckID)|\(cardID)|\(action.rawValue)|\(hash)|grounded-v1"
    }
}

struct CardAssistSnippet: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let detail: String
}

struct CardAssistResponse: Identifiable, Hashable, Codable {
    let action: CardAssistAction
    let deckID: String
    let cardID: String
    let headline: String
    let summary: String
    let bullets: [String]
    let snippets: [CardAssistSnippet]
    let footer: String
    let groundingLabel: String
    let sourceLabel: String
    let isGrounded: Bool
    let isFallback: Bool

    var id: String {
        "\(deckID)|\(cardID)|\(action.rawValue)"
    }

    static func unavailable(for request: CardAssistRequest, providerName: String) -> CardAssistResponse {
        CardAssistResponse(
            action: request.action,
            deckID: request.deckID,
            cardID: request.cardID,
            headline: request.action.title,
            summary: "No local model is available right now, but the card can still be assisted from local deck knowledge.",
            bullets: [
                "The card remains the primary source of truth.",
                "Retrieved deck knowledge can still power explain, compare, quiz, and feedback flows.",
                "You can plug in a supported on-device model later without changing the study UI."
            ],
            snippets: [],
            footer: "Offline fallback response.",
            groundingLabel: "Based on deck knowledge",
            sourceLabel: providerName,
            isGrounded: false,
            isFallback: true
        )
    }
}

protocol CardAssistService {
    var providerName: String { get }
    func respond(to request: CardAssistRequest) async -> CardAssistResponse
}

actor CardAssistCache {
    private struct CachedEntry: Codable {
        let response: CardAssistResponse
        let updatedAt: Date
    }

    static let shared = CardAssistCache()

    private let fileManager: FileManager
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let directoryName = "FlashDeck"
    private let storageFilename = "card-assist-cache.json"
    private let maxEntries = 120
    private let baseDirectoryURL: URL?
    private var cachedResponses: [String: CachedEntry]

    init(fileManager: FileManager = .default, baseDirectoryURL: URL? = nil) {
        self.fileManager = fileManager
        self.baseDirectoryURL = baseDirectoryURL
        self.cachedResponses = Self.loadCache(
            fileManager: fileManager,
            decoder: decoder,
            directoryName: directoryName,
            storageFilename: storageFilename,
            baseDirectoryURL: baseDirectoryURL
        )
    }

    func response(for request: CardAssistRequest) -> CardAssistResponse? {
        cachedResponses[request.cacheKey]?.response
    }

    func store(_ response: CardAssistResponse, for request: CardAssistRequest) {
        cachedResponses[request.cacheKey] = CachedEntry(response: response, updatedAt: Date())
        trimIfNeeded()
        persist()
    }

    func invalidate(deckID: String) {
        let prefix = "\(deckID)|"
        cachedResponses = cachedResponses.filter { $0.key.hasPrefix(prefix) == false }
        persist()
    }

    func clearAll() {
        cachedResponses = [:]

        guard let url = try? Self.storageURL(
            fileManager: fileManager,
            directoryName: directoryName,
            storageFilename: storageFilename,
            baseDirectoryURL: baseDirectoryURL
        ) else {
            return
        }

        guard fileManager.fileExists(atPath: url.path) else { return }
        try? fileManager.removeItem(at: url)
    }

    private func persist() {
        guard let url = try? Self.storageURL(
            fileManager: fileManager,
            directoryName: directoryName,
            storageFilename: storageFilename,
            baseDirectoryURL: baseDirectoryURL
        ),
              let data = try? encoder.encode(cachedResponses) else {
            return
        }

        try? data.write(to: url, options: [.atomic])
    }

    private static func loadCache(
        fileManager: FileManager,
        decoder: JSONDecoder,
        directoryName: String,
        storageFilename: String,
        baseDirectoryURL: URL?
    ) -> [String: CachedEntry] {
        guard let url = try? storageURL(
            fileManager: fileManager,
            directoryName: directoryName,
            storageFilename: storageFilename,
            baseDirectoryURL: baseDirectoryURL
        ),
              fileManager.fileExists(atPath: url.path) else {
            return [:]
        }

        do {
            let data = try Data(contentsOf: url, options: [.mappedIfSafe])
            return try decoder.decode([String: CachedEntry].self, from: data)
        } catch {
            recoverCorruptCache(at: url, fileManager: fileManager)
            return [:]
        }
    }

    private func trimIfNeeded() {
        guard cachedResponses.count > maxEntries else { return }

        let overflowCount = cachedResponses.count - maxEntries
        let keysToRemove = cachedResponses
            .sorted { $0.value.updatedAt < $1.value.updatedAt }
            .prefix(overflowCount)
            .map(\.key)

        keysToRemove.forEach { cachedResponses.removeValue(forKey: $0) }
    }

    private static func storageURL(
        fileManager: FileManager,
        directoryName: String,
        storageFilename: String,
        baseDirectoryURL: URL?
    ) throws -> URL {
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

    private static func recoverCorruptCache(at url: URL, fileManager: FileManager) {
        let timestamp = Int(Date().timeIntervalSince1970)
        let backupURL = url.deletingPathExtension().appendingPathExtension("corrupt-\(timestamp).json")
        try? fileManager.moveItem(at: url, to: backupURL)
    }

    static func hash(for input: String?) -> String {
        guard let input, input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            return "none"
        }

        let lowercased = input.lowercased().utf8
        var hash: UInt64 = 1469598103934665603

        for byte in lowercased {
            hash ^= UInt64(byte)
            hash &*= 1099511628211
        }

        return String(hash, radix: 16)
    }
}
