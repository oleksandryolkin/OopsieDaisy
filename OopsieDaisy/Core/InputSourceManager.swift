//
//  InputSourceManager.swift
//  OopsieDaisy
//

import Carbon
import Foundation

/// A keyboard input source enabled by the user (visible in the input menu),
/// together with the data needed to translate raw key codes under it.
struct KeyboardLayoutSource {
    let tisSource: TISInputSource
    let id: String
    /// Primary BCP-47 language tag, e.g. "ru", "en".
    let primaryLanguage: String
    let layoutData: Data
}

/// Thin wrapper around the Text Input Sources (TIS) APIs: lists the keyboard
/// layouts the user has enabled and switches the active one.
enum InputSourceManager {
    static func enabledKeyboardLayouts() -> [KeyboardLayoutSource] {
        let filter: [String: Any] = [
            kTISPropertyInputSourceCategory as String: kTISCategoryKeyboardInputSource as String
        ]
        // includeAllInstalled = false -> only sources the user actually enabled.
        guard let raw = TISCreateInputSourceList(filter as CFDictionary, false)?
            .takeRetainedValue() as? [TISInputSource] else {
            return []
        }
        return raw.compactMap(makeLayoutSource)
    }

    static func currentKeyboardLayout() -> KeyboardLayoutSource? {
        guard let source = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else { return nil }
        return makeLayoutSource(from: source)
    }

    static func select(_ layout: KeyboardLayoutSource) {
        TISSelectInputSource(layout.tisSource)
    }

    private static func makeLayoutSource(from source: TISInputSource) -> KeyboardLayoutSource? {
        guard isSelectable(source) else { return nil }
        guard let languages = stringArrayProperty(source, kTISPropertyInputSourceLanguages),
              let primaryLanguage = languages.first else { return nil }
        guard let layoutData = dataProperty(source, kTISPropertyUnicodeKeyLayoutData) else { return nil }
        guard let id = stringProperty(source, kTISPropertyInputSourceID) else { return nil }
        return KeyboardLayoutSource(tisSource: source, id: id, primaryLanguage: primaryLanguage, layoutData: layoutData)
    }

    private static func isSelectable(_ source: TISInputSource) -> Bool {
        guard let p = TISGetInputSourceProperty(source, kTISPropertyInputSourceIsSelectCapable) else { return false }
        return Unmanaged<CFBoolean>.fromOpaque(p).takeUnretainedValue() == kCFBooleanTrue
    }

    private static func stringProperty(_ source: TISInputSource, _ key: CFString) -> String? {
        guard let p = TISGetInputSourceProperty(source, key) else { return nil }
        return Unmanaged<CFString>.fromOpaque(p).takeUnretainedValue() as String
    }

    private static func stringArrayProperty(_ source: TISInputSource, _ key: CFString) -> [String]? {
        guard let p = TISGetInputSourceProperty(source, key) else { return nil }
        return Unmanaged<CFArray>.fromOpaque(p).takeUnretainedValue() as? [String]
    }

    private static func dataProperty(_ source: TISInputSource, _ key: CFString) -> Data? {
        guard let p = TISGetInputSourceProperty(source, key) else { return nil }
        return Unmanaged<CFData>.fromOpaque(p).takeUnretainedValue() as Data
    }
}
