import SwiftUI

struct SwitchView: View {
    @ObservedObject var model: SwitchModel

    private var grid: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: Design.tilePadding), count: Design.columns)
    }

    var body: some View {
        ZStack {
            VisualEffectBackdrop()
            ScrollView {
                LazyVGrid(columns: grid, spacing: Design.tilePadding) {
                    ForEach(Array(model.windows.enumerated()), id: \.element.id) { idx, win in
                        Tile(window: win, selected: idx == model.selected)
                    }
                }
                .padding(Design.tilePadding)
            }
        }
        .frame(width: Design.panelWidth, height: Design.panelHeight)
    }
}

private struct Tile: View {
    let window: WindowInfo
    let selected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Rectangle()
                .fill(Color.gray.opacity(0.18))
                .aspectRatio(16.0/10.0, contentMode: .fit)
                .overlay(Text(window.ownerName).font(.caption2))
            Text(window.title)
                .font(.caption)
                .lineLimit(1)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: Design.tileCorner)
                .fill(selected ? Color.accentColor.opacity(0.25) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Design.tileCorner)
                .stroke(selected ? Color.accentColor : Design.stroke, lineWidth: selected ? 2 : 1)
        )
    }
}
