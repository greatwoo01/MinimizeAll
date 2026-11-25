import Foundation
import Carbon.HIToolbox

/// 基于 Carbon RegisterEventHotKey 的全局快捷键管理器。
final class HotKeyManager {
    var onTrigger: (() -> Void)?

    private var hotKeyRef: EventHotKeyRef?
    private var handlerRef: EventHandlerRef?

    func registerIfNeeded(settings: SettingsStore) {
        unregister()

        var modifierFlags: UInt32 = 0
        if settings.hotKeyModifiers.contains(.command) { modifierFlags |= UInt32(cmdKey) }
        if settings.hotKeyModifiers.contains(.shift)   { modifierFlags |= UInt32(shiftKey) }
        if settings.hotKeyModifiers.contains(.option)  { modifierFlags |= UInt32(optionKey) }
        if settings.hotKeyModifiers.contains(.control) { modifierFlags |= UInt32(controlKey) }
        let keyCode = UInt32(settings.hotKeyKeyCode ?? UInt(KeyCode.m.code))

        registerHotKey(keyCode: keyCode, modifiers: modifierFlags)
    }

    func unregister() {
        if let ref = hotKeyRef { UnregisterEventHotKey(ref) }
        if let ref = handlerRef { RemoveEventHandler(ref) }
        hotKeyRef = nil
        handlerRef = nil
    }

    private func registerHotKey(keyCode: UInt32, modifiers: UInt32) {
        InstallEventHandler(GetApplicationEventTarget(), { _, event, userData -> OSStatus in
            guard let userData = userData else { return noErr }
            let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
            manager.onTrigger?()
            return noErr
        }, 1, [EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                             eventKind: UInt32(kEventHotKeyPressed))],
           Unmanaged.passUnretained(self).toOpaque(), &handlerRef)

        let hotKeyID = EventHotKeyID(signature: OSType(0x4D494E41), id: 1) // "MINA"
        RegisterEventHotKey(keyCode, modifiers, hotKeyID,
                            GetApplicationEventTarget(), 0, &hotKeyRef)
    }
}

/// 常用字符的虚拟键码（US 键盘布局）。
enum KeyCode {
    static let a: UInt16 = 0
    static let b: UInt16 = 11
    static let c: UInt16 = 8
    static let d: UInt16 = 2
    static let e: UInt16 = 14
    static let f: UInt16 = 3
    static let g: UInt16 = 5
    static let h: UInt16 = 4
    static let i: UInt16 = 34
    static let j: UInt16 = 38
    static let k: UInt16 = 40
    static let l: UInt16 = 37
    static let m: UInt16 = 46
    static let n: UInt16 = 45
    static let o: UInt16 = 31
    static let p: UInt16 = 35
    static let q: UInt16 = 12
    static let r: UInt16 = 15
    static let s: UInt16 = 1
    static let t: UInt16 = 17
    static let u: UInt16 = 32
    static let v: UInt16 = 9
    static let w: UInt16 = 13
    static let x: UInt16 = 7
    static let y: UInt16 = 16
    static let z: UInt16 = 6
}
