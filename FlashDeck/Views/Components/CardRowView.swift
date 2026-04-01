import SwiftUI

struct CardRowView: View {
    let card: FlashCard
    let accentDeck: DeckCategory
    var isSelecting = false
    var isSelected = false

    private var accessibilityValue: String {
        var parts: [String] = []

        if card.isMarkedForReview {
            parts.append("Marked for review")
        }

        if isSelecting {
            parts.append(isSelected ? "Selected" : "Not selected")
        }

        if card.tags.isEmpty == false {
            parts.append("Tags: \(card.tags.prefix(3).joined(separator: ", "))")
        }

        return parts.joined(separator: ". ")
    }

    var body: some View {
        HStack(spacing: 16) {
            if isSelecting {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? AppTheme.accentColor(for: accentDeck) : AppTheme.secondaryText)
            }

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(card.title)
                            .font(.system(.headline, design: .rounded).weight(.bold))
                            .foregroundStyle(AppTheme.primaryText)
                            .lineLimit(2)

                        Text(card.prompt)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(AppTheme.secondaryText)
                            .lineLimit(2)
                            .lineSpacing(2)
                    }

                    Spacer(minLength: 12)

                    if card.isMarkedForReview {
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(AppTheme.gradient(for: accentDeck), in: Circle())
                    }
                }

                HStack(spacing: 8) {
                    ForEach(card.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.system(.caption2, design: .rounded).weight(.semibold))
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
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(AppTheme.surfaceGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppTheme.outlineGradient, lineWidth: 1)
        )
        .shadow(color: AppTheme.shadowColor.opacity(0.68), radius: 16, x: 0, y: 10)
        .padding(.horizontal, 20)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(card.title). \(card.prompt)")
        .accessibilityValue(accessibilityValue)
        .accessibilityHint(isSelecting ? "Double tap to change selection." : "Double tap to study this card.")
    }
}
