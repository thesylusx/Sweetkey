import Foundation

final class BanglaPhoneticEngine {
    enum Language { case bangla, english }

    func convert(_ input: String, language: Language) -> String {
        switch language {
        case .english: return input
        case .bangla: return banglaConvert(input.lowercased())
        }
    }

    private func banglaConvert(_ input: String) -> String {
        guard !input.isEmpty else { return input }
        if let direct = directWords[input] { return direct }
        var result = ""
        var i = input.startIndex
        while i < input.endIndex {
            let remaining = String(input[i...])
            if let (matched, output) = longestMatch(in: remaining) {
                result += output
                i = input.index(i, offsetBy: matched.count)
            } else {
                let ch = String(input[i])
                result += singleCharMap[ch] ?? ch
                i = input.index(after: i)
            }
        }
        return postProcess(result)
    }

    private let directWords: [String: String] = [
        "ami": "আমি", "tumi": "তুমি", "apni": "আপনি",
        "bangla": "বাংলা", "bangladesh": "বাংলাদেশ",
        "design": "ডিজাইন", "dijain": "ডিজাইন", "dijacn": "ডিজাইন",
        "kemon": "কেমন", "kemonacho": "কেমন আছো",
        "valo": "ভালো", "bhalo": "ভালো",
        "dhonnobad": "ধন্যবাদ",
        "assalamualaikum": "আসসালামু আলাইকুম",
        "inshaallah": "ইনশাআল্লাহ", "alhamdulillah": "আলহামদুলিল্লাহ",
        "bhalobasha": "ভালোবাসা", "valobasha": "ভালোবাসা",
        "amar": "আমার", "tomar": "তোমার", "apnar": "আপনার",
        "ki": "কি", "keno": "কেন", "kothay": "কোথায়",
        "onek": "অনেক", "khub": "খুব", "taratari": "তাড়াতাড়ি",
        "theek": "ঠিক", "thik": "ঠিক", "ache": "আছে", "nai": "নাই",
        "korbo": "করবো", "korte": "করতে", "kore": "করে",
        "korechi": "করেছি", "hobe": "হবে", "hoy": "হয়", "hocche": "হচ্ছে",
        "bhai": "ভাই", "apa": "আপা", "amma": "আম্মা", "abba": "আব্বা",
        "school": "স্কুল", "college": "কলেজ", "university": "ইউনিভার্সিটি",
        "mobile": "মোবাইল", "computer": "কম্পিউটার", "internet": "ইন্টারনেট",
        "facebook": "ফেসবুক", "whatsapp": "হোয়াটসঅ্যাপ", "youtube": "ইউটিউব",
        "google": "গুগল", "email": "ইমেইল", "password": "পাসওয়ার্ড",
        "message": "মেসেজ", "friend": "ফ্রেন্ড", "love": "লাভ",
        "like": "লাইক", "comment": "কমেন্ট", "share": "শেয়ার"
    ]

    private let singleCharMap: [String: String] = [
        "o": "অ", "a": "া", "i": "ি", "I": "ঈ",
        "u": "ু", "U": "ঊ", "e": "ে", "oi": "ৈ", "ou": "ৌ",
        "k": "ক", "kh": "খ", "g": "গ", "gh": "ঘ", "ng": "ঙ",
        "c": "চ", "ch": "ছ", "j": "জ", "jh": "ঝ", "ny": "ঞ",
        "t": "ট", "th": "ঠ", "d": "ড", "dh": "ঢ", "n": "ন", "N": "ণ",
        "p": "প", "ph": "ফ", "f": "ফ", "b": "ব", "bh": "ভ", "v": "ভ",
        "m": "ম", "z": "য", "r": "র", "l": "ল",
        "sh": "শ", "s": "স", "h": "হ", "y": "য়", "T": "ৎ",
        "rri": "ৃ", "aa": "আ", "ee": "ঈ", "oo": "উ", "au": "ঔ"
    ]

    private let multiCharMap: [String: String] = [
        "kkh": "ক্ষ", "ksh": "ক্ষ", "ggh": "জ্ঞ", "gy": "জ্ঞ", "gg": "জ্ঞ",
        "chh": "চ্ছ", "cch": "চ্ছ", "jjh": "জ্ঝ",
        "tth": "ত্থ", "ddh": "ড্ঢ", "dd": "দ্ধ",
        "nn": "ন্ন", "mm": "ম্ম", "ll": "ল্ল",
        "shh": "শ্শ", "ssh": "শ্শ",
        "sst": "স্ত", "st": "স্ত", "sn": "স্ন", "sm": "স্ম", "sl": "স্ল",
        "hmm": "হ্ম", "hñ": "হ্ঞ",
        "ñch": "ঞ্চ", "ñj": "ঞ্জ", "ñjh": "ঞ্ঝ",
        "nT": "ণ্ট", "nTh": "ণ্ঠ", "nD": "ণ্ড", "nDh": "ণ্ঢ",
        "nt": "ন্ত", "nth": "ন্থ", "nd": "ন্দ", "ndh": "ন্ধ",
        "mb": "ম্ব", "mp": "ম্প", "mh": "ম্হ",
        "lT": "ল্ট", "lD": "ল্ড", "lk": "ল্ক", "lg": "ল্গ",
        "lp": "ল্প", "lb": "ল্ব", "lm": "ল্ম",
        "shn": "শ্ন", "shm": "শ্ম", "shl": "শ্ল",
        "ST": "ষ্ট", "STh": "ষ্ঠ", "Sh": "ষ", "sh": "শ", "s": "স", "h": "হ"
    ]

    private func longestMatch(in remaining: String) -> (String, String)? {
        let lower = remaining.lowercased()
        let keys = multiCharMap.keys.sorted { $0.count > $1.count }
        for key in keys {
            if lower.hasPrefix(key) {
                let original = String(remaining.prefix(key.count))
                if let output = multiCharMap[original.lowercased()] { return (original, output) }
            }
        }
        return
