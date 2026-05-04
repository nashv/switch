import AppKit
import CoreGraphics

struct WindowInfo: Identifiable, Hashable {
    let id: CGWindowID
    let pid: pid_t
    let appName: String
    let title: String
    let bounds: CGRect
}

enum WindowEnumerator {
    private static let skipApps: Set<String> = [
        "Window Server", "Dock", "SystemUIServer", "Control Center",
        "Notification Center", "Spotlight", "WallpaperAgent", "Switch",
        "loginwindow", "talagent", "TextInputMenuAgent", "TextInputSwitcher",
        "universalControl", "ControlStrip", "ScreenshotCapture"
    ]

    /// Process-name suffixes that mark XPC helper / agent / renderer subprocesses,
    /// not user-facing windows (e.g. "Cursor AI View Service", "Chrome Helper").
    private static let helperSuffixes: [String] = [
        "Helper", " Helper", " Helper (Renderer)", " Helper (GPU)", " Helper (Plugin)",
        "Agent", " Agent",
        "Service", " Service", " View Service",
        "Renderer", "(Renderer)",
        "WebContent", "Networking",
        "Extension"
    ]

    private static func isHelperProcess(_ name: String) -> Bool {
        for s in helperSuffixes where name.hasSuffix(s) { return true }
        return false
    }

    struct Enumeration {
        let activeSpace: [WindowInfo] // in front-to-back z-order from the OS
        let crossSpace: [WindowInfo]  // arbitrary order — needs MRU sort upstream
    }

    static func currentWindows(scope: HotkeyManager.Mode, frontmostPID: pid_t?) -> [WindowInfo] {
        let e = enumerate(scope: scope, frontmostPID: frontmostPID)
        return e.activeSpace + e.crossSpace
    }

    static func enumerate(scope: HotkeyManager.Mode, frontmostPID: pid_t?) -> Enumeration {
        // Two-pass:
        //   - .onScreenOnly returns active-Space windows in reliable front-to-back z-order.
        //     Trust this completely — it reflects the OS's focus history.
        //   - .optionAll adds windows on other Spaces (hidden + minimized + cross-Space).
        //     Order is unreliable here; the caller should sort with MRU as a tiebreaker.
        let activeSpace = enumerate(option: [.optionOnScreenOnly, .excludeDesktopElements], scope: scope, frontmostPID: frontmostPID)
        let everything = enumerate(option: [.optionAll, .excludeDesktopElements], scope: scope, frontmostPID: frontmostPID)
        let activeIDs = Set(activeSpace.map { $0.id })
        let crossSpace = everything.filter { !activeIDs.contains($0.id) }
        return Enumeration(activeSpace: activeSpace, crossSpace: crossSpace)
    }

    private static func enumerate(option: CGWindowListOption, scope: HotkeyManager.Mode, frontmostPID: pid_t?) -> [WindowInfo] {
        guard let raw = CGWindowListCopyWindowInfo(option, kCGNullWindowID) as? [[String: Any]] else {
            return []
        }
        var out: [WindowInfo] = []
        var seen: Set<String> = []
        for d in raw {
            guard let layer = d[kCGWindowLayer as String] as? Int, layer == 0 else { continue }
            guard let alpha = d[kCGWindowAlpha as String] as? Double, alpha > 0 else { continue }
            guard let id = d[kCGWindowNumber as String] as? CGWindowID else { continue }
            guard let pid = d[kCGWindowOwnerPID as String] as? pid_t else { continue }
            let appName = d[kCGWindowOwnerName as String] as? String ?? ""
            if skipApps.contains(appName) { continue }
            if isHelperProcess(appName) { continue }
            let title = d[kCGWindowName as String] as? String ?? ""
            let boundsDict = d[kCGWindowBounds as String] as? [String: CGFloat] ?? [:]
            let bounds = CGRect(
                x: boundsDict["X"] ?? 0,
                y: boundsDict["Y"] ?? 0,
                width: boundsDict["Width"] ?? 0,
                height: boundsDict["Height"] ?? 0
            )
            if bounds.width < 100 || bounds.height < 80 { continue }
            if title.isEmpty && (bounds.width < 400 || bounds.height < 300) { continue }
            let dedupeKey = "\(pid):\(title):\(Int(bounds.width))x\(Int(bounds.height))"
            if seen.contains(dedupeKey) { continue }
            seen.insert(dedupeKey)
            if scope == .currentApp, let f = frontmostPID, pid != f { continue }
            out.append(WindowInfo(id: id, pid: pid, appName: appName, title: title, bounds: bounds))
        }
        return out
    }
}
