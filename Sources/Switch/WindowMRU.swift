import Foundation

final class WindowMRU {
    private var order: [CGWindowID] = []

    func touch(_ id: CGWindowID) {
        order.removeAll { $0 == id }
        order.insert(id, at: 0)
    }

    func sort(_ windows: [WindowInfo]) -> [WindowInfo] {
        let positions = Dictionary(uniqueKeysWithValues: order.enumerated().map { ($1, $0) })
        return windows.sorted { (a, b) -> Bool in
            let pa = positions[a.id] ?? Int.max
            let pb = positions[b.id] ?? Int.max
            return pa < pb
        }
    }
}
