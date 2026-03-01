import SwiftUI

enum AppTheme {
    static let cornerRadius: CGFloat = 30
    static let cardHeight: CGFloat = 492

    static let backgroundTop = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.05, green: 0.07, blue: 0.11, alpha: 1)
                : UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1)
        }
    )

    static let backgroundBottom = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.09, green: 0.11, blue: 0.16, alpha: 1)
                : UIColor(red: 0.90, green: 0.94, blue: 0.98, alpha: 1)
        }
    )

    static let surface = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.12, green: 0.15, blue: 0.20, alpha: 0.96)
                : UIColor(red: 1, green: 1, blue: 1, alpha: 0.94)
        }
    )

    static let secondarySurface = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.16, green: 0.19, blue: 0.25, alpha: 1)
                : UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1)
        }
    )

    static let tertiarySurface = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.20, green: 0.23, blue: 0.30, alpha: 1)
                : UIColor(red: 0.92, green: 0.95, blue: 0.98, alpha: 1)
        }
    )

    static let primaryText = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.95, green: 0.96, blue: 0.99, alpha: 1)
                : UIColor(red: 0.11, green: 0.14, blue: 0.19, alpha: 1)
        }
    )

    static let secondaryText = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.68, green: 0.73, blue: 0.82, alpha: 1)
                : UIColor(red: 0.39, green: 0.45, blue: 0.54, alpha: 1)
        }
    )

    static let tertiaryText = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.54, green: 0.59, blue: 0.68, alpha: 1)
                : UIColor(red: 0.50, green: 0.56, blue: 0.65, alpha: 1)
        }
    )

    static let line = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.white.withAlphaComponent(0.10)
                : UIColor.black.withAlphaComponent(0.06)
        }
    )

    static let strongLine = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.white.withAlphaComponent(0.18)
                : UIColor.white.withAlphaComponent(0.82)
        }
    )

    static let shadowColor = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.black.withAlphaComponent(0.42)
                : UIColor.black.withAlphaComponent(0.12)
        }
    )

    static let deepShadowColor = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.black.withAlphaComponent(0.58)
                : UIColor.black.withAlphaComponent(0.18)
        }
    )

    static var surfaceGradient: LinearGradient {
        LinearGradient(
            colors: [surface, secondarySurface],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var elevatedSurfaceGradient: LinearGradient {
        LinearGradient(
            colors: [surface, tertiarySurface],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var outlineGradient: LinearGradient {
        LinearGradient(
            colors: [strongLine, line],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func gradient(for deck: DeckCategory) -> LinearGradient {
        switch deck {
        case .systemDesign:
            return LinearGradient(
                colors: [Color(red: 0.13, green: 0.33, blue: 0.73), Color(red: 0.28, green: 0.62, blue: 0.98)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .solutionArchitecture:
            return LinearGradient(
                colors: [Color(red: 0.16, green: 0.49, blue: 0.38), Color(red: 0.47, green: 0.79, blue: 0.60)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .awsServices:
            return LinearGradient(
                colors: [Color(red: 0.96, green: 0.47, blue: 0.12), Color(red: 0.99, green: 0.71, blue: 0.24)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    static func accentColor(for deck: DeckCategory) -> Color {
        switch deck {
        case .systemDesign:
            return Color(red: 0.28, green: 0.62, blue: 0.98)
        case .solutionArchitecture:
            return Color(red: 0.36, green: 0.74, blue: 0.58)
        case .awsServices:
            return Color(red: 0.98, green: 0.60, blue: 0.19)
        }
    }
}
