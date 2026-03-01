import SwiftUI

struct FlipFlashCardView: View {
    let card: FlashCard
    let deckID: DeckCategory
    let isMarked: Bool
    let onToggle: () -> Void
    @Binding var isFlipped: Bool

    private var rotation: Double {
        isFlipped ? 180 : 0
    }

    var body: some View {
        ZStack {
            CardFaceView(card: card, deckID: deckID, isMarked: isMarked, side: .front)
                .opacity(rotation < 90 ? 1 : 0)
                .rotation3DEffect(
                    .degrees(rotation),
                    axis: (x: 0.08, y: 1, z: 0.02),
                    perspective: 0.76
                )
                .scaleEffect(isFlipped ? 0.985 : 1)
                .zIndex(isFlipped ? 0 : 1)

            CardFaceView(card: card, deckID: deckID, isMarked: isMarked, side: .back)
                .opacity(rotation >= 90 ? 1 : 0)
                .rotation3DEffect(
                    .degrees(rotation - 180),
                    axis: (x: -0.08, y: 1, z: -0.02),
                    perspective: 0.76
                )
                .scaleEffect(isFlipped ? 1 : 0.985)
                .zIndex(isFlipped ? 1 : 0)
        }
        .contentShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .drawingGroup()
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.84, blendDuration: 0.16), value: isFlipped)
        .onTapGesture {
            onToggle()
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(isFlipped ? "Answer visible" : "Question visible")
        .accessibilityHint(isFlipped ? "Double tap to show the question." : "Double tap to show the answer.")
        .accessibilityAction {
            onToggle()
        }
    }
}
