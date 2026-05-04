import AppKit
import ApplicationServices
import CoreGraphics

final class HotkeyManager {
    enum Mode { case allWindows, currentApp }

    var onArm: ((Mode) -> Void)?
    var onAdvance: ((Bool) -> Void)?
    var onCommit: (() -> Void)?
    var onCancel: (() -> Void)?
    var onCloseSelected: (() -> Void)?
    var onFilterAppend: ((Character) -> Void)?
    var onFilterBackspace: (() -> Void)?

    private var tap: CFMachPort?
    private var source: CFRunLoopSource?
    private var armed: Mode?

    private static let kcEscape: CGKeyCode = 53
    private static let kcDelete: CGKeyCode = 51
    private static let kcRightArrow: CGKeyCode = 124

    func start() {
        if !ensureAccessibility() { return }
        installTap()
    }

    func stop() {
        if let tap { CGEvent.tapEnable(tap: tap, enable: false) }
        if let source { CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes) }
        tap = nil
        source = nil
    }

    @discardableResult
    private func ensureAccessibility() -> Bool {
        let key = "AXTrustedCheckOptionPrompt" as CFString
        let opts = [key: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(opts)
    }

    private func installTap() {
        let mask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.flagsChanged.rawValue)
        let info = Unmanaged.passUnretained(self).toOpaque()
        let cb: CGEventTapCallBack = { _, type, event, userInfo in
            guard let userInfo else { return Unmanaged.passUnretained(event) }
            let mgr = Unmanaged<HotkeyManager>.fromOpaque(userInfo).takeUnretainedValue()
            return mgr.handle(type: type, event: event)
        }
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(mask),
            callback: cb,
            userInfo: info
        ) else {
            NSLog("Switch: failed to create event tap")
            return
        }
        let src = CFMachPortCreateRunLoopSource(nil, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), src, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        self.tap = tap
        self.source = src
    }

    private func handle(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap { CGEvent.tapEnable(tap: tap, enable: true) }
            return Unmanaged.passUnretained(event)
        }

        let flags = event.flags
        let cmd = flags.contains(.maskCommand)
        let opt = flags.contains(.maskAlternate)
        let shift = flags.contains(.maskShift)
        let kc = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))

        if type == .keyDown {
            let allBinding = HotkeyConfig.shared.allWindows
            let appBinding = HotkeyConfig.shared.currentApp

            if allBinding.matchesTrigger(keyCode: kc, flags: flags) {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    if armed == nil { armed = .allWindows; onArm?(.allWindows) }
                    else { onAdvance?(shift) }
                }
                return nil
            }
            if appBinding.matchesTrigger(keyCode: kc, flags: flags) {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    if armed == nil { armed = .currentApp; onArm?(.currentApp) }
                    else { onAdvance?(shift) }
                }
                return nil
            }

            if armed != nil {
                if kc == Self.kcEscape {
                    DispatchQueue.main.async { [weak self] in
                        self?.armed = nil
                        self?.onCancel?()
                    }
                    return nil
                }
                if kc == Self.kcDelete {
                    DispatchQueue.main.async { [weak self] in
                        self?.onFilterBackspace?()
                    }
                    return nil
                }
                if kc == Self.kcRightArrow {
                    DispatchQueue.main.async { [weak self] in
                        self?.onCloseSelected?()
                    }
                    return nil
                }
                if let c = filterChar(from: event) {
                    DispatchQueue.main.async { [weak self] in
                        self?.onFilterAppend?(c)
                    }
                    return nil
                }
            }
        }

        if type == .flagsChanged {
            if armed == .allWindows && !HotkeyConfig.shared.allWindows.modifiersHeld(flags) {
                DispatchQueue.main.async { [weak self] in
                    self?.armed = nil
                    self?.onCommit?()
                }
            } else if armed == .currentApp && !HotkeyConfig.shared.currentApp.modifiersHeld(flags) {
                DispatchQueue.main.async { [weak self] in
                    self?.armed = nil
                    self?.onCommit?()
                }
            }
        }

        return Unmanaged.passUnretained(event)
    }

    /// Reinstall the tap so the new HotkeyConfig is picked up. Called when bindings change.
    func reload() {
        guard tap != nil else { return }
        stop()
        installTap()
    }

    private func filterChar(from event: CGEvent) -> Character? {
        guard let ns = NSEvent(cgEvent: event),
              let chars = ns.charactersIgnoringModifiers,
              let c = chars.first else { return nil }
        if c.isLetter || c.isNumber || c == " " || c == "-" || c == "." {
            return Character(c.lowercased())
        }
        return nil
    }
}
