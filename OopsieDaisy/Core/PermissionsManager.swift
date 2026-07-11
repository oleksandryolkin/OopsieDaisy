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
    /// though observing keystrokes only needs Input Monitoring.
    static func hasAccessibilityAccess() -> Bool {
        AXIsProcessTrusted()
    }

    /// Prompts the system dialog on first call if not yet granted.
    static func requestAccessibilityAccess() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: true]
        _ = AXIsProcessTrustedWithOptions(options)
    }

    static func openAccessibilitySettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else { return }
        NSWorkspace.shared.open(url)
    }
}
