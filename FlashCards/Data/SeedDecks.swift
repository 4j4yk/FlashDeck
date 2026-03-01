import Foundation

enum SeedDecks {
    static func card(
        _ id: String,
        deck: DeckCategory,
        title: String,
        prompt: String,
        answer: String,
        tags: [String]
    ) -> FlashCard {
        FlashCard(
            id: id,
            deck: deck,
            title: title,
            prompt: prompt,
            answer: answer,
            tags: tags
        )
    }

    static let all: [Deck] = [
        Deck(
            id: .systemDesign,
            title: "System Design",
            subtitle: "Scale systems with explicit tradeoffs",
            symbolName: "square.3.layers.3d.top.filled",
            summary: "Capacity, consistency, resiliency, deployment, and observability fundamentals for technical interviews.",
            cards: SystemDesignDeck.cards
        ),
        Deck(
            id: .solutionArchitecture,
            title: "Solution Architecture",
            subtitle: "Frame solutions from business need to delivery",
            symbolName: "point.3.connected.trianglepath.dotted",
            summary: "Requirements, governance, migration, communication, risk, and leadership skills for real architecture work.",
            cards: SolutionArchitectureDeck.cards
        ),
        Deck(
            id: .awsServices,
            title: "AWS Services",
            subtitle: "Choose the right managed service quickly",
            symbolName: "cloud.fill",
            summary: "Compute, storage, security, networking, analytics, operations, and migration services with practical use cases.",
            cards: AWSDeck.cards
        )
    ]
}
