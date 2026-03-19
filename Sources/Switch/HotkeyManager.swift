import AppKit

// NSEvent.addGlobalMonitor only OBSERVES events — it can't intercept or
// suppress them, so the system's built-in cmd-tab still fires alongside
// ours. Need CGEventTap instead.

final class HotkeyManager {
    func install() {
        // TODO: CGEventTap
    }
}
