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

                signalArc(
                    size: CGSize(width: proxy.size.width * 1.12, height: proxy.size.height * 0.72),
                    lineWidth: 1.3,
                    opacity: colorScheme == .dark ? 0.18 : 0.14
                )
                .offset(x: proxy.size.width * 0.18, y: -proxy.size.height * 0.22)

                signalArc(
                    size: CGSize(width: proxy.size.width * 0.88, height: proxy.size.height * 0.54),
                    lineWidth: 1.1,
                    opacity: colorScheme == .dark ? 0.14 : 0.11
                )
                .offset(x: -proxy.size.width * 0.24, y: proxy.size.height * 0.26)

                if AppTheme.usesAmbientGlow {
                    Ellipse()
                        .fill(glowColor.opacity(colorScheme == .dark ? 0.24 : 0.18))
                        .frame(width: proxy.size.width * 0.78, height: proxy.size.height * 0.34)
                        .rotationEffect(.degrees(-18))
                        .blur(radius: 82)
                        .offset(x: -proxy.size.width * 0.20, y: -proxy.size.height * 0.20)

                    Ellipse()
                        .fill(glowColor.opacity(colorScheme == .dark ? 0.14 : 0.10))
                        .frame(width: proxy.size.width * 0.60, height: proxy.size.height * 0.24)
                        .rotationEffect(.degrees(26))
                        .blur(radius: 68)
                        .offset(x: proxy.size.width * 0.34, y: -proxy.size.height * 0.10)

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

                if AppTheme.usesAmbientGlow {
                    RoundedRectangle(cornerRadius: 120, style: .continuous)
                        .stroke(glowColor.opacity(colorScheme == .dark ? 0.14 : 0.10), lineWidth: 1.2)
                        .frame(width: proxy.size.width * 0.78, height: proxy.size.height * 0.24)
                        .rotationEffect(.degrees(-18))
                        .blur(radius: 1.4)
                        .offset(x: proxy.size.width * 0.10, y: proxy.size.height * 0.30)
                }
            }
            .allowsHitTesting(false)
        }
    }

    private var glowColor: Color {
        guard let accentDeck else {
            return AppTheme.accentColor(for: .custom)
        }
        return AppTheme.accentColor(for: accentDeck)
    }

    private func signalArc(size: CGSize, lineWidth: CGFloat, opacity: Double) -> some View {
        Ellipse()
            .stroke(glowColor.opacity(opacity), lineWidth: lineWidth)
            .frame(width: size.width, height: size.height)
            .blur(radius: 0.2)
    }
}
