import AppKit
import SwiftUI

/// Manual settings window. SwiftUI's `Settings { }` scene is unreliable
/// on `.accessory` apps, so we host `SettingsView` in our own NSWindow.
@MainActor
final class SettingsWindow {
    static let shared = SettingsWindow()

    private var window: NSWindow?

    private init() {}

    func show() {
        if let existing = window {
            NSApp.activate(ignoringOtherApps: true)
            existing.makeKeyAndOrderFront(nil)
            return
        }

        let host = NSHostingController(rootView: SettingsView())
        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 400),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        win.title = "Switch Settings"
        win.contentViewController = host
        win.center()
        win.isReleasedWhenClosed = false
        win.delegate = SettingsWindowDelegate.shared

        window = win
        NSApp.activate(ignoringOtherApps: true)
        win.makeKeyAndOrderFront(nil)
    }

    func handleClose() {
        window = nil
    }
}

private final class SettingsWindowDelegate: NSObject, NSWindowDelegate {
    static let shared = SettingsWindowDelegate()

    func windowWillClose(_ notification: Notification) {
        Task { @MainActor in
            SettingsWindow.shared.handleClose()
        }
    }
}
