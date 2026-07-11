//
//  WordBuffer.swift
//  OopsieDaisy
//

import CoreGraphics
import Foundation

/// A single letter key press: which physical key it was, whether Shift was
/// held, and what character the *current* layout produced for it. Keeping
/// the key code lets us reconstruct what any other layout would have typed.
struct BufferedKeystroke {
    let keyCode: CGKeyCode
    let shift: Bool
    let character: Character
}

/// Accumulates the keystrokes of the word currently being typed.
struct WordBuffer {
    private(set) var keystrokes: [BufferedKeystroke] = []

    var word: String { String(keystrokes.map(\.character)) }
    var count: Int { keystrokes.count }
    var isEmpty: Bool { keystrokes.isEmpty }

    mutating func append(_ stroke: BufferedKeystroke) {
        keystrokes.append(stroke)
    }

    mutating func removeLast() {
        if !keystrokes.isEmpty { keystrokes.removeLast() }
    }

    mutating func clear() {
        keystrokes.removeAll(keepingCapacity: true)
    }
}
