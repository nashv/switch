import Foundation
import Carbon.HIToolbox

struct HotkeyConfig: Codable {
    var keyCode: Int
    var modifiers: UInt64

    static let defaultCmdTab = HotkeyConfig(
        keyCode: 48, // Tab
        modifiers: CGEventFlags.maskCommand.rawValue
    )
}
