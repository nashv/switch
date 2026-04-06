import Foundation
import Combine

final class SwitchModel: ObservableObject {
    @Published private(set) var windows: [WindowInfo] = []
    @Published var selected: Int = 0

    func refresh() {
        windows = WindowEnumerator.list()
        if selected >= windows.count { selected = 0 }
    }

    func advance() {
        guard !windows.isEmpty else { return }
        selected = (selected + 1) % windows.count
    }

    func back() {
        guard !windows.isEmpty else { return }
        selected = (selected - 1 + windows.count) % windows.count
    }
}
