import SwiftUI

struct FlipFlashCardView: View {
    let card: FlashCard
    let deckID: DeckCategory
    let isMarked: Bool
    let onToggle: () -> Void
    @Binding var isFlipped: Bool

    @State private var visibleSide: CardFaceView.Side = .front
    @State private var rotationDegrees: Double = 0
    @State private var pendingSwap: DispatchWorkItem?

    private let halfFlipDuration = 0.18

    var body: some View {
        CardFaceView(card: card, deckID: deckID, isMarked: isMarked, side: visibleSide)
            .id("\(card.id)-\(visibleSide == .front ? "front" : "back")")
            .rotation3DEffect(
                .degrees(rotationDegrees),
                axis: (x: 0.06, y: 1, z: 0.02),
                perspective: 0.78
            )
            .scaleEffect(1 - (min(abs(rotationDegrees) / 90, 1) * 0.035))
        .contentShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .onTapGesture {
            onToggle()
        }
        .onAppear {
            syncVisibleSide()
        }
        .onChange(of: isFlipped) { _, _ in
            animateFlip()
        }
        .onChange(of: card.id) { _, _ in
            syncVisibleSide()
        }
        .onDisappear {
            pendingSwap?.cancel()
            pendingSwap = nil
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(isFlipped ? "Answer visible" : "Question visible")
        .accessibilityHint(isFlipped ? "Double tap to show the question." : "Double tap to show the answer.")
        .accessibilityAction {
            onToggle()
        }
    }

    private func syncVisibleSide() {
        pendingSwap?.cancel()
        pendingSwap = nil
        visibleSide = isFlipped ? .back : .front
        rotationDegrees = 0
    }

    private func animateFlip() {
        let targetSide: CardFaceView.Side = isFlipped ? .back : .front
        guard visibleSide != targetSide || rotationDegrees != 0 else { return }

        pendingSwap?.cancel()

        let rotateOut = targetSide == .back ? 90.0 : -90.0
        withAnimation(.easeIn(duration: halfFlipDuration)) {
            rotationDegrees = rotateOut
        }

        let swap = DispatchWorkItem {
            visibleSide = targetSide
            rotationDegrees = -rotateOut

            withAnimation(.easeOut(duration: halfFlipDuration)) {
                rotationDegrees = 0
            }
        }

        pendingSwap = swap
        DispatchQueue.main.asyncAfter(deadline: .now() + halfFlipDuration, execute: swap)
    }
}
