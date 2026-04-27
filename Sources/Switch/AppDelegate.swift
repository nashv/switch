import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let hotkey = HotkeyManager()
    private var statusBar: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBar = StatusBarController()
        hotkey.onCmdTab = { _ in print("cmd-tab fired") }
        hotkey.onCmdRelease = { print("cmd released") }
        hotkey.install()
    }
}
