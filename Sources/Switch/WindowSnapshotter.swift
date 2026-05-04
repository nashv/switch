import AppKit
import ScreenCaptureKit

@available(macOS 14.0, *)
actor WindowSnapshotter {
    static let shared = WindowSnapshotter()

    private var cache: [CGWindowID: NSImage] = [:]
    private var inFlight: Set<CGWindowID> = []

    func snapshot(for id: CGWindowID, force: Bool = false) async -> NSImage? {
        if !force, let img = cache[id] { return img }
        if inFlight.contains(id) { return nil }
        inFlight.insert(id)
        defer { inFlight.remove(id) }

        // ScreenCaptureKit first — sharper, live-capable for active-Space windows.
        // onScreenWindowsOnly: false so we still see off-Space window entries here.
        if let img = await captureViaSCK(id: id) {
            cache[id] = img
            return img
        }
        // Fallback: window-server cache via CGWindowListCreateImage. Works for off-Space /
        // hidden / minimized windows where ScreenCaptureKit refuses (no live surface).
        if let img = captureViaCG(id: id) {
            cache[id] = img
            return img
        }
        return nil
    }

    private func captureViaSCK(id: CGWindowID) async -> NSImage? {
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
            guard let scWindow = content.windows.first(where: { $0.windowID == id }) else { return nil }
            let filter = SCContentFilter(desktopIndependentWindow: scWindow)
            let cfg = SCStreamConfiguration()
            cfg.width = max(1, Int(scWindow.frame.width))
            cfg.height = max(1, Int(scWindow.frame.height))
            cfg.showsCursor = false
            let cg = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: cfg)
            return NSImage(cgImage: cg, size: NSSize(width: cg.width, height: cg.height))
        } catch {
            return nil
        }
    }

    private nonisolated func captureViaCG(id: CGWindowID) -> NSImage? {
        // CGWindowListCreateImage is deprecated in 14+ but the only path for off-Space windows.
        let opts: CGWindowImageOption = [.boundsIgnoreFraming, .nominalResolution]
        guard let cg = CGWindowListCreateImage(.null, .optionIncludingWindow, id, opts) else {
            return nil
        }
        guard cg.width > 0, cg.height > 0 else { return nil }
        return NSImage(cgImage: cg, size: NSSize(width: cg.width, height: cg.height))
    }

    func purge() {
        cache.removeAll()
    }

    /// Drop cached entries for windows no longer in `keep`. Used by the pre-warm path
    /// so live thumbs survive between panel opens but dead window IDs don't accumulate.
    func purge(keeping keep: Set<CGWindowID>) {
        cache = cache.filter { keep.contains($0.key) }
    }
}
