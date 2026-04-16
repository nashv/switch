import Foundation

final class WindowMRU {
    private var order: [CGWindowID] = []

    func touch(_ id: CGWindowID) {
        order.removeAll { $0 == id }
        order.insert(id, at: 0)
    }

    func seedIfEmpty(_ windows: [WindowInfo]) {
        guard order.isEmpty else { return }
        order = windows.map { $0.id }
    }

    /// On the ACTIVE Space, trust the OS z-order — that's what users expect
    /// for "next window." Across Spaces the OS doesn't give us z-ordering
    /// (no on-screen position), so fall back to our own MRU index.
    func sort(active: [WindowInfo], offSpace: [WindowInfo]) -> [WindowInfo] {
        let positions = Dictionary(uniqueKeysWithValues: order.enumerated().map { ($1, $0) })
        let mruSorted = offSpace.sorted { (a, b) -> Bool in
            let pa = positions[a.id] ?? Int.max
            let pb = positions[b.id] ?? Int.max
            return pa < pb
        }
        return active + mruSorted
    }
}
