import SwiftUI

struct CardFaceView: View {
    enum Side {
        case front
        case back
    }

    let card: FlashCard
    let deckID: DeckCategory
    let isMarked: Bool
    let side: Side

    private var isFront: Bool {
        side == .front
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    labelPill(
                        isFront ? "Question" : "Answer",
                        iconName: isFront ? "questionmark" : "lightbulb"
                    )

                    if isFront {
                        Text(card.title)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.primaryText)
                            .lineSpacing(2)
                    }
                }

                Spacer()

                HStack(spacing: 10) {
                    if isMarked {
                        statusIcon(symbolName: "bookmark.fill", isAccent: true)
                    }

                    statusIcon(
                        symbolName: side == .front ? "rectangle.text.magnifyingglass" : "sparkles",
                        isAccent: false
                    )
                }
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(isFront ? card.prompt : card.answer)
                        .font(
                            .system(
                                size: isFront ? 28 : 19,
                                weight: isFront ? .semibold : .regular,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(AppTheme.primaryText)
                        .lineSpacing(isFront ? 5 : 4)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if isFront {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 88), spacing: 8)], alignment: .leading, spacing: 8) {
                            ForEach(card.tags.prefix(6), id: \.self) { tag in
                                Text(tag)
                                    .font(.system(.caption, design: .rounded).weight(.semibold))
                                    .foregroundStyle(AppTheme.primaryText)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(AppTheme.secondarySurface, in: Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(AppTheme.line, lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
                .padding(.top, 2)
            }

            Spacer(minLength: 0)

            HStack {
                Text(isFront ? "Tap for the distilled answer." : "Tap to return to the question.")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(AppTheme.tertiaryText)

                Spacer()

                Image(systemName: "hand.tap.fill")
                    .foregroundStyle(AppTheme.tertiaryText)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(AppTheme.secondarySurface.opacity(0.88), in: Capsule())
            .overlay(
                Capsule()
                    .stroke(AppTheme.line, lineWidth: 1)
            )
        }
        .padding(26)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(AppTheme.elevatedSurfaceGradient)
                .overlay(alignment: .topTrailing) {
                    if AppTheme.usesAmbientGlow {
                        Circle()
                            .fill(AppTheme.accentColor(for: deckID).opacity(isFront ? 0.10 : 0.16))
                            .frame(width: 200, height: 200)
                            .blur(radius: 58)
                            .offset(x: 58, y: -52)
                    }
                }
                .overlay(alignment: .bottomLeading) {
                    if AppTheme.usesAmbientGlow {
                        Circle()
                            .fill(AppTheme.ambientHighlight)
                            .frame(width: 160, height: 160)
                            .blur(radius: 60)
                            .offset(x: -24, y: 48)
                    }
                }
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.outlineGradient, lineWidth: 1)
        )
        .shadow(color: AppTheme.deepShadowColor.opacity(0.62), radius: 28, x: 0, y: 18)
    }

    private func statusIcon(symbolName: String, isAccent: Bool) -> some View {
        Image(systemName: symbolName)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 38, height: 38)
            .background(
                Circle()
                    .fill(
                        isAccent
                            ? AnyShapeStyle(AppTheme.gradient(for: deckID))
                            : AnyShapeStyle(
                                LinearGradient(
                                    colors: [AppTheme.tintBubble, AppTheme.secondarySurface],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
            .overlay(
                Circle()
                    .stroke(AppTheme.accentChromeStroke.opacity(isAccent ? 1 : 0.92), lineWidth: 1)
            )
    }

    private func labelPill(_ text: String, iconName: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: iconName)
            Text(text.uppercased())
        }
        .font(.system(.caption2, design: .rounded).weight(.bold))
        .foregroundStyle(AppTheme.secondaryText)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(AppTheme.secondarySurface, in: Capsule())
        .overlay(
            Capsule()
                .stroke(AppTheme.line, lineWidth: 1)
        )
    }
}
