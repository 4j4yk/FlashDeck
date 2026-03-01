import SwiftUI

struct DeckCardView: View {
    let deck: Deck
    let markedCount: Int
    let isContinue: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.16))

                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)

                        Image(systemName: deck.symbolName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 50, height: 50)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(isContinue ? "CONTINUE" : "DECK")
                            .font(.system(.caption2, design: .rounded).weight(.bold))
                            .foregroundStyle(.white.opacity(0.72))

                        Text(deck.title)
                            .font(.system(size: 27, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer()

                if isContinue {
                    capsuleLabel("Resume")
                }
            }

            Text(deck.subtitle)
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundStyle(.white.opacity(0.88))
                .lineLimit(2)

            Text(deck.summary)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.white.opacity(0.80))
                .lineLimit(3)

            HStack(spacing: 10) {
                metricPill(value: "\(deck.cards.count)", label: "cards")
                metricPill(value: "\(markedCount)", label: "marked")
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.16))

                    Circle()
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.92))
                }
                .frame(width: 36, height: 36)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(AppTheme.gradient(for: deck.id))
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 180, height: 180)
                        .blur(radius: 24)
                        .offset(x: 52, y: -56)
                }
                .overlay(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 38, style: .continuous)
                        .fill(Color.black.opacity(0.10))
                        .frame(width: 180, height: 76)
                        .blur(radius: 30)
                        .offset(x: -26, y: 30)
                }
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.16), lineWidth: 1)
        )
        .shadow(color: AppTheme.deepShadowColor.opacity(0.88), radius: 30, x: 0, y: 18)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(deck.title). \(deck.subtitle)")
        .accessibilityValue("\(deck.cards.count) cards. \(markedCount) marked for review.")
        .accessibilityHint(isContinue ? "Double tap to continue this deck." : "Double tap to open this deck.")
    }

    private func capsuleLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(.caption, design: .rounded).weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.16), in: Capsule())
    }

    private func metricPill(value: String, label: String) -> some View {
        HStack(spacing: 6) {
            Text(value)
                .font(.system(.caption, design: .rounded).weight(.bold))
            Text(label)
                .font(.system(.caption, design: .rounded).weight(.medium))
                .foregroundStyle(.white.opacity(0.74))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.16), in: Capsule())
    }
}
