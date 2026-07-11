//
//  LayoutConverter.swift
//  OopsieDaisy
//
//  Reconstructs what a sequence of physical key presses would have produced
//  under a *different* keyboard layout, using UCKeyTranslate directly against
//  that layout's own Unicode key layout data. This avoids hand-maintaining a
//  character mapping table: it works for any pair of layouts the user has
//  enabled, not just Russian/English, and it is guaranteed to match the
//  layout's real behavior (verified against this machine's actual
//  Russian/British layout data).
//

import Carbon
import Foundation

enum LayoutConverter {
    static func character(forKeyCode keyCode: CGKeyCode, shift: Bool, layoutData: Data) -> Character? {
        var result: Character?
        layoutData.withUnsafeBytes { (raw: UnsafeRawBufferPointer) in
            guard let keyLayoutPtr = raw.bindMemory(to: UCKeyboardLayout.self).baseAddress else { return }
            var deadKeyState: UInt32 = 0
            let maxLength = 4
            var chars = [UniChar](repeating: 0, count: maxLength)
            var actualLength = 0
            let modifierState: UInt32 = shift ? (UInt32(shiftKey) >> 8) : 0
            let status = UCKeyTranslate(
                keyLayoutPtr,
                keyCode,
                UInt16(kUCKeyActionDown),
                modifierState,
                UInt32(LMGetKbdType()),
                OptionBits(kUCKeyTranslateNoDeadKeysBit),
                &deadKeyState,
                maxLength,
                &actualLength,
                &chars
            )
            guard status == noErr, actualLength > 0 else { return }
            result = String(utf16CodeUnits: chars, count: actualLength).first
        }
        return result
    }

    static func convert(_ keystrokes: [BufferedKeystroke], to layoutData: Data) -> String {
        var out = ""
        out.reserveCapacity(keystrokes.count)
        for stroke in keystrokes {
            guard let c = character(forKeyCode: stroke.keyCode, shift: stroke.shift, layoutData: layoutData) else {
                return ""
            }
            out.append(c)
        }
        return out
    }
}
