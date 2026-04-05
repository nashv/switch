import AppKit
import ScreenCaptureKit

enum WindowSnapshotter {
    static func snapshot(_ windowID: CGWindowID) async -> NSImage? {
        do {
            let content = try await SCShareableContent.current
            guard let win = content.windows.first(where: { $0.windowID == windowID }) else { return nil }
            let filter = SCContentFilter(desktopIndependentWindow: win)
            let cfg = SCStreamConfiguration()
            cfg.width = Int(win.frame.width)
            cfg.height = Int(win.frame.height)
            cfg.captureResolution = .nominal
            let cgImage = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: cfg)
            return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        } catch {
            print("[snapshot] failed for \(windowID): \(error)")
            return nil
        }
    }
}
