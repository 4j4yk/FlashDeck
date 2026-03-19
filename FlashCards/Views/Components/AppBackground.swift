import SwiftUI

struct AppBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var accentDeck: DeckCategory? = nil

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [AppTheme.backgroundTop, AppTheme.backgroundBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if AppTheme.usesAmbientGlow {
                    Circle()
                        .fill(glowColor.opacity(colorScheme == .dark ? 0.24 : 0.18))
                        .frame(width: proxy.size.width * 0.74)
                        .blur(radius: 78)
                        .offset(x: -proxy.size.width * 0.26, y: -proxy.size.height * 0.24)

                    Circle()
                        .fill(glowColor.opacity(colorScheme == .dark ? 0.14 : 0.10))
                        .frame(width: proxy.size.width * 0.62)
                        .blur(radius: 68)
                        .offset(x: proxy.size.width * 0.34, y: -proxy.size.height * 0.12)

                    Circle()
                        .fill(AppTheme.ambientHighlight)
                        .frame(width: proxy.size.width * 0.48)
                        .blur(radius: 60)
                        .offset(x: proxy.size.width * 0.28, y: -proxy.size.height * 0.32)

                    RoundedRectangle(cornerRadius: 80, style: .continuous)
                        .fill(AppTheme.tintBubble)
                        .frame(width: proxy.size.width * 0.56, height: proxy.size.height * 0.26)
                        .rotationEffect(.degrees(-12))
                        .blur(radius: 40)
                        .offset(x: proxy.size.width * 0.32, y: proxy.size.height * 0.38)
                }
            }
            .allowsHitTesting(false)
        }
    }

    private var glowColor: Color {
        guard let accentDeck else {
            return Color(red: 0.44, green: 0.58, blue: 0.93)
        }
        return AppTheme.accentColor(for: accentDeck)
    }
}
