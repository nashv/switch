import SwiftUI

struct OnboardingView: View {
    @StateObject private var model = OnboardingModel()
    var onComplete: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Switch needs two permissions")
                .font(.title2.weight(.semibold))
            Text("These let Switch intercept ⌘-Tab and capture window thumbnails.")
                .foregroundStyle(.secondary)

            permissionRow(
                title: "Accessibility",
                granted: model.hasAccessibility,
                action: model.openAccessibilityPane
            )
            permissionRow(
                title: "Screen Recording",
                granted: model.hasScreenRecording,
                action: model.openScreenRecordingPane
            )

            Spacer()
            HStack {
                Spacer()
                Button("Done") { onComplete() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!model.allGranted)
            }
        }
        .padding(28)
        .frame(width: 420, height: 320)
        .onAppear { model.startPolling() }
        .onDisappear { model.stopPolling() }
        .onChange(of: model.allGranted) { _, ok in if ok { onComplete() } }
    }

    @ViewBuilder
    private func permissionRow(title: String, granted: Bool, action: @escaping () -> Void) -> some View {
        HStack {
            Image(systemName: granted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(granted ? .green : .secondary)
            Text(title)
            Spacer()
            Button("Open Settings…", action: action)
                .disabled(granted)
        }
    }
}
