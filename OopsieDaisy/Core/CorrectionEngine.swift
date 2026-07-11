//
//  CorrectionEngine.swift
//  OopsieDaisy
//
//  Decides whether a just-finished word was typed in the wrong keyboard
//  layout and, if so, performs the fix: switch the input source, delete the
//  wrong word, retype it.
//

import AppKit
import CoreGraphics

@MainActor
final class CorrectionEngine {
    private let minimumWordLength = 3

    func evaluate(buffer: WordBuffer, boundary: BoundaryKey) {
        guard AppSettings.shared.isEnabled else { return }
        guard buffer.count >= minimumWordLength else { return }
        guard !isFrontmostAppExcluded() else { return }
        guard let currentLayout = InputSourceManager.currentKeyboardLayout() else { return }

        let originalWord = buffer.word
        guard !WordValidator.isValidWord(originalWord, primaryLanguageTag: currentLayout.primaryLanguage) else { return }

        let candidates = InputSourceManager.enabledKeyboardLayouts().filter { $0.id != currentLayout.id }
        for candidate in candidates {
            let candidateWord = LayoutConverter.convert(buffer.keystrokes, to: candidate.layoutData)
            guard candidateWord.count == originalWord.count, !candidateWord.isEmpty else { continue }
            guard WordValidator.isValidWord(candidateWord, primaryLanguageTag: candidate.primaryLanguage) else { continue }

            applyCorrection(originalLength: buffer.count, correctedWord: candidateWord, layout: candidate, boundary: boundary)
            return
        }
    }

    private func applyCorrection(originalLength: Int, correctedWord: String, layout: KeyboardLayoutSource, boundary: BoundaryKey) {
        InputSourceManager.select(layout)
        TextInjector.sendBackspaces(originalLength + 1) // + the boundary char itself
        TextInjector.typeUnicodeString(correctedWord)
        TextInjector.resend(keyCode: boundary.keyCode, flags: boundary.flags)
    }

    private func isFrontmostAppExcluded() -> Bool {
        guard let bundleID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier else { return false }
        return AppSettings.shared.excludedBundleIdentifiers.contains(bundleID)
    }
}
