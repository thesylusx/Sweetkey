import UIKit

final class ClipboardManager {
    private let maxItems = 25
    private let storageKey = "sweetkey.clipboardHistory"
    private let suiteName = "group.com.sweet.customkeyboard"
    private(set) var items: [String] = []

    init() { load() }

    func refreshFromPasteboard() {
        guard let string = UIPasteboard.general.string,
              !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        items.removeAll { $0 == string }
        items.insert(string, at: 0)
        if items.count > maxItems { items = Array(items.prefix(maxItems)) }
        save()
    }

    func clear() { items = []; save() }

    private func load() {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let saved = defaults.stringArray(forKey: storageKey) else { return }
        items = saved
    }

    private func save() {
        UserDefaults(suiteName: suiteName)?.set(items, forKey: storageKey)
    }
}
