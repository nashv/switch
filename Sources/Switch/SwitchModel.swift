import Foundation
import Combine

final class SwitchModel: ObservableObject {
    @Published private(set) var windows: [WindowInfo] = []

    func refresh() {
        windows = WindowEnumerator.list()
    }
}
