import SwiftUI

enum TE {
    // All neutrals on one warm aubergine axis. Single rose accent.
    static let bg        = Color(red: 0.102, green: 0.067, blue: 0.082) // #1A1115
    static let panel     = Color(red: 0.133, green: 0.094, blue: 0.122) // #22181F
    static let panelHi   = Color(red: 0.173, green: 0.129, blue: 0.165) // #2C212A
    static let stroke    = Color(red: 0.196, green: 0.149, blue: 0.180) // #32262E
    static let text      = Color(red: 0.937, green: 0.890, blue: 0.808) // #EFE3CE warm cream
    static let textDim   = Color(red: 0.659, green: 0.584, blue: 0.502) // #A89580
    static let textFaint = Color(red: 0.361, green: 0.302, blue: 0.267) // #5C4D44
    static let accent    = Color(red: 0.741, green: 0.514, blue: 0.467) // #BD8377 rose

    static let grid: CGFloat = 8
    static let strokeWidth: CGFloat = 1

    static func mono(_ size: CGFloat, _ weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}
