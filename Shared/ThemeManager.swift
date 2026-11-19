import Foundation
import UIKit

enum ThemeID: String, CaseIterable {
    case defaultLight = "default_light"
    case defaultDark  = "default_dark"
    case amoledBlack  = "amoled_black"
    case neonGlow     = "neon_glow"
    case pinkBlossom  = "pink_blossom"
    case materialBlue = "material_blue"
    case forestGreen  = "forest_green"
    case sunset       = "sunset"

    var displayName: String {
        switch self {
        case .defaultLight: return "Default Light"
        case .defaultDark:  return "Default Dark"
        case .amoledBlack:  return "AMOLED Black"
        case .neonGlow:     return "Neon Glow"
        case .pinkBlossom:  return "Pink Blossom"
        case .materialBlue: return "Material Blue"
        case .forestGreen:  return "Forest Green"
        case .sunset:       return "Sunset"
        }
    }
}

final class ThemeManager {
    static let shared = ThemeManager()
    static let suiteName = "group.com.sweet.customkeyboard"
    private static let themeKey = "sweetkey.selectedTheme"
    private static let hapticsKey = "sweetkey.hapticsEnabled"
    private static let soundKey = "sweetkey.soundEnabled"
    private init() {}

    var currentThemeID: ThemeID {
        get {
            let raw = UserDefaults(suiteName: Self.suiteName)?.string(forKey: Self.themeKey) ?? ThemeID.defaultDark.rawValue
            return ThemeID(rawValue: raw) ?? .defaultDark
        }
        set {
            UserDefaults(suiteName: Self.suiteName)?.set(newValue.rawValue, forKey: Self.themeKey)
            UserDefaults(suiteName: Self.suiteName)?.synchronize()
        }
    }

    var currentTheme: KeyboardTheme { KeyboardTheme.theme(for: currentThemeID) }

    var hapticsEnabled: Bool {
        get {
            let d = UserDefaults(suiteName: Self.suiteName)
            if d?.object(forKey: Self.hapticsKey) == nil { return true }
            return d?.bool(forKey: Self.hapticsKey) ?? true
        }
        set {
            UserDefaults(suiteName: Self.suiteName)?.set(newValue, forKey: Self.hapticsKey)
            UserDefaults(suiteName: Self.suiteName)?.synchronize()
        }
    }

    var soundEnabled: Bool {
        get { UserDefaults(suiteName: Self.suiteName)?.bool(forKey: Self.soundKey) ?? false }
        set {
            UserDefaults(suiteName: Self.suiteName)?.set(newValue, forKey: Self.soundKey)
            UserDefaults(suiteName: Self.suiteName)?.synchronize()
        }
    }
}
