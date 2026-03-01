import Foundation

final class ReviewStore: ObservableObject {
    @Published private(set) var markedIDs: Set<String>

    private let defaults: UserDefaults
    private let storageKey = "flashcards.review.markedIDs"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let storedIDs = defaults.array(forKey: storageKey) as? [String] ?? []
        self.markedIDs = Set(storedIDs)
    }

    func mark(_ cardID: String) {
        guard markedIDs.insert(cardID).inserted else { return }
        persist()
    }

    func unmark(_ cardID: String) {
        guard markedIDs.remove(cardID) != nil else { return }
        persist()
    }

    func toggle(_ cardID: String) {
        if markedIDs.contains(cardID) {
            markedIDs.remove(cardID)
        } else {
            markedIDs.insert(cardID)
        }
        persist()
    }

    func markMany(_ cardIDs: [String]) {
        let initialCount = markedIDs.count
        markedIDs.formUnion(cardIDs)
        guard markedIDs.count != initialCount else { return }
        persist()
    }

    func unmarkMany(_ cardIDs: [String]) {
        let initialCount = markedIDs.count
        markedIDs.subtract(cardIDs)
        guard markedIDs.count != initialCount else { return }
        persist()
    }

    func allMarkedIDs() -> Set<String> {
        markedIDs
    }

    func isMarked(_ cardID: String) -> Bool {
        markedIDs.contains(cardID)
    }

    private func persist() {
        defaults.set(Array(markedIDs).sorted(), forKey: storageKey)
    }
}
