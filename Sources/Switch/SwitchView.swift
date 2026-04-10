import SwiftUI

struct SwitchView: View {
    @ObservedObject var model: SwitchModel
    var onCommit: () -> Void = {}

    private var grid: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: Design.tilePadding), count: Design.columns)
    }

    var body: some View {
        ZStack {
            VisualEffectBackdrop()
            VStack(spacing: 0) {
                ScrollView {
                    LazyVGrid(columns: grid, spacing: Design.tilePadding) {
                        ForEach(Array(model.windows.enumerated()), id: \.element.id) { idx, win in
                            Tile(window: win, selected: idx == model.selected)
                                .onTapGesture {
                                    model.selected = idx
                                    onCommit()
                                }
                        }
                    }
                    .padding(Design.tilePadding)
                }
                hintStrip
            }
        }
        .frame(width: Design.panelWidth, height: Design.panelHeight)
        .onKeyPress(.tab) { model.advance(); return .handled }
        .onKeyPress(.leftArrow) { model.back(); return .handled }
        .onKeyPress(.rightArrow) { model.advance(); return .handled }
        .onKeyPress(.return) { onCommit(); return .handled }
        .onKeyPress(.escape) { onCommit(); return .handled }
    }

    private var hintStrip: some View {
        HStack(spacing: 14) {
            if !model.filter.isEmpty {
                Text(model.filter)
                    .font(.system(.callout, design: .monospaced))
                    .foregroundStyle(.primary)
                Spacer()
            } else {
                Spacer()
            }
            Text("return / esc / type / ⇧")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
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
        .shadow(color: selected ? Color.accentColor.opacity(0.3) : .clear, radius: selected ? 8 : 0)
    }
}
