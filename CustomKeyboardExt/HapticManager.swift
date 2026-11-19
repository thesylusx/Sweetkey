import UIKit
import AudioToolbox

final class HapticManager {
    static let shared = HapticManager()
    private let impact = UIImpactFeedbackGenerator(style: .light)
    private let selection = UISelectionFeedbackGenerator()
    private let notify = UINotificationFeedbackGenerator()

    private init() {
        impact.prepare()
        selection.prepare()
        notify.prepare()
    }

    func keyTap() {
        guard ThemeManager.shared.hapticsEnabled else { return }
        impact.impactOccurred()
        impact.prepare()
        playClickSound()
    }

    func specialTap() {
        guard ThemeManager.shared.hapticsEnabled else { return }
        let medium = UIImpactFeedbackGenerator(style: .medium)
        medium.impactOccurred()
        playClickSound()
    }

    func selectionTap() {
        guard ThemeManager.shared.hapticsEnabled else { return }
        selection.selectionChanged()
        selection.prepare()
    }

    func success() {
        guard ThemeManager.shared.hapticsEnabled else { return }
        notify.notificationOccurred(.success)
    }

    func error() {
        guard ThemeManager.shared.hapticsEnabled else { return }
        notify.notificationOccurred(.error)
    }

    private func playClickSound() {
        guard ThemeManager.shared.soundEnabled else { return }
        AudioServicesPlaySystemSound(1104)
    }
}
