import Foundation

private enum KnowledgeImportLimits {
    static let maxDeckIDLength = 80
    static let maxDocumentsPerDeck = 400
    static let maxDocumentIDLength = 96
    static let maxTitleLength = 120
    static let maxAliasesPerDocument = 12
    static let maxAliasLength = 80
    static let maxTagsPerDocument = 12
    static let maxTagLength = 40
    static let maxSummaryLength = 700
    static let maxKeyPoints = 8
    static let maxPointLength = 280
    static let maxExamples = 6
    static let maxCompareTo = 8
    static let maxPitfalls = 6
    static let maxAvoidWhen = 6
}

struct KnowledgeDeckFile: Codable, Hashable {
    let deckID: String
    let documents: [KnowledgeDocument]

    enum CodingKeys: String, CodingKey {
        case deckID = "deck_id"
        case documents
    }

    func validated() throws -> KnowledgeDeckFile {
        let trimmedDeckID = deckID.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedDeckID.isEmpty == false else {
            throw KnowledgeImportError.invalidKnowledge("Knowledge deck id is required.")
        }

        guard trimmedDeckID.count <= KnowledgeImportLimits.maxDeckIDLength else {
            throw KnowledgeImportError.invalidKnowledge("Knowledge deck ids must be \(KnowledgeImportLimits.maxDeckIDLength) characters or fewer.")
        }

        guard documents.isEmpty == false else {
            throw KnowledgeImportError.invalidKnowledge("A knowledge file must include at least one document.")
        }

        guard documents.count <= KnowledgeImportLimits.maxDocumentsPerDeck else {
            throw KnowledgeImportError.invalidKnowledge("Knowledge files are limited to \(KnowledgeImportLimits.maxDocumentsPerDeck) documents per import.")
        }

        var seenDocumentIDs = Set<String>()
        let normalizedDocuments = try documents.map { document in
            let normalized = try document.validated(defaultDeckID: trimmedDeckID)

            guard seenDocumentIDs.insert(normalized.id).inserted else {
                throw KnowledgeImportError.invalidKnowledge("Duplicate knowledge document id \"\(normalized.id)\" in deck \"\(trimmedDeckID)\".")
            }

            return normalized
        }

        return KnowledgeDeckFile(deckID: trimmedDeckID, documents: normalizedDocuments)
    }
}

struct KnowledgeDocument: Identifiable, Codable, Hashable {
    let id: String
    let deckID: String?
    let title: String
    let aliases: [String]
    let tags: [String]
    let summary: String
    let keyPoints: [String]
    let examples: [String]
    let compareTo: [String]
    let pitfalls: [String]
    let avoidWhen: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case deckID = "deck_id"
        case title
        case aliases
        case tags
        case summary
        case keyPoints = "key_points"
        case examples
        case compareTo = "compare_to"
        case pitfalls
        case avoidWhen = "avoid_when"
    }

    func validated(defaultDeckID: String) throws -> KnowledgeDocument {
        let trimmedID = id.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDeckID = (deckID ?? defaultDeckID).trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSummary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedAliases = normalize(entries: aliases, maxCount: KnowledgeImportLimits.maxAliasesPerDocument)
        let normalizedTags = normalize(entries: tags, maxCount: KnowledgeImportLimits.maxTagsPerDocument)
        let normalizedKeyPoints = normalize(entries: keyPoints, maxCount: KnowledgeImportLimits.maxKeyPoints)
        let normalizedExamples = normalize(entries: examples, maxCount: KnowledgeImportLimits.maxExamples)
        let normalizedCompareTo = normalize(entries: compareTo, maxCount: KnowledgeImportLimits.maxCompareTo)
        let normalizedPitfalls = normalize(entries: pitfalls, maxCount: KnowledgeImportLimits.maxPitfalls)
        let normalizedAvoidWhen = normalize(entries: avoidWhen, maxCount: KnowledgeImportLimits.maxAvoidWhen)

        guard trimmedID.isEmpty == false else {
            throw KnowledgeImportError.invalidKnowledge("Every knowledge document needs an id.")
        }

        guard trimmedID.count <= KnowledgeImportLimits.maxDocumentIDLength else {
            throw KnowledgeImportError.invalidKnowledge("Knowledge document ids must be \(KnowledgeImportLimits.maxDocumentIDLength) characters or fewer.")
        }

        guard trimmedDeckID.isEmpty == false else {
            throw KnowledgeImportError.invalidKnowledge("Every knowledge document must resolve to a deck id.")
        }

        guard trimmedDeckID.count <= KnowledgeImportLimits.maxDeckIDLength else {
            throw KnowledgeImportError.invalidKnowledge("Knowledge deck ids must be \(KnowledgeImportLimits.maxDeckIDLength) characters or fewer.")
        }

        guard trimmedTitle.isEmpty == false else {
            throw KnowledgeImportError.invalidKnowledge("Every knowledge document needs a title.")
        }

        guard trimmedTitle.count <= KnowledgeImportLimits.maxTitleLength else {
            throw KnowledgeImportError.invalidKnowledge("Knowledge document titles must be \(KnowledgeImportLimits.maxTitleLength) characters or fewer.")
        }

        guard trimmedSummary.isEmpty == false else {
            throw KnowledgeImportError.invalidKnowledge("Knowledge document \"\(trimmedID)\" is missing its summary.")
        }

        guard trimmedSummary.count <= KnowledgeImportLimits.maxSummaryLength else {
            throw KnowledgeImportError.invalidKnowledge("Knowledge summaries must be \(KnowledgeImportLimits.maxSummaryLength) characters or fewer.")
        }

        try validateLengths(normalizedAliases, maxLength: KnowledgeImportLimits.maxAliasLength, message: "Knowledge aliases must be \(KnowledgeImportLimits.maxAliasLength) characters or fewer.")
        try validateLengths(normalizedTags, maxLength: KnowledgeImportLimits.maxTagLength, message: "Knowledge tags must be \(KnowledgeImportLimits.maxTagLength) characters or fewer.")
        try validateLengths(normalizedKeyPoints, maxLength: KnowledgeImportLimits.maxPointLength, message: "Knowledge key points must be \(KnowledgeImportLimits.maxPointLength) characters or fewer.")
        try validateLengths(normalizedExamples, maxLength: KnowledgeImportLimits.maxPointLength, message: "Knowledge examples must be \(KnowledgeImportLimits.maxPointLength) characters or fewer.")
        try validateLengths(normalizedCompareTo, maxLength: KnowledgeImportLimits.maxDocumentIDLength, message: "Knowledge compare-to ids must be \(KnowledgeImportLimits.maxDocumentIDLength) characters or fewer.")
        try validateLengths(normalizedPitfalls, maxLength: KnowledgeImportLimits.maxPointLength, message: "Knowledge pitfalls must be \(KnowledgeImportLimits.maxPointLength) characters or fewer.")
        try validateLengths(normalizedAvoidWhen, maxLength: KnowledgeImportLimits.maxPointLength, message: "Knowledge avoid-when entries must be \(KnowledgeImportLimits.maxPointLength) characters or fewer.")

        return KnowledgeDocument(
            id: trimmedID,
            deckID: trimmedDeckID,
            title: trimmedTitle,
            aliases: normalizedAliases,
            tags: normalizedTags,
            summary: trimmedSummary,
            keyPoints: normalizedKeyPoints,
            examples: normalizedExamples,
            compareTo: normalizedCompareTo,
            pitfalls: normalizedPitfalls,
            avoidWhen: normalizedAvoidWhen
        )
    }

    private func normalize(entries: [String], maxCount: Int) -> [String] {
        let normalizedEntries = Array(
            Set(
                entries
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()

        return Array(normalizedEntries.prefix(maxCount))
    }

    private func validateLengths(_ entries: [String], maxLength: Int, message: String) throws {
        if entries.contains(where: { $0.count > maxLength }) {
            throw KnowledgeImportError.invalidKnowledge(message)
        }
    }
}

struct RetrievedKnowledge: Identifiable, Hashable {
    let document: KnowledgeDocument
    let score: Int
    let matchedTerms: [String]

    var id: String { document.id }
}

enum KnowledgeImportError: LocalizedError {
    case invalidKnowledge(String)

    var errorDescription: String? {
        switch self {
        case let .invalidKnowledge(message):
            return message
        }
    }
}
