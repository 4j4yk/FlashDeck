import Foundation

struct GroundedAssistContext {
    let request: CardAssistRequest
    let knowledge: [RetrievedKnowledge]

    var primaryDocument: KnowledgeDocument? {
        knowledge.first?.document
    }

    var relatedDocuments: [KnowledgeDocument] {
        Array(knowledge.dropFirst().map(\.document))
    }

    func snippets(limit: Int = 3) -> [CardAssistSnippet] {
        knowledge.prefix(limit).map { item in
            let detail = item.document.keyPoints.first ?? item.document.summary
            return CardAssistSnippet(
                id: item.document.id,
                title: item.document.title,
                detail: detail
            )
        }
    }
}

protocol CardAssistGenerationProvider {
    var providerName: String { get }
    var isAvailable: Bool { get }
    func generate(from context: GroundedAssistContext) async -> CardAssistResponse?
}

struct TemplateGenerationProvider: CardAssistGenerationProvider {
    let providerName = "Template Grounded Assist"
    let isAvailable = true

    func generate(from context: GroundedAssistContext) async -> CardAssistResponse? {
        let request = context.request
        let primary = context.primaryDocument
        let snippets = context.snippets()

        let summary = primary?.summary ?? firstSentence(in: request.answer) ?? request.answer
        let groundingLabel = snippets.isEmpty ? "Based on current deck cards" : "Based on deck knowledge"

        switch request.action {
        case .explain:
            return CardAssistResponse(
                action: request.action,
                deckID: request.deckID,
                cardID: request.cardID,
                headline: "Explain \(request.cardTitle)",
                summary: summary,
                bullets: [
                    primary?.keyPoints.first ?? "Start with what the concept is and the problem it solves.",
                    primary?.keyPoints.dropFirst().first ?? "Then explain when you would pick it in a real design.",
                    primary?.pitfalls.first ?? "Close with the main tradeoff or operational caveat."
                ],
                snippets: snippets,
                footer: primary?.examples.first ?? "Keep the answer scoped to the current deck concept.",
                groundingLabel: groundingLabel,
                sourceLabel: providerName,
                isGrounded: snippets.isEmpty == false,
                isFallback: false
            )

        case .compare:
            let comparisonTarget = context.relatedDocuments.first ?? primary.flatMap { relatedPrimary(for: $0, in: context.relatedDocuments) }
            return CardAssistResponse(
                action: request.action,
                deckID: request.deckID,
                cardID: request.cardID,
                headline: "Compare \(request.cardTitle)",
                summary: comparisonTarget.map { "\(request.cardTitle) is best understood against \($0.title)." } ?? "Compare the concept to the simpler adjacent option before defending added complexity.",
                bullets: [
                    primary.map { "Use \(request.cardTitle) when \($0.summary.lowercased())" } ?? "State when the primary concept is the right fit.",
                    comparisonTarget.map { "Compare against \($0.title): \($0.summary)" } ?? "Name the most likely alternative and the tradeoff between them.",
                    primary?.pitfalls.first ?? "Call out the operational cost, failure mode, or scaling limit that changes the decision."
                ],
                snippets: snippets,
                footer: "Ground the comparison in fit, complexity, cost, and operational burden.",
                groundingLabel: groundingLabel,
                sourceLabel: providerName,
                isGrounded: snippets.isEmpty == false,
                isFallback: false
            )

        case .quizMe:
            return CardAssistResponse(
                action: request.action,
                deckID: request.deckID,
                cardID: request.cardID,
                headline: "Quiz Me on \(request.cardTitle)",
                summary: request.prompt,
                bullets: [
                    "Answer in one line: what is it?",
                    primary?.keyPoints.first ?? "Then say when to use it and what outcome it improves.",
                    primary?.pitfalls.first ?? "Finish with one tradeoff, pitfall, or avoid-when case."
                ],
                snippets: snippets,
                footer: primary?.examples.first ?? "Flip the card after answering to self-check.",
                groundingLabel: groundingLabel,
                sourceLabel: providerName,
                isGrounded: snippets.isEmpty == false,
                isFallback: false
            )

        case .feedback:
            return CardAssistResponse(
                action: request.action,
                deckID: request.deckID,
                cardID: request.cardID,
                headline: "Feedback for \(request.cardTitle)",
                summary: "Use this deck-grounded rubric to judge your own answer before moving on.",
                bullets: [
                    "Clarity: did you define the concept without vague language?",
                    primary?.keyPoints.first.map { "Coverage: did you include \($0.lowercased())" } ?? "Coverage: did you explain when to use it?",
                    primary?.pitfalls.first.map { "Depth: did you mention \($0.lowercased())" } ?? "Depth: did you include a tradeoff or failure mode?"
                ],
                snippets: snippets,
                footer: primary?.avoidWhen.first ?? "If any area felt weak, mark the card for review.",
                groundingLabel: groundingLabel,
                sourceLabel: providerName,
                isGrounded: snippets.isEmpty == false,
                isFallback: false
            )
        }
    }

    private func relatedPrimary(for document: KnowledgeDocument, in related: [KnowledgeDocument]) -> KnowledgeDocument? {
        related.first { candidate in
            document.compareTo.contains(candidate.id)
        }
    }

    private func firstSentence(in text: String) -> String? {
        let normalized = text.replacingOccurrences(of: "\n", with: " ")
        guard let sentence = normalized.split(separator: ".", omittingEmptySubsequences: true).first else {
            return nil
        }

        let trimmed = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return nil }
        return trimmed + "."
    }
}

struct FoundationModelsGenerationProvider: CardAssistGenerationProvider {
    let providerName = "Foundation Models"
    let isAvailable = false

    func generate(from context: GroundedAssistContext) async -> CardAssistResponse? {
        nil
    }
}

struct MLXGenerationProvider: CardAssistGenerationProvider {
    let providerName = "MLX Local Model"
    let isAvailable = false

    func generate(from context: GroundedAssistContext) async -> CardAssistResponse? {
        nil
    }
}
