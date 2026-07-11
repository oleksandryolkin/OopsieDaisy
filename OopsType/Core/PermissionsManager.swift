//
//  PermissionsManager.swift
//  OopsType
//

import AppKit
import IOKit.hid

enum PermissionsManager {
    static func hasInputMonitoringAccess() -> Bool {
        IOHIDCheckAccess(kIOHIDRequestTypeListenEvent) == kIOHIDAccessTypeGranted
    }

    /// Registers the app with the system so it shows up under
    /// System Settings > Privacy & Security > Input Monitoring.
    /// On first call macOS presents the permission prompt itself.
    static func requestInputMonitoringAccess() {
        IOHIDRequestAccess(kIOHIDRequestTypeListenEvent)
    }

    static func openInputMonitoringSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent") else { return }
        NSWorkspace.shared.open(url)
    }
}
