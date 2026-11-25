import Foundation

/// 偏好设置持久化（UserDefaults）。
final class SettingsStore {

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let launchAtLogin = "launchAtLogin"
        static let hotKeyKeyCode = "hotKeyKeyCode"
        static let hotKeyModifiers = "hotKeyModifiers"
    }

    var launchAtLogin: Bool {
        get { defaults.object(forKey: Keys.launchAtLogin) as? Bool ?? false }
        set { defaults.set(newValue, forKey: Keys.launchAtLogin) }
    }

    var hotKeyKeyCode: UInt16? {
        get { defaults.object(forKey: Keys.hotKeyKeyCode) as? UInt16 ?? KeyCode.m }
        set {
            if let v = newValue { defaults.set(Int(v), forKey: Keys.hotKeyKeyCode) }
        }
    }

    var hotKeyModifiers: NSEvent.ModifierFlags {
        get {
            let raw = defaults.object(forKey: Keys.hotKeyModifiers) as? UInt ?? 0
            let saved = NSEvent.ModifierFlags(rawValue: raw)
            return saved.isEmpty ? [.command, .shift] : saved
        }
        set { defaults.set(newValue.rawValue, forKey: Keys.hotKeyModifiers) }
    }
}
