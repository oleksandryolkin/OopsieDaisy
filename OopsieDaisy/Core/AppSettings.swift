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

    /// Off by default: terminals are common enough to want autocorrection in
    /// that some users will prefer it on, so exclusion is opt-in rather than
    /// baked in like the editors/password managers below.
    @Published var excludeTerminalApps: Bool {
        didSet { UserDefaults.standard.set(excludeTerminalApps, forKey: Keys.excludeTerminalApps) }
    }

    let terminalBundleIdentifiers: Set<String> = [
        "com.apple.Terminal",
        "com.googlecode.iterm2",
        "dev.warp.Warp-Stable",
    ]

    /// Apps where autocorrection is always skipped: code editors and
    /// password managers regularly contain text that looks like gibberish to
    /// a spell checker in either language.
    let alwaysExcludedBundleIdentifiers: Set<String> = [
        "com.microsoft.VSCode",
        "com.jetbrains.intellij",
        "com.apple.dt.Xcode",
        "com.agilebits.onepassword7",
        "com.1password.1password",
        "com.apple.SecurityAgent",
    ]

    var excludedBundleIdentifiers: Set<String> {
        excludeTerminalApps ? alwaysExcludedBundleIdentifiers.union(terminalBundleIdentifiers) : alwaysExcludedBundleIdentifiers
    }

    private enum Keys {
        static let enabled = "isEnabled"
        static let excludeTerminalApps = "excludeTerminalApps"
    }

    private init() {
        if let stored = UserDefaults.standard.object(forKey: Keys.enabled) as? Bool {
            isEnabled = stored
        } else {
            isEnabled = true
        }
        excludeTerminalApps = UserDefaults.standard.bool(forKey: Keys.excludeTerminalApps)
    }
}
