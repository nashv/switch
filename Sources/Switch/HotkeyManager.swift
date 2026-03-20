import AppKit
import Carbon.HIToolbox

final class HotkeyManager {
    private var tap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    var onCmdTab: () -> Void = {}

    func install() {
        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)

        let callback: CGEventTapCallBack = { _, type, event, refcon in
            guard let refcon else { return Unmanaged.passUnretained(event) }
            let me = Unmanaged<HotkeyManager>.fromOpaque(refcon).takeUnretainedValue()
            return me.handle(event)
        }

        let opaque = Unmanaged.passUnretained(self).toOpaque()
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: opaque
        ) else {
            print("[hotkey] tap create failed — Accessibility not granted?")
            return
        }
        self.tap = tap
        self.runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    private func handle(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let cmd = event.flags.contains(.maskCommand)
        // 48 = Tab
        if keyCode == 48 && cmd {
            DispatchQueue.main.async { self.onCmdTab() }
            return nil // swallow so system cmd-tab doesn't also fire
        }
        return Unmanaged.passUnretained(event)
    }
}
