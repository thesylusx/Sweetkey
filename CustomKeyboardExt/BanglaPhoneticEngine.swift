import Foundation

final class BanglaPhoneticEngine {
    enum Language { case bangla, english }

    func convert(_ input: String, language: Language) -> String {
        switch language {
        case .english: return input
        case .bangla: return phoneticConvert(input.lowercased())
        }
    }

    private func phoneticConvert(_ input: String) -> String {
        guard !input.isEmpty else { return input }

        // ১. সরাসরি শব্দের অভিধান (Direct Word Dictionary)
        if let direct = directWords[input] { return direct }

        // ২. দীর্ঘতম সিকোয়েন্স ম্যাচিং (Longest Match Rules)
        var result = ""
        var i = input.startIndex

        while i < input.endIndex {
            let remaining = String(input[i...])
            
            // প্রথমে যুক্তাক্ষর বা বড় রুল চেক করবো
            if let (matched, output) = longestMatch(in: remaining) {
                result += output
                i = input.index(i, offsetBy: matched.count)
            } else {
                // পরে সাধারণ অক্ষর চেক করবো
                let ch = String(input[i])
                result += singleCharMap[ch] ?? ch
                i = input.index(after: i)
            }
        }

        return postProcess(result)
    }

    // MARK: - Dictionary & Rules

    private let directWords: [String: String] = [
        "ami": "আমি", "tumi": "তুমি", "apni": "আপনি",
        "bojhbo": "বোঝবো", "bujhbo": "বুঝবো", "kemon": "কেমন",
        "valo": "ভালো", "bhalo": "ভালো", "dhonnobad": "ধন্যবাদ",
        "bangla": "বাংলা", "bangladesh": "বাংলাদেশ",
        "amar": "আমার", "tomar": "তোমার", "apnar": "আপনার",
        "ki": "কি", "keno": "কেন", "kothay": "কোথায়",
        "onek": "অনেক", "khub": "খুব", "taratari": "তাড়াতাড়ি",
        "theek": "ঠিক", "thik": "ঠিক", "ache": "আছে", "nai": "নাই",
        "korbo": "করবো", "korte": "করতে", "kore": "করে",
        "korechi": "করেছি", "hobe": "হবে", "hoy": "হয়", "hocche": "হচ্ছে",
        "bhai": "ভাই", "apa": "আপা", "amma": "আম্মা", "abba": "আব্বা",
        "school": "স্কুল", "college": "কলেজ", "mobile": "মোবাইল", 
        "computer": "কম্পিউটার", "internet": "ইন্টারনেট", "facebook": "ফেসবুক"
    ]

    private let singleCharMap: [String: String] = [
        "o": "অ", "a": "আ", "i": "ই", "I": "ঈ", "u": "উ", "U": "ঊ",
        "rri": "ঋ", "e": "এ", "OI": "ঐ", "O": "ও", "OU": "ঔ",
        "k": "ক", "kh": "খ", "g": "গ", "gh": "ঘ", "Ng": "ঙ",
        "c": "চ", "ch": "ছ", "j": "জ", "jh": "ঝ", "NG": "ঞ",
        "T": "ট", "Th": "ঠ", "D": "ড", "Dh": "ঢ", "N": "ণ",
        "t": "ত", "th": "থ", "d": "দ", "dh": "ধ", "n": "ন",
        "p": "প", "f": "ফ", "ph": "ফ", "b": "ব", "v": "ভ", "bh": "ভ", "m": "ম",
        "z": "য", "r": "র", "l": "ল", "S": "শ", "sh": "শ", "Sh": "ষ",
        "s": "স", "h": "হ", "R": "ড়", "Rh": "ঢ়", "y": "য়", "TH": "ৎ",
        "ng": "ং", "qq": "ঁ"
    ]

    private let multiCharMap: [String: String] = [
        // যুক্তাক্ষর
        "kkh": "ক্ষ", "ksh": "ক্ষ", "ggh": "জ্ঞ", "gy": "জ্ঞ", "gg": "জ্ঞ",
        "chh": "চ্ছ", "cch": "চ্ছ", "jjh": "জ্ঝ", "tth": "ত্থ",
        "ddh": "ড্ঢ", "dd": "দ্ধ", "nn": "ন্ন", "mm": "ম্ম", "ll": "ল্ল",
        "shh": "শ্শ", "ssh": "শ্শ", "sst": "স্ত", "st": "স্ত",
        "sn": "স্ন", "sm": "স্ম", "sl": "স্ল", "hmm": "হ্ম", "hñ": "হ্ঞ",
        "ñch": "ঞ্চ", "ñj": "ঞ্জ", "ñjh": "ঞ্ঝ", "nT": "ণ্ট",
        "nTh": "ণ্ঠ", "nD": "ণ্ড", "nDh": "ণ্ঢ", "nt": "ন্ত",
        "nth": "ন্থ", "nd": "ন্দ", "ndh": "ন্ধ", "mb": "ম্ব",
        "mp": "ম্প", "mh": "ম্হ", "lT": "ল্ট", "lD": "ল্ড",
        "lk": "ল্ক", "lg": "ল্গ", "lp": "ল্প", "lb": "ল্ব",
        "lm": "ল্ম", "shn": "শ্ন", "shm": "শ্ম", "shl": "শ্ল",
        "ST": "ষ্ট", "STh": "ষ্ঠ",
        
        // কার-চিহ্ন (Vowel signs) - শব্দের মাঝে বসলে
        "OI": "ৈ", "OU": "ৌ", "o": "ো", "a": "া", "i": "ি", 
        "I": "ী", "u": "ু", "U": "ূ", "rri": "ৃ", "e": "ে",
        
        // হসন্ত (Hasanta) ও য-ফলা / ব-ফলা
        "\\": "্", "y": "্য", "w": "্ব", "r": "্র"
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
        return nil
    }

    private func postProcess(_ input: String) -> String {
        var result = input
        // কার-চিহ্ন ব্যবহারের পর হসন্ত ঠিক করা
        result = result.replacingOccurrences(of: "ো", with: "ো")
        return result
    }
}
