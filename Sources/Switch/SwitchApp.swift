import SwiftUI

@main
struct SwitchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Settings scene kept as a fallback. The menu bar's Settings… item
        // routes through SettingsWindow.show() instead, which manages its
        // own NSWindow because SwiftUI's Settings is unreliable on
        // .accessory apps.
        Settings {
            SettingsView()
        }
    }
}
