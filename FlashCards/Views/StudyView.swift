import SwiftUI

struct StudyView: View {
    @EnvironmentObject private var reviewStore: ReviewStore

    let session: StudySession

    @State private var currentIndex: Int
    @State private var orderedCards: [FlashCard]
    @State private var isFlipped = false
    @State private var isShuffled = false
    @State private var dragOffset: CGFloat = 0

    init(session: StudySession) {
        self.session = session
        let clampedIndex = min(max(session.startIndex, 0), max(session.cards.count - 1, 0))
        _currentIndex = State(initialValue: clampedIndex)
        _orderedCards = State(initialValue: session.cards)
    }

    private var currentCard: FlashCard? {
        guard orderedCards.indices.contains(currentIndex) else { return nil }
        return orderedCards[currentIndex]
    }

    private var progressText: String {
        guard orderedCards.isEmpty == false else { return "0 / 0" }
        return "\(currentIndex + 1) / \(orderedCards.count)"
    }

    private var progressValue: Double {
        guard orderedCards.isEmpty == false else { return 0 }
        return Double(currentIndex + 1) / Double(orderedCards.count)
    }

    private var progressPercentText: String {
        "\(Int((progressValue * 100).rounded()))%"
    }

    private var dragProgress: CGFloat {
        min(abs(dragOffset) / 160, 1)
    }

    private var canMoveForward: Bool {
        currentIndex < orderedCards.count - 1
    }

    private var canMoveBackward: Bool {
        currentIndex > 0
    }

    var body: some View {
        ZStack {
            AppBackground(accentDeck: session.deckID)

            if let currentCard {
                VStack(spacing: 22) {
                    header

                    FlipFlashCardView(
                        card: currentCard,
                        deckID: session.deckID,
                        isMarked: reviewStore.isMarked(currentCard.id),
                        onToggle: toggleCardFace,
                        isFlipped: $isFlipped
                    )
                    .id(currentCard.id)
                    .frame(maxWidth: .infinity)
                    .frame(height: AppTheme.cardHeight)
                    .offset(x: dragOffset)
                    .rotationEffect(.degrees(Double(dragOffset / 18)))
                    .scaleEffect(1 - (dragProgress * 0.035))
                    .animation(.interactiveSpring(response: 0.26, dampingFraction: 0.86), value: dragOffset)
                    .highPriorityGesture(dragGesture)
                    .padding(.horizontal, 20)

                    controls(for: currentCard)
                }
                .padding(.top, 16)
                .padding(.bottom, 30)
            } else {
                EmptyStateView(
                    symbolName: "rectangle.stack.badge.minus",
                    title: "No cards available",
                    message: "Open a deck from the browser and start a study session there."
                )
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle(session.deckTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    toggleShuffle()
                } label: {
                    Image(systemName: isShuffled ? "shuffle.circle.fill" : "shuffle.circle")
                }
                .accessibilityLabel(isShuffled ? "Disable shuffle" : "Enable shuffle")
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 7) {
                    Text(session.mode.title.uppercased())
                        .font(.system(.caption2, design: .rounded).weight(.bold))
                        .foregroundStyle(AppTheme.tertiaryText)

                    Text(session.deckTitle)
                        .font(.system(size: 29, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)

                    Text(session.mode.detailText(cardCount: orderedCards.count))
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(AppTheme.secondaryText)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text(progressPercentText)
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundStyle(AppTheme.primaryText)

                    Text(progressText)
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(minWidth: 74)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppTheme.surfaceGradient)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppTheme.outlineGradient, lineWidth: 1)
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Session progress")
                .accessibilityValue("\(progressText). \(progressPercentText)")
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.secondarySurface)
                        .overlay(
                            Capsule()
                                .stroke(AppTheme.line, lineWidth: 1)
                        )

                    Capsule()
                        .fill(AppTheme.gradient(for: session.deckID))
                        .frame(width: progressWidth(totalWidth: proxy.size.width))
                }
            }
            .frame(height: 8)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Progress bar")
            .accessibilityValue(progressPercentText)
        }
        .padding(.horizontal, 20)
    }

    private func controls(for card: FlashCard) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                circularButton(symbolName: "chevron.left", isEnabled: canMoveBackward) {
                    movePrevious()
                }
                .accessibilityLabel("Previous card")
                .accessibilityHint("Moves to the previous card in this session.")

                Button {
                    toggleCardFace()
                } label: {
                    Label(isFlipped ? "Question" : "Answer", systemImage: "arrow.triangle.2.circlepath")
                        .font(.system(.headline, design: .rounded).weight(.semibold))
                        .foregroundStyle(AppTheme.primaryText)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(AppTheme.surfaceGradient)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(AppTheme.outlineGradient, lineWidth: 1)
                        )
                        .shadow(color: AppTheme.shadowColor.opacity(0.40), radius: 16, x: 0, y: 8)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isFlipped ? "Show question" : "Show answer")
                .accessibilityHint("Double tap to flip the current card.")

                circularButton(symbolName: "chevron.right", isEnabled: canMoveForward) {
                    moveNext()
                }
                .accessibilityLabel("Next card")
                .accessibilityHint("Moves to the next card in this session.")
            }

            Button {
                reviewStore.toggle(card.id)
                Haptics.selection()
            } label: {
                Label(
                    reviewStore.isMarked(card.id) ? "Marked for review" : "Mark for review",
                    systemImage: reviewStore.isMarked(card.id) ? "bookmark.fill" : "bookmark"
                )
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundStyle(reviewStore.isMarked(card.id) ? .white : AppTheme.primaryText)
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            reviewStore.isMarked(card.id)
                                ? AnyShapeStyle(AppTheme.gradient(for: session.deckID))
                                : AnyShapeStyle(AppTheme.surfaceGradient)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(reviewStore.isMarked(card.id) ? 0.14 : 0.18), lineWidth: 1)
                )
                .shadow(color: AppTheme.shadowColor.opacity(0.42), radius: 16, x: 0, y: 8)
            }
            .buttonStyle(.plain)
            .accessibilityValue(reviewStore.isMarked(card.id) ? "Marked" : "Not marked")
        }
        .padding(.horizontal, 20)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 24)
            .onChanged { value in
                let translation = value.translation.width
                let isAtEdge = (translation < 0 && canMoveForward == false) || (translation > 0 && canMoveBackward == false)
                dragOffset = isAtEdge ? translation * 0.28 : translation * 0.92
            }
            .onEnded { value in
                let projected = value.predictedEndTranslation.width
                let resolved = abs(projected) > abs(value.translation.width) ? projected : value.translation.width
                let threshold: CGFloat = 72

                if resolved <= -threshold {
                    moveNext()
                } else if resolved >= threshold {
                    movePrevious()
                } else {
                    withAnimation(.interactiveSpring(response: 0.24, dampingFraction: 0.84)) {
                        dragOffset = 0
                    }
                    Haptics.soft(0.34)
                }
            }
    }

    private func circularButton(symbolName: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbolName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(isEnabled ? AppTheme.primaryText : AppTheme.secondaryText)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(AppTheme.surfaceGradient)
                )
                .overlay(
                    Circle()
                        .stroke(AppTheme.outlineGradient, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(isEnabled == false)
        .opacity(isEnabled ? 1 : 0.48)
        .shadow(color: AppTheme.shadowColor.opacity(0.32), radius: 14, x: 0, y: 8)
    }

    private func toggleCardFace() {
        withAnimation(.interactiveSpring(response: 0.48, dampingFraction: 0.84, blendDuration: 0.14)) {
            isFlipped.toggle()
        }
        Haptics.soft(0.66)
    }

    private func moveNext() {
        guard canMoveForward else { return }
        withAnimation(.interactiveSpring(response: 0.30, dampingFraction: 0.84)) {
            currentIndex += 1
            isFlipped = false
            dragOffset = 0
        }
        Haptics.light(0.62)
    }

    private func movePrevious() {
        guard canMoveBackward else { return }
        withAnimation(.interactiveSpring(response: 0.30, dampingFraction: 0.84)) {
            currentIndex -= 1
            isFlipped = false
            dragOffset = 0
        }
        Haptics.light(0.62)
    }

    private func toggleShuffle() {
        let currentCardID = currentCard?.id

        withAnimation(.interactiveSpring(response: 0.34, dampingFraction: 0.86)) {
            isShuffled.toggle()
            orderedCards = isShuffled ? session.cards.shuffled() : session.cards

            if let currentCardID,
               let newIndex = orderedCards.firstIndex(where: { $0.id == currentCardID }) {
                currentIndex = newIndex
            } else {
                currentIndex = min(currentIndex, max(orderedCards.count - 1, 0))
            }

            isFlipped = false
        }

        Haptics.soft(0.56)
    }

    private func progressWidth(totalWidth: CGFloat) -> CGFloat {
        guard orderedCards.isEmpty == false else { return 0 }
        return totalWidth * CGFloat(currentIndex + 1) / CGFloat(orderedCards.count)
    }
}

struct StudyView_Previews: PreviewProvider {
    static var previews: some View {
        let reviewStore = ReviewStore()

        return NavigationStack {
            StudyView(
                session: StudySession(
                    deckID: .systemDesign,
                    deckTitle: "System Design",
                    mode: .randomTwenty,
                    cards: Array(SystemDesignDeck.cards.prefix(12)),
                    startIndex: 0
                )
            )
                .environmentObject(reviewStore)
        }
    }
}
