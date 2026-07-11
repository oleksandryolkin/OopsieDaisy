//
//  OopsieDaisyTests.swift
//  OopsieDaisyTests
//

import Testing
@testable import OopsieDaisy

struct OopsieDaisyTests {

    /// "ghbdtn" is the textbook example of a word typed in the wrong layout:
    /// the user meant to type "привет" (hello) but forgot to switch to
    /// Russian, so pressing the same physical keys under the English layout
    /// produced "ghbdtn". This exercises the real TIS layout data installed
    /// on the machine, not a hardcoded table.
    @Test func convertsGhbdtnToPrivet() throws {
        let layouts = InputSourceManager.enabledKeyboardLayouts()
        let russian = try #require(layouts.first { $0.primaryLanguage == "ru" })

        // Physical keys g, h, b, d, t, n (all unshifted).
        let keystrokes: [BufferedKeystroke] = [5, 4, 11, 2, 17, 45].map {
            BufferedKeystroke(keyCode: $0, shift: false, character: " ")
        }

        let converted = LayoutConverter.convert(keystrokes, to: russian.layoutData)
        #expect(converted == "привет")
    }

    @Test func spellCheckerRejectsGibberishAndAcceptsRealWords() {
        #expect(WordValidator.isValidWord("ghbdtn", primaryLanguageTag: "en") == false)
        #expect(WordValidator.isValidWord("hello", primaryLanguageTag: "en") == true)
        #expect(WordValidator.isValidWord("привет", primaryLanguageTag: "ru") == true)
    }
}
