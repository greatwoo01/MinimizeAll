import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let menuBarController = MenuBarController()
    private let hotKeyManager = HotKeyManager()
    private let minimizer = WindowMinimizer()
    private let settings = SettingsStore()

    func applicationDidFinishLaunching(_ notification: Notification) {
        menuBarController.onTrigger = { [weak self] in
            self?.runMinimization()
        }
        menuBarController.onOpenSettings = { [weak self] in
            self?.openSettings()
        }

        hotKeyManager.onTrigger = { [weak self] in
            self?.runMinimization()
        }
        hotKeyManager.registerIfNeeded(settings: settings)

        applyLoginItemSetting(settings: settings)
    }

    private func runMinimization() {
        guard PermissionManager.hasAccessibilityPermission() else {
            PermissionManager.promptForAccessibility()
            return
        }
        minimizer.minimizeAllWindows()
    }

    private func openSettings() {
        let alert = NSAlert()
        alert.messageText = "MinimizeAll 设置"
        alert.informativeText = "（占位）此处可挂载完整的设置窗口，用于修改快捷键、切换开机自启等。"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "好")
        alert.runModal()
    }

    private func applyLoginItemSetting(settings: SettingsStore) {
        if settings.launchAtLogin {
            try? SMAppService.mainApp.register()
        } else {
            try? SMAppService.mainApp.unregister()
        }
    }
}
