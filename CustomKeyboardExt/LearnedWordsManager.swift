import Foundation

final class LearnedWordsManager {
    private let suiteName = "group.com.sweet.customkeyboard"
    private let storageKey = "sweetkey.learnedWords"
    private let maxWordsPerLanguage = 500
    private var banglaWords: [String: Int] = [:]
    private var englishWords: [String: Int] = [:]

    func load() {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(Storage.self, from: data) else { return }
        banglaWords = decoded.bangla
        englishWords = decoded.english
    }

    func record(word: String, language: BanglaPhoneticEngine.Language) {
        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty, trimmed.count > 1 else { return }
        switch language {
        case .bangla:
            banglaWords[trimmed, default: 0] += 1
            if banglaWords.count > maxWordsPerLanguage { trim(&banglaWords) }
        case .english:
            englishWords[trimmed, default: 0] += 1
            if englishWords.count > maxWordsPerLanguage { trim(&englishWords) }
        }
        save()
    }

    func suggestions(for prefix: String, language: BanglaPhoneticEngine.Language) -> [String] {
        let lower = prefix.lowercased()
        let dict = language == .bangla ? banglaWords : englishWords
        return dict.filter { $0.key.hasPrefix(lower) && $0.key != lower }
            .sorted { $0.value > $1.value }.prefix(3).map { $0.key }
    }

    private func trim(_ dict: inout [String: Int]) {
        let sorted = dict.sorted { $0.value > $1.value }
        dict = Dictionary(uniqueKeysWithValues: sorted.prefix(maxWordsPerLanguage))
    }

    private func save() {
        let storage = Storage(bangla: banglaWords, english: englishWords)
        guard let data = try? JSONEncoder().encode(storage),
              let defaults = UserDefaults(suiteName: suiteName) else { return }
        defaults.set(data, forKey: storageKey)
    }

    private struct Storage: Codable {
        let bangla: [String: Int]
        let english: [String: Int]
    }
}
