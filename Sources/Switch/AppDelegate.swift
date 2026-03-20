import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let hotkey = HotkeyManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        hotkey.onCmdTab = { print("cmd-tab fired") }
        hotkey.install()
    }
}
