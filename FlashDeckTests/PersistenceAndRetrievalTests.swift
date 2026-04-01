import Foundation
import XCTest
@testable import FlashDeck

final class PersistenceAndRetrievalTests: XCTestCase {
    private var tempDirectoryURL: URL!
    private let fileManager = FileManager.default

    override func setUpWithError() throws {
        tempDirectoryURL = fileManager.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let tempDirectoryURL {
            try? fileManager.removeItem(at: tempDirectoryURL)
        }
        tempDirectoryURL = nil
    }

    func testCustomDeckStoreRepairsInvalidDeckEntries() throws {
        let store = CustomDeckStore(fileManager: fileManager, baseDirectoryURL: tempDirectoryURL)
        let validDeck = DeckFile.sample
        let invalidDeck = DeckFile(
            id: "broken-deck",
            category: .custom,
            title: "",
            subtitle: "Broken",
            symbolName: "tray.fill",
            summary: "This deck should not survive validation.",
            cards: [
                DeckFileCard(
                    id: "broken-card",
                    title: "Broken Card",
                    prompt: "Why is this deck invalid?",
                    answer: "Because the deck title is missing.",
                    tags: ["broken"]
                )
            ]
        )

        try seed(
            payload: [validDeck, invalidDeck],
            storageFilename: "custom-decks.json"
        )

        let result = store.loadDecks()

        XCTAssertEqual(result.decks.map(\.id), [validDeck.id])
        XCTAssertEqual(result.notices.count, 1)

        let repaired = try JSONDecoder().decode(
            [DeckFile].self,
            from: Data(contentsOf: storageURL(filename: "custom-decks.json"))
        )
        XCTAssertEqual(repaired.map(\.id), [validDeck.id])
        XCTAssertEqual(backupFilenames(prefix: "custom-decks-invalid-").count, 1)
    }

    func testCustomKnowledgeStoreRepairsInvalidKnowledgeEntries() throws {
        let store = CustomKnowledgeStore(fileManager: fileManager, baseDirectoryURL: tempDirectoryURL)
        let validDeck = KnowledgeDeckFile(
            deckID: "aws-services",
            documents: [
                KnowledgeDocument(
                    id: "lambda",
                    deckID: "aws-services",
                    title: "Lambda",
                    aliases: ["aws lambda"],
                    tags: ["compute", "serverless"],
                    summary: "Lambda runs code without managing servers.",
                    keyPoints: ["Good for event-driven tasks."],
                    examples: ["Resize an image after an S3 upload."],
                    compareTo: ["ecs"],
                    pitfalls: ["Cold starts can matter on latency-sensitive paths."],
                    avoidWhen: ["Long-running, stateful workloads."]
                )
            ]
        )
        let invalidDeck = KnowledgeDeckFile(
            deckID: "broken-knowledge",
            documents: [
                KnowledgeDocument(
                    id: "",
                    deckID: "broken-knowledge",
                    title: "Broken Knowledge",
                    aliases: [],
                    tags: [],
                    summary: "",
                    keyPoints: [],
                    examples: [],
                    compareTo: [],
                    pitfalls: [],
                    avoidWhen: []
                )
            ]
        )

        try seed(
            payload: [validDeck, invalidDeck],
            storageFilename: "custom-knowledge.json"
        )

        let result = store.loadDocumentMap()

        XCTAssertEqual(result.documents["aws-services"]?.count, 1)
        XCTAssertNil(result.documents["broken-knowledge"])
        XCTAssertEqual(result.notices.count, 1)
        XCTAssertEqual(backupFilenames(prefix: "custom-knowledge-invalid-").count, 1)
    }

    func testKnowledgeRetrieverPrefersExactTitleMatches() {
        let documents = [
            KnowledgeDocument(
                id: "lambda",
                deckID: "aws-services",
                title: "Lambda",
                aliases: ["aws lambda"],
                tags: ["compute", "serverless"],
                summary: "Lambda runs code without managing servers.",
                keyPoints: ["Good for event-driven tasks."],
                examples: [],
                compareTo: ["ecs"],
                pitfalls: [],
                avoidWhen: []
            ),
            KnowledgeDocument(
                id: "ecs",
                deckID: "aws-services",
                title: "ECS",
                aliases: ["elastic container service"],
                tags: ["compute", "containers"],
                summary: "ECS runs containers.",
                keyPoints: ["Works well with Fargate or EC2 capacity."],
                examples: [],
                compareTo: ["lambda"],
                pitfalls: [],
                avoidWhen: []
            )
        ]

        let card = FlashCard(
            id: "card-lambda",
            deckID: "aws-services",
            title: "Lambda",
            prompt: "When should you choose AWS Lambda?",
            answer: "Use Lambda for event-driven, short-lived compute.",
            tags: ["compute", "serverless"]
        )
        let request = CardAssistRequest(
            action: .explain,
            deckID: "aws-services",
            deckTitle: "AWS Services",
            deckCategory: .awsServices,
            deckCards: [card],
            cardID: card.id,
            cardTitle: card.title,
            prompt: card.prompt,
            answer: card.answer,
            tags: card.tags,
            userInput: nil
        )

        let matches = KnowledgeRetriever().retrieve(for: request, documents: documents, limit: 2)

        XCTAssertEqual(matches.first?.document.id, "lambda")
        XCTAssertGreaterThan(matches.first?.score ?? 0, matches.last?.score ?? 0)
    }

    func testCardAssistCacheStoresAndInvalidatesDeckScopedResponses() async {
        let cache = CardAssistCache(fileManager: fileManager, baseDirectoryURL: tempDirectoryURL)
        let card = FlashCard(
            id: "lambda-card",
            deckID: "aws-services",
            title: "Lambda",
            prompt: "Explain Lambda.",
            answer: "Lambda runs code without managing servers.",
            tags: ["aws", "compute"]
        )
        let request = CardAssistRequest(
            action: .explain,
            deckID: "aws-services",
            deckTitle: "AWS Services",
            deckCategory: .awsServices,
            deckCards: [card],
            cardID: card.id,
            cardTitle: card.title,
            prompt: card.prompt,
            answer: card.answer,
            tags: card.tags,
            userInput: nil
        )
        let response = CardAssistResponse(
            action: .explain,
            deckID: "aws-services",
            cardID: card.id,
            headline: "Explain",
            summary: "Lambda is grounded in local deck knowledge.",
            bullets: ["Runs event-driven code without server management."],
            snippets: [],
            footer: "Offline response.",
            groundingLabel: "Based on deck knowledge",
            sourceLabel: "Template",
            isGrounded: true,
            isFallback: false
        )

        await cache.store(response, for: request)
        let cachedBeforeInvalidate = await cache.response(for: request)

        XCTAssertEqual(cachedBeforeInvalidate?.summary, response.summary)

        await cache.invalidate(deckID: "aws-services")
        let cachedAfterInvalidate = await cache.response(for: request)

        XCTAssertNil(cachedAfterInvalidate)
    }

    func testImportedKnowledgeAppliesOnlyToExactDeckIDMatches() throws {
        let customKnowledgeStore = CustomKnowledgeStore(fileManager: fileManager, baseDirectoryURL: tempDirectoryURL)
        let knowledgeStore = KnowledgeStore(bundle: Bundle(for: Self.self), customKnowledgeStore: customKnowledgeStore)
        let importedKnowledge = KnowledgeDeckFile(
            deckID: "aws-services",
            documents: [
                KnowledgeDocument(
                    id: "lambda-imported",
                    deckID: "aws-services",
                    title: "Lambda",
                    aliases: ["aws lambda"],
                    tags: ["compute", "serverless"],
                    summary: "Imported knowledge for the built-in AWS deck.",
                    keyPoints: ["Imported exact-match knowledge should win only for the matching deck id."],
                    examples: [],
                    compareTo: [],
                    pitfalls: [],
                    avoidWhen: []
                )
            ]
        )

        _ = try knowledgeStore.importKnowledgeDeckFile(importedKnowledge)

        let customCard = FlashCard(
            id: "custom-lambda-card",
            deckID: "my-aws-deck",
            title: "Lambda",
            prompt: "Explain Lambda.",
            answer: "Use Lambda for short-lived event-driven compute.",
            tags: ["aws", "compute", "serverless"]
        )
        let customDeckRequest = CardAssistRequest(
            action: .explain,
            deckID: "my-aws-deck",
            deckTitle: "My AWS Deck",
            deckCategory: .awsServices,
            deckCards: [customCard],
            cardID: customCard.id,
            cardTitle: customCard.title,
            prompt: customCard.prompt,
            answer: customCard.answer,
            tags: customCard.tags,
            userInput: nil
        )

        let customDeckDocuments = knowledgeStore.documents(for: customDeckRequest)
        XCTAssertEqual(customDeckDocuments.first?.id, customCard.id)

        let builtInRequest = CardAssistRequest(
            action: .explain,
            deckID: "aws-services",
            deckTitle: "AWS Services",
            deckCategory: .awsServices,
            deckCards: [customCard],
            cardID: customCard.id,
            cardTitle: customCard.title,
            prompt: customCard.prompt,
            answer: customCard.answer,
            tags: customCard.tags,
            userInput: nil
        )

        let builtInDocuments = knowledgeStore.documents(for: builtInRequest)
        XCTAssertEqual(builtInDocuments.first?.id, "lambda-imported")
    }

    private func seed<T: Encodable>(payload: T, storageFilename: String) throws {
        let directoryURL = tempDirectoryURL.appendingPathComponent("FlashDeck", isDirectory: true)
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(payload)
        try data.write(to: directoryURL.appendingPathComponent(storageFilename), options: [.atomic])
    }

    private func storageURL(filename: String) -> URL {
        tempDirectoryURL
            .appendingPathComponent("FlashDeck", isDirectory: true)
            .appendingPathComponent(filename)
    }

    private func backupFilenames(prefix: String) -> [String] {
        let directoryURL = tempDirectoryURL.appendingPathComponent("FlashDeck", isDirectory: true)
        let contents = (try? fileManager.contentsOfDirectory(atPath: directoryURL.path)) ?? []
        return contents.filter { $0.hasPrefix(prefix) }
    }
}
