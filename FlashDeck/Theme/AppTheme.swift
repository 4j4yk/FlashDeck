import SwiftUI

enum AppColorSchemePreference: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }

    var systemImage: String {
        switch self {
        case .system:
            return "circle.lefthalf.filled"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

enum AppReadingMode: String, CaseIterable, Identifiable {
    case standard
    case reading
    case eInk = "e-ink"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .standard:
            return "Standard"
        case .reading:
            return "Reading"
        case .eInk:
            return "E-Ink"
        }
    }

    var systemImage: String {
        switch self {
        case .standard:
            return "sparkles"
        case .reading:
            return "book.closed.fill"
        case .eInk:
            return "rectangle.compress.vertical"
        }
    }

    var detail: String {
        switch self {
        case .standard:
            return "Premium gradients and soft depth."
        case .reading:
            return "Calmer surfaces with warmer paper-like contrast."
        case .eInk:
            return "Monochrome, flatter, and easier on long reading sessions."
        }
    }
}

final class AppearanceStore: ObservableObject {
    static let shared = AppearanceStore()

    private let defaults: UserDefaults
    private let colorSchemeKey = "flashdeck.appearance.colorScheme"
    private let readingModeKey = "flashdeck.appearance.readingMode"

    @Published private(set) var colorSchemePreference: AppColorSchemePreference
    @Published private(set) var readingMode: AppReadingMode

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.colorSchemePreference = AppColorSchemePreference(
            rawValue: defaults.string(forKey: colorSchemeKey) ?? ""
        ) ?? .system
        self.readingMode = AppReadingMode(
            rawValue: defaults.string(forKey: readingModeKey) ?? ""
        ) ?? .standard
    }

    var preferredColorScheme: ColorScheme? {
        colorSchemePreference.colorScheme
    }

    var renderKey: String {
        "\(colorSchemePreference.rawValue)|\(readingMode.rawValue)"
    }

    func update(colorSchemePreference: AppColorSchemePreference) {
        guard self.colorSchemePreference != colorSchemePreference else { return }
        self.colorSchemePreference = colorSchemePreference
        defaults.set(colorSchemePreference.rawValue, forKey: colorSchemeKey)
    }

    func update(readingMode: AppReadingMode) {
        guard self.readingMode != readingMode else { return }
        self.readingMode = readingMode
        defaults.set(readingMode.rawValue, forKey: readingModeKey)
    }

    func reset() {
        colorSchemePreference = .system
        readingMode = .standard
        defaults.removeObject(forKey: colorSchemeKey)
        defaults.removeObject(forKey: readingModeKey)
    }
}

enum AppTheme {
    static let cornerRadius: CGFloat = 30
    static let rootTabBarClearance: CGFloat = 126

    private static var readingMode: AppReadingMode {
        AppearanceStore.shared.readingMode
    }

    static var usesMinimalChrome: Bool {
        readingMode != .standard
    }

    static var usesAmbientGlow: Bool {
        readingMode == .standard
    }

    static var backgroundTop: Color {
        themedColor(
            standardLight: UIColor(red: 0.95, green: 0.97, blue: 1.00, alpha: 1),
            standardDark: UIColor(red: 0.05, green: 0.06, blue: 0.11, alpha: 1),
            readingLight: UIColor(red: 0.95, green: 0.94, blue: 0.90, alpha: 1),
            readingDark: UIColor(red: 0.10, green: 0.10, blue: 0.09, alpha: 1),
            eInkLight: UIColor(red: 0.95, green: 0.94, blue: 0.90, alpha: 1),
            eInkDark: UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)
        )
    }

    static var backgroundBottom: Color {
        themedColor(
            standardLight: UIColor(red: 0.88, green: 0.93, blue: 0.98, alpha: 1),
            standardDark: UIColor(red: 0.08, green: 0.10, blue: 0.17, alpha: 1),
            readingLight: UIColor(red: 0.91, green: 0.89, blue: 0.84, alpha: 1),
            readingDark: UIColor(red: 0.13, green: 0.13, blue: 0.12, alpha: 1),
            eInkLight: UIColor(red: 0.92, green: 0.91, blue: 0.86, alpha: 1),
            eInkDark: UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1)
        )
    }

    static var surface: Color {
        themedColor(
            standardLight: UIColor(red: 1, green: 1, blue: 1, alpha: 0.94),
            standardDark: UIColor(red: 0.12, green: 0.15, blue: 0.20, alpha: 0.96),
            readingLight: UIColor(red: 0.99, green: 0.98, blue: 0.95, alpha: 0.96),
            readingDark: UIColor(red: 0.16, green: 0.16, blue: 0.14, alpha: 0.96),
            eInkLight: UIColor(red: 0.99, green: 0.98, blue: 0.94, alpha: 1),
            eInkDark: UIColor(red: 0.13, green: 0.13, blue: 0.12, alpha: 1)
        )
    }

    static var secondarySurface: Color {
        themedColor(
            standardLight: UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1),
            standardDark: UIColor(red: 0.16, green: 0.19, blue: 0.25, alpha: 1),
            readingLight: UIColor(red: 0.96, green: 0.95, blue: 0.91, alpha: 1),
            readingDark: UIColor(red: 0.20, green: 0.20, blue: 0.18, alpha: 1),
            eInkLight: UIColor(red: 0.95, green: 0.94, blue: 0.89, alpha: 1),
            eInkDark: UIColor(red: 0.17, green: 0.17, blue: 0.16, alpha: 1)
        )
    }

    static var tertiarySurface: Color {
        themedColor(
            standardLight: UIColor(red: 0.92, green: 0.95, blue: 0.98, alpha: 1),
            standardDark: UIColor(red: 0.20, green: 0.23, blue: 0.30, alpha: 1),
            readingLight: UIColor(red: 0.93, green: 0.92, blue: 0.88, alpha: 1),
            readingDark: UIColor(red: 0.24, green: 0.24, blue: 0.22, alpha: 1),
            eInkLight: UIColor(red: 0.91, green: 0.90, blue: 0.85, alpha: 1),
            eInkDark: UIColor(red: 0.20, green: 0.20, blue: 0.19, alpha: 1)
        )
    }

    static var primaryText: Color {
        themedColor(
            standardLight: UIColor(red: 0.11, green: 0.14, blue: 0.19, alpha: 1),
            standardDark: UIColor(red: 0.95, green: 0.96, blue: 0.99, alpha: 1),
            readingLight: UIColor(red: 0.18, green: 0.17, blue: 0.14, alpha: 1),
            readingDark: UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1),
            eInkLight: UIColor(red: 0.12, green: 0.12, blue: 0.11, alpha: 1),
            eInkDark: UIColor(red: 0.95, green: 0.94, blue: 0.89, alpha: 1)
        )
    }

    static var secondaryText: Color {
        themedColor(
            standardLight: UIColor(red: 0.39, green: 0.45, blue: 0.54, alpha: 1),
            standardDark: UIColor(red: 0.68, green: 0.73, blue: 0.82, alpha: 1),
            readingLight: UIColor(red: 0.43, green: 0.39, blue: 0.31, alpha: 1),
            readingDark: UIColor(red: 0.76, green: 0.72, blue: 0.65, alpha: 1),
            eInkLight: UIColor(red: 0.34, green: 0.33, blue: 0.30, alpha: 1),
            eInkDark: UIColor(red: 0.74, green: 0.73, blue: 0.68, alpha: 1)
        )
    }

    static var tertiaryText: Color {
        themedColor(
            standardLight: UIColor(red: 0.50, green: 0.56, blue: 0.65, alpha: 1),
            standardDark: UIColor(red: 0.54, green: 0.59, blue: 0.68, alpha: 1),
            readingLight: UIColor(red: 0.54, green: 0.48, blue: 0.39, alpha: 1),
            readingDark: UIColor(red: 0.57, green: 0.54, blue: 0.48, alpha: 1),
            eInkLight: UIColor(red: 0.42, green: 0.40, blue: 0.37, alpha: 1),
            eInkDark: UIColor(red: 0.58, green: 0.57, blue: 0.53, alpha: 1)
        )
    }

    static var line: Color {
        themedColor(
            standardLight: UIColor.black.withAlphaComponent(0.06),
            standardDark: UIColor.white.withAlphaComponent(0.10),
            readingLight: UIColor.black.withAlphaComponent(0.08),
            readingDark: UIColor.white.withAlphaComponent(0.10),
            eInkLight: UIColor.black.withAlphaComponent(0.18),
            eInkDark: UIColor.white.withAlphaComponent(0.20)
        )
    }

    static var strongLine: Color {
        themedColor(
            standardLight: UIColor.white.withAlphaComponent(0.82),
            standardDark: UIColor.white.withAlphaComponent(0.18),
            readingLight: UIColor.white.withAlphaComponent(0.70),
            readingDark: UIColor.white.withAlphaComponent(0.16),
            eInkLight: UIColor.black.withAlphaComponent(0.20),
            eInkDark: UIColor.white.withAlphaComponent(0.24)
        )
    }

    static var shadowColor: Color {
        themedColor(
            standardLight: UIColor.black.withAlphaComponent(0.12),
            standardDark: UIColor.black.withAlphaComponent(0.42),
            readingLight: UIColor.black.withAlphaComponent(0.07),
            readingDark: UIColor.black.withAlphaComponent(0.24),
            eInkLight: UIColor.clear,
            eInkDark: UIColor.clear
        )
    }

    static var deepShadowColor: Color {
        themedColor(
            standardLight: UIColor.black.withAlphaComponent(0.18),
            standardDark: UIColor.black.withAlphaComponent(0.58),
            readingLight: UIColor.black.withAlphaComponent(0.10),
            readingDark: UIColor.black.withAlphaComponent(0.28),
            eInkLight: UIColor.clear,
            eInkDark: UIColor.clear
        )
    }

    static var accentChromeFill: Color {
        themedColor(
            standardLight: UIColor.white.withAlphaComponent(0.16),
            standardDark: UIColor.white.withAlphaComponent(0.16),
            readingLight: UIColor.white.withAlphaComponent(0.10),
            readingDark: UIColor.black.withAlphaComponent(0.16),
            eInkLight: UIColor.white.withAlphaComponent(0.06),
            eInkDark: UIColor.white.withAlphaComponent(0.08)
        )
    }

    static var accentChromeStroke: Color {
        themedColor(
            standardLight: UIColor.white.withAlphaComponent(0.18),
            standardDark: UIColor.white.withAlphaComponent(0.18),
            readingLight: UIColor.white.withAlphaComponent(0.14),
            readingDark: UIColor.white.withAlphaComponent(0.10),
            eInkLight: UIColor.black.withAlphaComponent(0.18),
            eInkDark: UIColor.white.withAlphaComponent(0.14)
        )
    }

    static var ambientHighlight: Color {
        themedColor(
            standardLight: UIColor.white.withAlphaComponent(0.18),
            standardDark: UIColor.white.withAlphaComponent(0.06),
            readingLight: UIColor.white.withAlphaComponent(0.08),
            readingDark: UIColor.white.withAlphaComponent(0.04),
            eInkLight: UIColor.clear,
            eInkDark: UIColor.clear
        )
    }

    static var ambientShadow: Color {
        themedColor(
            standardLight: UIColor.black.withAlphaComponent(0.10),
            standardDark: UIColor.black.withAlphaComponent(0.18),
            readingLight: UIColor.black.withAlphaComponent(0.06),
            readingDark: UIColor.black.withAlphaComponent(0.12),
            eInkLight: UIColor.clear,
            eInkDark: UIColor.clear
        )
    }

    static var tintBubble: Color {
        themedColor(
            standardLight: UIColor.white.withAlphaComponent(0.12),
            standardDark: UIColor.white.withAlphaComponent(0.05),
            readingLight: UIColor.white.withAlphaComponent(0.06),
            readingDark: UIColor.white.withAlphaComponent(0.03),
            eInkLight: UIColor.clear,
            eInkDark: UIColor.clear
        )
    }

    static var surfaceGradient: LinearGradient {
        LinearGradient(
            colors: readingMode == .standard ? [surface, secondarySurface] : [surface, surface],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var elevatedSurfaceGradient: LinearGradient {
        LinearGradient(
            colors: readingMode == .standard ? [surface, tertiarySurface] : [surface, secondarySurface],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var outlineGradient: LinearGradient {
        LinearGradient(
            colors: readingMode == .eInk ? [line, line] : [strongLine, line],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func gradient(for deck: DeckCategory) -> LinearGradient {
        switch deck {
        case .systemDesign:
            return deckGradient(
                standard: [Color(red: 0.11, green: 0.24, blue: 0.62), Color(red: 0.29, green: 0.58, blue: 0.95)],
                reading: [Color(red: 0.31, green: 0.43, blue: 0.61), Color(red: 0.43, green: 0.58, blue: 0.74)],
                eInk: [Color(red: 0.40, green: 0.40, blue: 0.38), Color(red: 0.56, green: 0.56, blue: 0.53)]
            )
        case .solutionArchitecture:
            return deckGradient(
                standard: [Color(red: 0.12, green: 0.38, blue: 0.30), Color(red: 0.40, green: 0.72, blue: 0.58)],
                reading: [Color(red: 0.29, green: 0.45, blue: 0.35), Color(red: 0.49, green: 0.65, blue: 0.52)],
                eInk: [Color(red: 0.33, green: 0.33, blue: 0.31), Color(red: 0.48, green: 0.48, blue: 0.45)]
            )
        case .awsServices:
            return deckGradient(
                standard: [Color(red: 0.82, green: 0.36, blue: 0.12), Color(red: 0.98, green: 0.66, blue: 0.20)],
                reading: [Color(red: 0.69, green: 0.49, blue: 0.23), Color(red: 0.82, green: 0.63, blue: 0.34)],
                eInk: [Color(red: 0.47, green: 0.46, blue: 0.43), Color(red: 0.63, green: 0.62, blue: 0.58)]
            )
        case .custom:
            return deckGradient(
                standard: [Color(red: 0.23, green: 0.21, blue: 0.42), Color(red: 0.78, green: 0.34, blue: 0.42)],
                reading: [Color(red: 0.39, green: 0.40, blue: 0.48), Color(red: 0.54, green: 0.55, blue: 0.66)],
                eInk: [Color(red: 0.38, green: 0.38, blue: 0.36), Color(red: 0.53, green: 0.53, blue: 0.50)]
            )
        }
    }

    static func accentColor(for deck: DeckCategory) -> Color {
        switch deck {
        case .systemDesign:
            return accent(
                standard: Color(red: 0.28, green: 0.62, blue: 0.98),
                reading: Color(red: 0.43, green: 0.58, blue: 0.74),
                eInk: Color(red: 0.46, green: 0.46, blue: 0.43)
            )
        case .solutionArchitecture:
            return accent(
                standard: Color(red: 0.36, green: 0.74, blue: 0.58),
                reading: Color(red: 0.49, green: 0.65, blue: 0.52),
                eInk: Color(red: 0.40, green: 0.40, blue: 0.37)
            )
        case .awsServices:
            return accent(
                standard: Color(red: 0.98, green: 0.60, blue: 0.19),
                reading: Color(red: 0.82, green: 0.63, blue: 0.34),
                eInk: Color(red: 0.55, green: 0.55, blue: 0.51)
            )
        case .custom:
            return accent(
                standard: Color(red: 0.89, green: 0.43, blue: 0.48),
                reading: Color(red: 0.54, green: 0.55, blue: 0.66),
                eInk: Color(red: 0.46, green: 0.46, blue: 0.43)
            )
        }
    }

    static var tabBarBackgroundColor: UIColor {
        uiColor(
            standardLight: UIColor(red: 0.97, green: 0.98, blue: 1.0, alpha: 0.90),
            standardDark: UIColor(red: 0.08, green: 0.10, blue: 0.14, alpha: 0.88),
            readingLight: UIColor(red: 0.98, green: 0.97, blue: 0.94, alpha: 0.96),
            readingDark: UIColor(red: 0.13, green: 0.13, blue: 0.12, alpha: 0.94),
            eInkLight: UIColor(red: 0.96, green: 0.95, blue: 0.91, alpha: 1),
            eInkDark: UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1)
        )
    }

    static var tabBarShadowUIColor: UIColor {
        uiColor(
            standardLight: UIColor.black.withAlphaComponent(0.08),
            standardDark: UIColor.black.withAlphaComponent(0.16),
            readingLight: UIColor.black.withAlphaComponent(0.08),
            readingDark: UIColor.black.withAlphaComponent(0.18),
            eInkLight: UIColor.black.withAlphaComponent(0.12),
            eInkDark: UIColor.white.withAlphaComponent(0.10)
        )
    }

    static var usesTabBarBlur: Bool {
        readingMode == .standard
    }

    private static func accent(standard: Color, reading: Color, eInk: Color) -> Color {
        switch readingMode {
        case .standard:
            return standard
        case .reading:
            return reading
        case .eInk:
            return eInk
        }
    }

    private static func deckGradient(standard: [Color], reading: [Color], eInk: [Color]) -> LinearGradient {
        switch readingMode {
        case .standard:
            return LinearGradient(colors: standard, startPoint: .topLeading, endPoint: .bottomTrailing)
        case .reading:
            return LinearGradient(colors: reading, startPoint: .topLeading, endPoint: .bottomTrailing)
        case .eInk:
            return LinearGradient(colors: eInk, startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private static func themedColor(
        standardLight: UIColor,
        standardDark: UIColor,
        readingLight: UIColor? = nil,
        readingDark: UIColor? = nil,
        eInkLight: UIColor? = nil,
        eInkDark: UIColor? = nil
    ) -> Color {
        Color(uiColor: uiColor(
            standardLight: standardLight,
            standardDark: standardDark,
            readingLight: readingLight,
            readingDark: readingDark,
            eInkLight: eInkLight,
            eInkDark: eInkDark
        ))
    }

    private static func uiColor(
        standardLight: UIColor,
        standardDark: UIColor,
        readingLight: UIColor? = nil,
        readingDark: UIColor? = nil,
        eInkLight: UIColor? = nil,
        eInkDark: UIColor? = nil
    ) -> UIColor {
        UIColor { traits in
            let isDark = traits.userInterfaceStyle == .dark

            switch readingMode {
            case .standard:
                return isDark ? standardDark : standardLight
            case .reading:
                return isDark ? (readingDark ?? standardDark) : (readingLight ?? standardLight)
            case .eInk:
                return isDark
                    ? (eInkDark ?? readingDark ?? standardDark)
                    : (eInkLight ?? readingLight ?? standardLight)
            }
        }
    }
}
