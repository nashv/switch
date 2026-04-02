import SwiftUI

enum Design {
    static let panelWidth: CGFloat = 880
    static let panelHeight: CGFloat = 560
    static let columns: Int = 4

    static let tilePadding: CGFloat = 12
    static let tileCorner: CGFloat = 10

    static let bg = Color(nsColor: NSColor.windowBackgroundColor).opacity(0.85)
    static let stroke = Color.primary.opacity(0.08)
}
