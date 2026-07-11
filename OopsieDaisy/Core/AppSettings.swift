//
//  AppSettings.swift
//  OopsieDaisy
//

import Combine
import Foundation

@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var isEnabled: Bool {
        didSet { UserDefaults.standard.set(isEnabled, forKey: Keys.enabled) }
    }

    /// Apps where autocorrection is intentionally skipped: terminals, code
    /// editors and password managers regularly contain text that looks like
    /// gibberish to a spell checker in either language.
    let excludedBundleIdentifiers: Set<String> = [
        "com.apple.Terminal",
        "com.googlecode.iterm2",
        "dev.warp.Warp-Stable",
        "com.microsoft.VSCode",
        "com.jetbrains.intellij",
        "com.apple.dt.Xcode",
        "com.agilebits.onepassword7",
        "com.1password.1password",
        "com.apple.SecurityAgent",
    ]

    private enum Keys {
        static let enabled = "isEnabled"
    }

    private init() {
        if let stored = UserDefaults.standard.object(forKey: Keys.enabled) as? Bool {
            isEnabled = stored
        } else {
            isEnabled = true
        }
    }
}
