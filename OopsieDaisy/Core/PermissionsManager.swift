//
//  PermissionsManager.swift
//  OopsieDaisy
//

import AppKit
import ApplicationServices
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

    /// Accessibility is what actually gates performing the correction:
    /// synthesizing the backspace/retype (`CGEventPost`) and switching the
    /// active keyboard layout (`TISSelectInputSource`) both require it, even
    /// though observing keystrokes only needs Input Monitoring. macOS
    /// prompts for it on its own the first time those calls actually run,
    /// so this is just a settings shortcut — no explicit status check/request.
    static func openAccessibilitySettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else { return }
        NSWorkspace.shared.open(url)
    }
}
