import UIKit

struct KeyboardTheme {
    let id: ThemeID
    let background: UIColor
    let keyBackground: UIColor
    let keyText: UIColor
    let specialKeyBackground: UIColor
    let specialKeyText: UIColor
    let toolbarBackground: UIColor
    let toolbarText: UIColor
    let accentColor: UIColor

    var suggestionBackground: UIColor { toolbarBackground }
    var clipboardBackground: UIColor { toolbarBackground }

    static func theme(for id: ThemeID) -> KeyboardTheme {
        switch id {
        case .defaultLight: return .defaultLight
        case .defaultDark:  return .defaultDark
        case .amoledBlack:  return .amoledBlack
        case .neonGlow:     return .neonGlow
        case .pinkBlossom:  return .pinkBlossom
        case .materialBlue: return .materialBlue
        case .forestGreen:  return .forestGreen
        case .sunset:       return .sunset
        }
    }

    static let defaultLight = KeyboardTheme(
        id: .defaultLight,
        background: UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1),
        keyBackground: .white, keyText: .black,
        specialKeyBackground: UIColor(red: 0.82, green: 0.82, blue: 0.84, alpha: 1),
        specialKeyText: .black,
        toolbarBackground: UIColor(red: 0.90, green: 0.90, blue: 0.92, alpha: 1),
        toolbarText: .darkGray, accentColor: .systemBlue)

    static let defaultDark = KeyboardTheme(
        id: .defaultDark,
        background: UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1),
        keyBackground: UIColor(red: 0.23, green: 0.23, blue: 0.24, alpha: 1),
        keyText: .white,
        specialKeyBackground: UIColor(red: 0.34, green: 0.34, blue: 0.36, alpha: 1),
        specialKeyText: .white,
        toolbarBackground: UIColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1),
        toolbarText: .lightGray, accentColor: .systemBlue)

    static let amoledBlack = KeyboardTheme(
        id: .amoledBlack, background: .black,
        keyBackground: UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1),
        keyText: .white,
        specialKeyBackground: UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1),
        specialKeyText: .white,
        toolbarBackground: UIColor(red: 0.04, green: 0.04, blue: 0.04, alpha: 1),
        toolbarText: UIColor(white: 0.7, alpha: 1), accentColor: .systemTeal)

    static let neonGlow = KeyboardTheme(
        id: .neonGlow,
        background: UIColor(red: 0.06, green: 0.06, blue: 0.14, alpha: 1),
        keyBackground: UIColor(red: 0.12, green: 0.10, blue: 0.30, alpha: 1),
        keyText: UIColor(red: 0.00, green: 0.90, blue: 1.00, alpha: 1),
        specialKeyBackground: UIColor(red: 0.35, green: 0.00, blue: 0.55, alpha: 1),
        specialKeyText: UIColor(red: 1.00, green: 0.30, blue: 1.00, alpha: 1),
        toolbarBackground: UIColor(red: 0.10, green: 0.10, blue: 0.20, alpha: 1),
        toolbarText: UIColor(red: 0.00, green: 0.90, blue: 1.00, alpha: 1),
        accentColor: UIColor(red: 1.00, green: 0.30, blue: 1.00, alpha: 1))

    static let pinkBlossom = KeyboardTheme(
        id: .pinkBlossom,
        background: UIColor(red: 1.00, green: 0.94, blue: 0.96, alpha: 1),
        keyBackground: .white, keyText: UIColor(red: 0.55, green: 0.04, blue: 0.31, alpha: 1),
        specialKeyBackground: UIColor(red: 1.00, green: 0.75, blue: 0.80, alpha: 1),
        specialKeyText: UIColor(red: 0.55, green: 0.04, blue: 0.31, alpha: 1),
        toolbarBackground: UIColor(red: 1.00, green: 0.89, blue: 0.92, alpha: 1),
        toolbarText: UIColor(red: 0.55, green: 0.04, blue: 0.31, alpha: 1),
        accentColor: UIColor(red: 0.91, green: 0.30, blue: 0.55, alpha: 1))

    static let materialBlue = KeyboardTheme(
        id: .materialBlue,
        background: UIColor(red: 0.89, green: 0.95, blue: 0.99, alpha: 1),
        keyBackground: .white, keyText: UIColor(red: 0.05, green: 0.28, blue: 0.63, alpha: 1),
        specialKeyBackground: UIColor(red: 0.73, green: 0.87, blue: 0.98, alpha: 1),
        specialKeyText: UIColor(red: 0.05, green: 0.28, blue: 0.63, alpha: 1),
        toolbarBackground: UIColor(red: 0.56, green: 0.79, blue: 0.98, alpha: 1),
        toolbarText: .white, accentColor: UIColor(red: 0.13, green: 0.59, blue: 0.95, alpha: 1))

    static let forestGreen = KeyboardTheme(
        id: .forestGreen,
        background: UIColor(red: 0.10, green: 0.18, blue: 0.10, alpha: 1),
        keyBackground: UIColor(red: 0.18, green: 0.29, blue: 0.18, alpha: 1),
        keyText: UIColor(red: 0.91, green: 0.96, blue: 0.91, alpha: 1),
        specialKeyBackground: UIColor(red: 0.29, green: 0.42, blue: 0.29, alpha: 1),
        specialKeyText: UIColor(red: 0.91, green: 0.96, blue: 0.91, alpha: 1),
        toolbarBackground: UIColor(red: 0.08, green: 0.14, blue: 0.08, alpha: 1),
        toolbarText: UIColor(red: 0.65, green: 0.85, blue: 0.65, alpha: 1),
        accentColor: UIColor(red: 0.42, green: 0.75, blue: 0.42, alpha: 1))

    static let sunset = KeyboardTheme(
        id: .sunset,
        background: UIColor(red: 0.16, green: 0.03, blue: 0.24, alpha: 1),
        keyBackground: UIColor(red: 0.39, green: 0.25, blue: 0.55, alpha: 1),
        keyText: .white,
        specialKeyBackground: UIColor(red: 1.00, green: 0.42, blue: 0.21, alpha: 1),
        specialKeyText: .white,
        toolbarBackground: UIColor(red: 0.10, green: 0.02, blue: 0.15, alpha: 1),
        toolbarText: UIColor(red: 1.00, green: 0.78, blue: 0.50, alpha: 1),
        accentColor: UIColor(red: 1.00, green: 0.42, blue: 0.21, alpha: 1))
}
