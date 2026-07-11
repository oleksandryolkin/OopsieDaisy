//
//  WordValidator.swift
//  OopsType
//
//  Offline word validity check backed by the system spell checker, so we
//  don't need to ship or maintain our own dictionaries.
//

import AppKit

enum WordValidator {
    private static var languageCache: [String: String?] = [:]

    static func isValidWord(_ word: String, primaryLanguageTag: String) -> Bool {
        guard let language = spellCheckerLanguage(for: primaryLanguageTag) else { return true }
        let checker = NSSpellChecker.shared
        let range = checker.checkSpelling(
            of: word,
            startingAt: 0,
            language: language,
            wrap: false,
            inSpellDocumentWithTag: 0,
            wordCount: nil
        )
        return range.location == NSNotFound
    }

    private static func spellCheckerLanguage(for tag: String) -> String? {
        if let cached = languageCache[tag] { return cached }
        let primary = tag.split(separator: "-").first.map(String.init) ?? tag
        let available = NSSpellChecker.shared.availableLanguages
        let match = available.first { $0.caseInsensitiveCompare(tag) == .orderedSame }
            ?? available.first { $0.lowercased().hasPrefix(primary.lowercased() + "_") }
            ?? available.first { $0.lowercased().hasPrefix(primary.lowercased()) }
        languageCache[tag] = match
        return match
    }
}
