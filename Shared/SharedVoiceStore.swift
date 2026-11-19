import Foundation

enum SharedVoiceStore {
    static let suiteName = "group.com.sweet.customkeyboard"
    private static let pendingTextKey = "sweetkey.pendingVoiceText"
    private static let pendingTimestampKey = "sweetkey.pendingVoiceTimestamp"

    static func savePendingVoiceText(_ text: String) {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return }
        defaults.set(text, forKey: pendingTextKey)
        defaults.set(Date().timeIntervalSince1970, forKey: pendingTimestampKey)
        defaults.synchronize()
    }

    static func consumePendingVoiceText() -> String? {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let text = defaults.string(forKey: pendingTextKey),
              !text.isEmpty else { return nil }
        defaults.removeObject(forKey: pendingTextKey)
        defaults.removeObject(forKey: pendingTimestampKey)
        defaults.synchronize()
        return text
    }

    static func peekPendingVoiceText() -> String? {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let text = defaults.string(forKey: pendingTextKey),
              !text.isEmpty else { return nil }
        return text
    }

    static func clearPending() {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return }
        defaults.removeObject(forKey: pendingTextKey)
        defaults.removeObject(forKey: pendingTimestampKey)
        defaults.synchronize()
    }
}
