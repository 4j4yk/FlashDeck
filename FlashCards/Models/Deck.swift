import Foundation

struct Deck: Identifiable, Hashable {
    let id: DeckCategory
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
    let deckID: DeckCategory
    let deckTitle: String
    let mode: StudyMode
    let cards: [FlashCard]
    let startIndex: Int
}

enum DeckCategory: String, CaseIterable, Identifiable, Codable {
    case systemDesign = "system-design"
    case solutionArchitecture = "solution-architecture"
    case awsServices = "aws-services"

    var id: String { rawValue }
}
