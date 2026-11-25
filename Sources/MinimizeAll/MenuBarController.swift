import AppKit

/// 菜单栏控制器：负责 NSStatusItem、双击判定、右键菜单。
final class MenuBarController {
    var onTrigger: (() -> Void)?
    var onOpenSettings: (() -> Void)?

    private var statusItem: NSStatusItem!
    private var clickCountTimer: Timer?
    private var hasReceivedClick = false

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "rectangle.compress.vertical",
                                   accessibilityDescription: "MinimizeAll")
            button.target = self
            button.action = #selector(leftClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    @objc private func leftClick(_ sender: Any?) {
        let event = NSApp.currentEvent

        if event?.type == .rightMouseUp {
            showMenu()
            return
        }

        guard let clickCount = event?.clickCount else { return }

        if clickCount >= 2 {
            hasReceivedClick = false
            clickCountTimer?.invalidate()
            clickCountTimer = nil
            onTrigger?()
        } else {
            hasReceivedClick = true
            clickCountTimer?.invalidate()
            clickCountTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                if self.hasReceivedClick {
                    self.hasReceivedClick = false
                    self.showMenu()
                }
            }
        }
    }

    private func showMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "最小化所有窗口", action: #selector(trigger), keyEquivalent: ""))
        menu.items.first?.target = self
        menu.addItem(.separator())
        let settingsItem = NSMenuItem(title: "设置…", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "退出 MinimizeAll", action: #selector(quit), keyEquivalent: "q"))
        menu.items.last?.target = self
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func trigger() { onTrigger?() }
    @objc private func openSettings() { onOpenSettings?() }
    @objc private func quit() { NSApp.terminate(nil) }
}
