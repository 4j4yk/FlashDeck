import UIKit

enum Haptics {
    private static let softGenerator = UIImpactFeedbackGenerator(style: .soft)
    private static let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private static let selectionGenerator = UISelectionFeedbackGenerator()
    private static let notificationGenerator = UINotificationFeedbackGenerator()

    static func soft(_ intensity: CGFloat = 0.7) {
        softGenerator.prepare()
        softGenerator.impactOccurred(intensity: intensity)
    }

    static func light(_ intensity: CGFloat = 0.65) {
        lightGenerator.prepare()
        lightGenerator.impactOccurred(intensity: intensity)
    }

    static func selection() {
        selectionGenerator.prepare()
        selectionGenerator.selectionChanged()
    }

    static func success() {
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(.success)
    }
}
