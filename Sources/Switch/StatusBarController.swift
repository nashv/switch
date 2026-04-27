import AppKit

final class StatusBarController {
    private let item: NSStatusItem

    init() {
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.image = NSImage(systemSymbolName: "square.on.square", accessibilityDescription: "Switch")
            button.image?.isTemplate = true
        }
        let menu = NSMenu()
        menu.addItem(.init(title: "Quit Switch", action: #selector(quit), keyEquivalent: "q"))
        for it in menu.items { it.target = self }
        item.menu = menu
    }

    @objc private func quit() { NSApp.terminate(nil) }
}
