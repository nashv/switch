import AppKit

final class StatusBarController {
    private let item: NSStatusItem

    init() {
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = item.button {
            let img = NSImage(systemSymbolName: "square.on.square", accessibilityDescription: "Switch")
            img?.isTemplate = true
            button.image = img
        }

        let menu = NSMenu()

        let header = NSMenuItem(title: "Switch", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)

        menu.addItem(.separator())

        let settings = NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ",")
        settings.target = self
        menu.addItem(settings)

        let permissions = NSMenuItem(title: "Permissions…", action: #selector(showOnboarding), keyEquivalent: "")
        permissions.target = self
        menu.addItem(permissions)

        menu.addItem(.separator())

        let quit = NSMenuItem(title: "Quit Switch", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quit.target = NSApp
        menu.addItem(quit)

        item.menu = menu
    }

    @objc private func showOnboarding() {
        NotificationCenter.default.post(name: .switchShowOnboarding, object: nil)
    }

    @objc private func openSettings() {
        // SwiftUI's Settings scene doesn't reliably show with .accessory
        // activation policy. Send the action, then locate the window and
        // force it front on the next runloop tick.
        NSApp.activate(ignoringOtherApps: true)
        if #available(macOS 14, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
        DispatchQueue.main.async {
            for window in NSApp.windows where window.title == "Switch Settings" || window.frameAutosaveName == "com_apple_SwiftUI_Settings_window" {
                window.level = .floating
                window.makeKeyAndOrderFront(nil)
                window.level = .normal
            }
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

extension Notification.Name {
    static let switchShowOnboarding = Notification.Name("com.sanyamgarg.switch.showOnboarding")
}
