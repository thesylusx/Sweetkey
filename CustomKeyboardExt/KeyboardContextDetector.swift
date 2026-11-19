import UIKit

enum KeyboardContextType {
    case standard, email, url, numberOnly, phoneNumber, name
}

enum KeyboardContextDetector {
    static func detect(from proxy: UITextDocumentProxy) -> KeyboardContextType {
        switch proxy.keyboardType {
        case .emailAddress: return .email
        case .URL: return .url
        case .numberPad, .decimalPad, .asciiCapableNumberPad: return .numberOnly
        case .phonePad: return .phoneNumber
        case .namePhonePad: return .name
        case .numbersAndPunctuation, .twitter, .webSearch, .default, .asciiCapable, .none:
            return .standard
        @unknown default: return .standard
        }
    }
}
