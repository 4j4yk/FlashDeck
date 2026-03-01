import SwiftUI

struct EmptyStateView: View {
    let symbolName: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(AppTheme.elevatedSurfaceGradient)

                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(AppTheme.outlineGradient, lineWidth: 1)

                Circle()
                    .fill(Color.white.opacity(0.14))
                    .frame(width: 54, height: 54)
                    .blur(radius: 8)

                Image(systemName: symbolName)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
            }
            .frame(width: 84, height: 84)

            VStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)

                Text(message)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 26)
        .padding(.vertical, 30)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(AppTheme.elevatedSurfaceGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.outlineGradient, lineWidth: 1)
        )
        .shadow(color: AppTheme.shadowColor.opacity(0.75), radius: 22, x: 0, y: 14)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(message)
    }
}
