import AppKit
import ApplicationServices

/// 通过 Accessibility API 枚举所有前台 App 的标准窗口，逐个最小化。
final class WindowMinimizer {

    func minimizeAllWindows() {
        DispatchQueue.global(qos: .userInitiated).async {
            let workspace = NSWorkspace.shared
            let apps = workspace.runningApplications.filter { app in
                app.activationPolicy == .regular && !app.isHidden
            }

            for app in apps {
                self.minimizeWindows(of: app)
            }
        }
    }

    private func minimizeWindows(of app: NSRunningApplication) {
        let appElement = AXUIElementCreateApplication(app.processIdentifier)

        exitFullscreenIfNeeded(in: appElement)

        var windowList: CFTypeRef?
        let windowsError = AXUIElementCopyAttributeValue(
            appElement, kAXWindowsAttribute as CFString, &windowList
        )
        guard windowsError == .success,
              let windows = windowList as? [AXUIElement] else {
            return
        }

        for window in windows {
            var subroleRef: CFTypeRef?
            AXUIElementCopyAttributeValue(window, kAXSubroleAttribute as CFString, &subroleRef)
            let subrole = subroleRef as? String ?? ""
            guard subrole == kAXStandardWindowSubrole as String else { continue }

            var isMinimizedRef: CFTypeRef?
            AXUIElementCopyAttributeValue(window, kAXMinimizedAttribute as CFString, &isMinimizedRef)
            if (isMinimizedRef as? Bool) == true { continue }

            let result = AXUIElementSetAttributeValue(
                window, kAXMinimizedAttribute as CFString, true as CFBoolean
            )
            if result != .success {
                AXUIElementPerformAction(window, kAXMinimizeAction as CFString)
            }
        }
    }

    private func exitFullscreenIfNeeded(in appElement: AXUIElement) {
        var windowList: CFTypeRef?
        AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowList)
        guard let windows = windowList as? [AXUIElement] else { return }

        for window in windows {
            var isFullScreenRef: CFTypeRef?
            AXUIElementCopyAttributeValue(window, kAXFullScreenAttribute as CFString, &isFullScreenRef)
            if (isFullScreenRef as? Bool) == true {
                AXUIElementSetAttributeValue(window, kAXFullScreenAttribute as CFString, false as CFBoolean)
            }
        }
    }
}
