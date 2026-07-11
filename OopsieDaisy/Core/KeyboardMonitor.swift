//
//  KeyboardMonitor.swift
//  OopsieDaisy
//
//  Listens to keystrokes system-wide via a listen-only CGEventTap and
//  accumulates the word currently being typed. It never blocks or modifies
//  the user's keystrokes itself — correction happens afterwards by
//  synthesizing new events (see TextInjector).
//

import Carbon.HIToolbox
import CoreGraphics
import Foundation

struct BoundaryKey {
    let keyCode: CGKeyCode
    let flags: CGEventFlags
}

protocol KeyboardMonitorDelegate: AnyObject {
    func keyboardMonitor(_ monitor: KeyboardMonitor, didCompleteWord buffer: WordBuffer, boundary: BoundaryKey)
}

final class KeyboardMonitor {
    weak var delegate: KeyboardMonitorDelegate?
    private(set) var isRunning = false

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var buffer = WordBuffer()

    // Virtual key codes, see HIToolbox/Events.h.
    private static let backspaceKeyCode: CGKeyCode = 51
    private static let boundaryKeyCodes: Set<CGKeyCode> = [36, 48, 49, 76] // Return, Tab, Space, Keypad Enter
    private static let resetKeyCodes: Set<CGKeyCode> = [123, 124, 125, 126, 53] // arrows, Escape

    @discardableResult
    func start() -> Bool {
        guard !isRunning else { return true }

        let mask: CGEventMask =
            (1 << CGEventType.keyDown.rawValue) |
            (1 << CGEventType.leftMouseDown.rawValue) |
            (1 << CGEventType.rightMouseDown.rawValue)

        let refcon = Unmanaged.passUnretained(self).toOpaque()
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: { _, type, event, refcon in
                if let refcon {
                    Unmanaged<KeyboardMonitor>.fromOpaque(refcon).takeUnretainedValue().handle(type: type, event: event)
                }
                return Unmanaged.passUnretained(event)
            },
            userInfo: refcon
        ) else {
            return false
        }

        eventTap = tap
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        runLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        isRunning = true
        return true
    }

    func stop() {
        if let tap = eventTap { CGEvent.tapEnable(tap: tap, enable: false) }
        if let source = runLoopSource { CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes) }
        eventTap = nil
        runLoopSource = nil
        isRunning = false
    }

    func resetBuffer() {
        buffer.clear()
    }

    private func handle(type: CGEventType, event: CGEvent) {
        if TextInjector.isSynthetic(event) { return }

        if type == .leftMouseDown || type == .rightMouseDown {
            buffer.clear()
            return
        }
        guard type == .keyDown else { return }

        // Never buffer or act on anything typed while a secure field (e.g.
        // a password) has focus.
        guard !IsSecureEventInputEnabled() else {
            buffer.clear()
            return
        }

        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        let flags = event.flags

        if flags.contains(.maskCommand) || flags.contains(.maskControl) {
            buffer.clear()
            return
        }

        if keyCode == Self.backspaceKeyCode {
            buffer.removeLast()
            return
        }

        if Self.resetKeyCodes.contains(keyCode) {
            buffer.clear()
            return
        }

        if Self.boundaryKeyCodes.contains(keyCode) {
            completeWord(boundary: BoundaryKey(keyCode: keyCode, flags: flags))
            return
        }

        let maxLength = 4
        var actualLength = 0
        var chars = [UniChar](repeating: 0, count: maxLength)
        event.keyboardGetUnicodeString(maxStringLength: maxLength, actualStringLength: &actualLength, unicodeString: &chars)
        guard actualLength > 0 else { return }
        let typed = String(utf16CodeUnits: chars, count: actualLength)
        guard typed.count == 1, let character = typed.first else {
            buffer.clear()
            return
        }

        if character.isLetter {
            buffer.append(BufferedKeystroke(keyCode: keyCode, shift: flags.contains(.maskShift), character: character))
        } else {
            // Punctuation typed via a real key (not one of the boundary key
            // codes above, e.g. comma/period) also ends the word.
            completeWord(boundary: BoundaryKey(keyCode: keyCode, flags: flags))
        }
    }

    private func completeWord(boundary: BoundaryKey) {
        if !buffer.isEmpty {
            delegate?.keyboardMonitor(self, didCompleteWord: buffer, boundary: boundary)
        }
        buffer.clear()
    }
}
