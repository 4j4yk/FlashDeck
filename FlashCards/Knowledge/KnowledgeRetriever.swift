import Foundation

struct KnowledgeRetriever {
    func retrieve(for request: CardAssistRequest, documents: [KnowledgeDocument], limit: Int = 3) -> [RetrievedKnowledge] {
        guard documents.isEmpty == false else { return [] }

        let normalizedTitle = normalize(request.cardTitle)
        let queryTokens = tokenSet(
            [
                request.cardTitle,
                request.prompt,
                request.answer,
                request.userInput ?? "",
                request.tags.joined(separator: " ")
            ].joined(separator: " ")
        )

        let baseMatches = documents
            .map { document in
                score(document: document, normalizedTitle: normalizedTitle, queryTokens: queryTokens, requestTags: request.tags)
            }
            .filter { $0.score > 0 }
            .sorted {
                if $0.score == $1.score {
                    return $0.document.title < $1.document.title
                }
                return $0.score > $1.score
            }

        guard baseMatches.isEmpty == false else {
            return Array(documents.prefix(limit)).map { RetrievedKnowledge(document: $0, score: 1, matchedTerms: []) }
        }

        var ranked = Array(baseMatches.prefix(limit))
        let byID = Dictionary(uniqueKeysWithValues: documents.map { ($0.id, $0) })

        if request.action == .compare, let primary = ranked.first {
            for relatedID in primary.document.compareTo {
                guard ranked.contains(where: { $0.document.id == relatedID }) == false,
                      let related = byID[relatedID] else { continue }

                ranked.append(
                    RetrievedKnowledge(
                        document: related,
                        score: max(primary.score - 5, 1),
                        matchedTerms: primary.matchedTerms + ["related"]
                    )
                )
            }
        }

        return Array(ranked.prefix(limit))
    }

    private func score(
        document: KnowledgeDocument,
        normalizedTitle: String,
        queryTokens: Set<String>,
        requestTags: [String]
    ) -> RetrievedKnowledge {
        let normalizedDocumentTitle = normalize(document.title)
        let normalizedAliases = document.aliases.map(normalize)
        let normalizedTags = document.tags.map(normalize)

        var score = 0
        var matchedTerms: [String] = []

        if normalizedDocumentTitle == normalizedTitle {
            score += 140
            matchedTerms.append("title")
        } else if normalizedDocumentTitle.contains(normalizedTitle) || normalizedTitle.contains(normalizedDocumentTitle) {
            score += 70
            matchedTerms.append("title")
        }

        if normalizedAliases.contains(normalizedTitle) {
            score += 110
            matchedTerms.append("alias")
        }

        for tag in requestTags.map(normalize) where normalizedTags.contains(tag) {
            score += 24
            matchedTerms.append(tag)
        }

        let keywordSource = tokenSet(
            [
                document.title,
                document.aliases.joined(separator: " "),
                document.tags.joined(separator: " "),
                document.summary,
                document.keyPoints.joined(separator: " "),
                document.examples.joined(separator: " "),
                document.pitfalls.joined(separator: " "),
                document.avoidWhen.joined(separator: " ")
            ].joined(separator: " ")
        )

        for token in queryTokens where keywordSource.contains(token) {
            score += token.count > 7 ? 12 : 8
            matchedTerms.append(token)
        }

        if queryTokens.contains("compare"), document.compareTo.isEmpty == false {
            score += 10
            matchedTerms.append("compare")
        }

        return RetrievedKnowledge(
            document: document,
            score: score,
            matchedTerms: Array(Set(matchedTerms)).sorted()
        )
    }

    private func normalize(_ text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9]+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func tokenSet(_ text: String) -> Set<String> {
        Set(
            normalize(text)
                .split(separator: " ")
                .map(String.init)
                .filter { $0.count >= 3 }
        )
    }
}
