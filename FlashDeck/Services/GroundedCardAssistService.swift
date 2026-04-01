import Foundation

final class GroundedCardAssistService: CardAssistService {
    static let shared = GroundedCardAssistService(
        knowledgeStore: .shared,
        retriever: KnowledgeRetriever(),
        preferredProviders: [
            FoundationModelsGenerationProvider(),
            MLXGenerationProvider()
        ],
        fallbackProvider: TemplateGenerationProvider(),
        cache: .shared
    )

    let providerName = "Grounded Card Assist"

    private let knowledgeStore: KnowledgeStore
    private let retriever: KnowledgeRetriever
    private let preferredProviders: [any CardAssistGenerationProvider]
    private let fallbackProvider: TemplateGenerationProvider
    private let cache: CardAssistCache

    init(
        knowledgeStore: KnowledgeStore,
        retriever: KnowledgeRetriever,
        preferredProviders: [any CardAssistGenerationProvider],
        fallbackProvider: TemplateGenerationProvider,
        cache: CardAssistCache
    ) {
        self.knowledgeStore = knowledgeStore
        self.retriever = retriever
        self.preferredProviders = preferredProviders
        self.fallbackProvider = fallbackProvider
        self.cache = cache
    }

    func respond(to request: CardAssistRequest) async -> CardAssistResponse {
        if let cached = await cache.response(for: request) {
            return cached
        }

        let documents = knowledgeStore.documents(for: request)
        let retrieved = retriever.retrieve(for: request, documents: documents)
        let context = GroundedAssistContext(request: request, knowledge: retrieved)

        for provider in preferredProviders where provider.isAvailable {
            if let response = await provider.generate(from: context) {
                await cache.store(response, for: request)
                return response
            }
        }

        if let response = await fallbackProvider.generate(from: context) {
            await cache.store(response, for: request)
            return response
        }

        let response = CardAssistResponse.unavailable(for: request, providerName: providerName)
        await cache.store(response, for: request)
        return response
    }
}
