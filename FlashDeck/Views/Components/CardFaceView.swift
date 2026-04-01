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
                            .font(.system(.title, design: .rounded).weight(.bold))
                            .foregroundStyle(AppTheme.primaryText)
                            .lineSpacing(2)
                    }
                }

                Spacer()

                if isMarked {
                    statusIcon(symbolName: "bookmark.fill", isAccent: true)
                }
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(isFront ? card.prompt : card.answer)
                        .font(
                            isFront
                                ? .system(.title, design: .rounded).weight(.semibold)
                                : .system(.body, design: .rounded)
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

            if isFront {
                HStack(spacing: 8) {
                    Image(systemName: "hand.tap")
                        .font(.system(size: 12, weight: .semibold))

                    Text("Tap anywhere to flip")
                        .font(.system(.caption, design: .rounded).weight(.medium))
                }
                .foregroundStyle(AppTheme.tertiaryText)
            }
        }
        .padding(26)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(AppTheme.elevatedSurfaceGradient)
                .overlay(alignment: .topTrailing) {
                    if AppTheme.usesAmbientGlow {
                        cardSignalCluster
                            .offset(x: 36, y: -24)
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
                .overlay(alignment: .topLeading) {
                    if AppTheme.usesAmbientGlow {
                        Capsule()
                            .fill(AppTheme.accentColor(for: deckID).opacity(0.18))
                            .frame(width: 82, height: 3)
                            .padding(.top, 22)
                            .padding(.leading, 26)
                    }
                }
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.outlineGradient, lineWidth: 1)
        )
        .shadow(color: AppTheme.deepShadowColor.opacity(0.62), radius: 28, x: 0, y: 18)
    }

    private var cardSignalCluster: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.accentColor(for: deckID).opacity(isFront ? 0.16 : 0.24), lineWidth: 1.1)
                .frame(width: 132, height: 132)

            Circle()
                .stroke(AppTheme.accentColor(for: deckID).opacity(isFront ? 0.08 : 0.12), lineWidth: 1)
                .frame(width: 92, height: 92)

            Circle()
                .fill(AppTheme.accentColor(for: deckID).opacity(isFront ? 0.10 : 0.14))
                .frame(width: 162, height: 162)
                .blur(radius: 34)
        }
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
