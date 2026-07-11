//
//  LaunchAtLoginManager.swift
//  OopsieDaisy
//
//  Registers/unregisters OopsieDaisy as a login item via ServiceManagement,
//  so it can start automatically when the user logs in without needing a
//  privileged installer or a separate LaunchAgent plist.
//

import Combine
import Foundation
import ServiceManagement

@MainActor
final class LaunchAtLoginManager: ObservableObject {
    static let shared = LaunchAtLoginManager()

    @Published private(set) var isEnabled: Bool

    private init() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    /// Re-reads the actual system status — the user may have toggled this
    /// from System Settings > General > Login Items directly.
    func refresh() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("OopsieDaisy: failed to \(enabled ? "register" : "unregister") launch-at-login: \(error)")
        }
        refresh()
    }
}
