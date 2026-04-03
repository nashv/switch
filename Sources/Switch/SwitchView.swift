import SwiftUI

struct SwitchView: View {
    @ObservedObject var model: SwitchModel

    var body: some View {
        ZStack {
            VisualEffectBackdrop()
            VStack {
                Text("\(model.windows.count) windows")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: Design.panelWidth, height: Design.panelHeight)
    }
}
