import Foundation

struct FlashCard: Identifiable, Hashable, Codable {
    let id: String
    let deck: DeckCategory
    let title: String
    let prompt: String
    let answer: String
    let tags: [String]
    var isMarkedForReview: Bool = false

    func matches(_ query: String) -> Bool {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return true }
        let haystack = [
            title,
            prompt,
            answer,
            tags.joined(separator: " ")
        ]
        .joined(separator: " ")
        .lowercased()

        return haystack.contains(trimmed.lowercased())
    }
}
