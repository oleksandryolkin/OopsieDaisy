//
//  TextInjector.swift
//  OopsType
//
//  Synthesizes the backspace + retype sequence that performs a correction.
//  Every event we post is tagged with a marker so KeyboardMonitor can
//  recognize and ignore its own synthetic input (avoiding feedback loops).
//

import CoreGraphics
import Foundation

enum TextInjector {
    static let syntheticMarker: Int64 = 0x004F_5054_5354 // "OPTST"

    static func isSynthetic(_ event: CGEvent) -> Bool {
        event.getIntegerValueField(.eventSourceUserData) == syntheticMarker
    }

    static func sendBackspaces(_ count: Int) {
        guard count > 0 else { return }
        let source = CGEventSource(stateID: .hidSystemState)
        let backspace: CGKeyCode = 51
        for _ in 0..<count {
            postKey(keyCode: backspace, keyDown: true, source: source)
            postKey(keyCode: backspace, keyDown: false, source: source)
        }
    }

    static func typeUnicodeString(_ string: String) {
        guard !string.isEmpty else { return }
        let source = CGEventSource(stateID: .hidSystemState)
        guard let down = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true),
              let up = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false) else { return }
        down.setIntegerValueField(.eventSourceUserData, value: syntheticMarker)
        up.setIntegerValueField(.eventSourceUserData, value: syntheticMarker)
        let utf16 = Array(string.utf16)
        utf16.withUnsafeBufferPointer { buf in
            down.keyboardSetUnicodeString(stringLength: buf.count, unicodeString: buf.baseAddress)
            up.keyboardSetUnicodeString(stringLength: buf.count, unicodeString: buf.baseAddress)
        }
        down.post(tap: .cghidEventTap)
        up.post(tap: .cghidEventTap)
    }

    /// Replays the original boundary key (Space/Return/Tab/punctuation) with
    /// a real key code rather than a literal character, so apps that treat
    /// e.g. Return specially (submit, newline, focus change) behave exactly
    /// as if the user had pressed it themselves.
    static func resend(keyCode: CGKeyCode, flags: CGEventFlags) {
        let source = CGEventSource(stateID: .hidSystemState)
        postKey(keyCode: keyCode, keyDown: true, source: source, flags: flags)
        postKey(keyCode: keyCode, keyDown: false, source: source, flags: flags)
    }

    private static func postKey(keyCode: CGKeyCode, keyDown: Bool, source: CGEventSource?, flags: CGEventFlags = []) {
        guard let event = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: keyDown) else { return }
        event.setIntegerValueField(.eventSourceUserData, value: syntheticMarker)
        event.flags = flags
        event.post(tap: .cghidEventTap)
    }
}
