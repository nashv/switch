import AppKit
import ApplicationServices

enum WindowFocuser {
    static func focus(_ window: WindowInfo) {
        let app = NSRunningApplication(processIdentifier: window.pid)
        app?.activate()

        let appAX = AXUIElementCreateApplication(window.pid)
        var ref: CFTypeRef?
        guard AXUIElementCopyAttributeValue(appAX, kAXWindowsAttribute as CFString, &ref) == .success,
              let axWindows = ref as? [AXUIElement] else {
            WindowMRU.touch(window.id)
            return
        }

        if let match = axWindows.first(where: { AXHelpers.title(of: $0) == window.title }) {
            AXUIElementPerformAction(match, kAXRaiseAction as CFString)
            AXUIElementSetAttributeValue(match, kAXMainAttribute as CFString, kCFBooleanTrue)
        } else if let first = axWindows.first {
            AXUIElementPerformAction(first, kAXRaiseAction as CFString)
        }
        WindowMRU.touch(window.id)
    }
}

enum WindowCloser {
    /// Sends a close action to the AX window matching `window`. Best-effort.
    static func close(_ window: WindowInfo) {
        let appAX = AXUIElementCreateApplication(window.pid)
        var ref: CFTypeRef?
        guard AXUIElementCopyAttributeValue(appAX, kAXWindowsAttribute as CFString, &ref) == .success,
              let axWindows = ref as? [AXUIElement] else { return }
        let target = axWindows.first(where: { AXHelpers.title(of: $0) == window.title }) ?? axWindows.first
        guard let target else { return }
        var btnRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(target, kAXCloseButtonAttribute as CFString, &btnRef) == .success,
              let btnObj = btnRef else { return }
        // CFTypeRef from AXUIElementCopyAttributeValue is an AXUIElement under the hood.
        let closeBtn = btnObj as! AXUIElement
        AXUIElementPerformAction(closeBtn, kAXPressAction as CFString)
    }
}

enum AXHelpers {
    static func title(of element: AXUIElement) -> String {
        var ref: CFTypeRef?
        AXUIElementCopyAttributeValue(element, kAXTitleAttribute as CFString, &ref)
        return ref as? String ?? ""
    }
}
