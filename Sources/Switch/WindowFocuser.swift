import AppKit
import ApplicationServices

enum WindowFocuser {
    static func focus(_ info: WindowInfo) {
        // 1) raise the owning app
        if let app = NSRunningApplication(processIdentifier: info.pid) {
            app.activate(options: [.activateIgnoringOtherApps])
        }
        // 2) raise the specific window via AX
        let axApp = AXUIElementCreateApplication(info.pid)
        var windowsRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &windowsRef) == .success,
              let windows = windowsRef as? [AXUIElement] else { return }
        for win in windows {
            var titleRef: CFTypeRef?
            AXUIElementCopyAttributeValue(win, kAXTitleAttribute as CFString, &titleRef)
            if let title = titleRef as? String, title == info.title {
                AXUIElementPerformAction(win, kAXRaiseAction as CFString)
                break
            }
        }
    }
}
